import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/websocket.dart';

const kDefaultBootstrapRetryTimeouts = <Duration>[
  Duration(milliseconds: 1000),
  Duration(seconds: 2),
  Duration(seconds: 3),
];

class StartupSplashScreen extends HookConsumerWidget {
  final bool runBootstrap;
  final VoidCallback onCompleted;
  final List<Duration> retryTimeouts;

  const StartupSplashScreen({
    super.key,
    required this.runBootstrap,
    required this.onCompleted,
    this.retryTimeouts = kDefaultBootstrapRetryTimeouts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> runWithTimeoutRetries({
      required Future<void> Function(Duration timeout) action,
      required String stageLabel,
      required ValueNotifier<String?> subtitle,
    }) async {
      for (var idx = 0; idx < retryTimeouts.length; idx++) {
        final timeout = retryTimeouts[idx];
        try {
          await action(timeout);
          return;
        } catch (e, _) {
          subtitle.value =
              '$stageLabel retry ${idx + 1}/${retryTimeouts.length} failed.';
        }
      }
    }

    final subtitle = useState<String?>(null);
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final hasConnectivity = hasNetworkConnectivityValue(connectivityStatus);
    final stages = useMemoized(
      () => <_BootstrapStage>[
        _BootstrapStage(
          label: 'Checking service health',
          isCritical: true,
          action: () async {
            await runWithTimeoutRetries(
              stageLabel: 'Health check',
              subtitle: subtitle,
              action: (timeout) async {
                final apiClient = ref.read(solarNetworkClientProvider);
                final response = await apiClient.dio.get(
                  '/health',
                  options: Options(
                    validateStatus: (_) => true,
                    connectTimeout: timeout,
                    sendTimeout: timeout,
                    receiveTimeout: timeout,
                  ),
                );
                final code = response.statusCode ?? 0;
                if (code != 200) {
                  throw DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    error: 'Health check failed with status $code',
                  );
                }
              },
            );
          },
        ),
        _BootstrapStage(
          label: 'Loading account profile',
          isCritical: true,
          action: () async {
            await ref
                .read(userInfoProvider.notifier)
                .fetchUserForBootstrap(retryTimeouts: retryTimeouts);
          },
        ),
        _BootstrapStage(
          label: 'Connecting realtime gateway',
          isCritical: true,
          action: () async {
            await ref.read(websocketStateProvider.notifier).connect();
          },
        ),
        // Python 初始化阶段 - 放在网络连接之后，推送通知之前
        // TODO enable it till the python service is stable
        // _BootstrapStage(
        //   label: 'Initializing Python scripts',
        //   isCritical: false,
        //   action: () async {
        //     await python.initPython();
        //   },
        // ),
        _BootstrapStage(
          label: 'Registering push notifications',
          isCritical: false,
          action: () async {
            final user = await ref.read(userInfoProvider.future);
            if (!context.mounted || user == null) return;
            final apiClient = ref.read(solarNetworkClientProvider).dio;
            await subscribePushNotification(apiClient, context: context);
          },
        ),
        _BootstrapStage(
          label: 'Preparing local notifications',
          isCritical: false,
          action: () async {
            await initializeLocalNotifications(ref);
          },
        ),
        _BootstrapStage(
          label: 'Preparing audio assets',
          isCritical: false,
          action: () async {
            await ref.read(audioSessionProvider.future);
            await ref.read(notificationSfxProvider.future);
            await ref.read(messageSfxProvider.future);
          },
        ),
      ],
      [],
    );

    final isBusy = useState(true);
    final isErrored = useState(false);
    final isDismissable = useState(true);
    final isWaitingForConnectivity = useState(false);
    final periodCursor = useState(0);
    final showSkip = useState(false);
    final isCurrentStageSkippable = useState(false);
    final phaseNonce = useRef(0);
    final skipCompleterRef = useRef<Completer<void>?>(null);
    final warnings = useState<List<String>>([]);
    final unFocusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.75);

    Future<void> runStages() async {
      final phase = ++phaseNonce.value;
      isBusy.value = true;
      isErrored.value = false;
      isDismissable.value = true;
      isWaitingForConnectivity.value = false;
      subtitle.value = null;
      showSkip.value = false;
      warnings.value = [];

      for (var idx = 0; idx < stages.length; idx++) {
        if (phaseNonce.value != phase) return;

        if (!hasNetworkConnectivityValue(
          ref.read(connectivityStatusProvider),
        )) {
          isBusy.value = false;
          isErrored.value = true;
          isDismissable.value = false;
          isWaitingForConnectivity.value = true;
          subtitle.value = 'No internet connection. Waiting to resume startup.';
          return;
        }

        final stage = stages[idx];
        periodCursor.value = idx;
        isCurrentStageSkippable.value = !stage.isCritical;
        skipCompleterRef.value = Completer<void>();
        showSkip.value = false;

        Timer? skipTimer;
        if (!stage.isCritical) {
          skipTimer = Timer(const Duration(milliseconds: 500), () {
            if (phaseNonce.value == phase && isBusy.value) {
              showSkip.value = true;
            }
          });
        }

        try {
          if (stage.isCritical) {
            await stage.action();
          } else {
            await Future.any([stage.action(), skipCompleterRef.value!.future]);
            if (skipCompleterRef.value!.isCompleted) {
              subtitle.value = 'Skipped optional stage: ${stage.label}';
            }
          }
        } catch (_) {
          final warning = 'Skipped "${stage.label}" after retries.';
          warnings.value = [...warnings.value, warning];
          subtitle.value = '$warning App may have limited functionality.';
        } finally {
          skipTimer?.cancel();
          showSkip.value = false;
          skipCompleterRef.value = null;
        }
      }

      if (phaseNonce.value != phase) return;
      isBusy.value = false;
      if (warnings.value.isEmpty) {
        if (runBootstrap) onCompleted();
      } else {
        isErrored.value = true;
        isDismissable.value = true;
        subtitle.value =
            '${warnings.value.length} startup stage(s) were skipped due to network issues. Tap to continue.';
      }
    }

    useEffect(() {
      if (!runBootstrap) {
        isBusy.value = false;
        subtitle.value = null;
        return null;
      }
      if (!hasConnectivity) {
        phaseNonce.value++;
        isBusy.value = false;
        isErrored.value = true;
        isDismissable.value = false;
        isWaitingForConnectivity.value = true;
        subtitle.value = 'No internet connection. Waiting to resume startup.';
        return null;
      }
      Future(() => runStages());
      return () {
        phaseNonce.value++;
      };
    }, [runBootstrap, hasConnectivity]);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          if (isBusy.value) return;
          if (isDismissable.value) {
            if (runBootstrap) {
              onCompleted();
            }
          } else {
            Future(() => runStages());
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 280,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Image.asset(
                    'assets/icons/icon.webp',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                if (isErrored.value && !isDismissable.value && !isBusy.value)
                  Icon(
                    isWaitingForConnectivity.value
                        ? Icons.wifi_off
                        : Icons.cancel,
                    size: 24,
                  ),
                if (isErrored.value && isDismissable.value && !isBusy.value)
                  const Icon(Icons.warning, size: 24),
                if ((isErrored.value && isDismissable.value && isBusy.value) ||
                    isBusy.value)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                if (!isBusy.value && !isErrored.value)
                  const Icon(Icons.check_circle, size: 24, color: Colors.green),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    children: [
                      if (subtitle.value == null)
                        Text(
                          '${stages[periodCursor.value].label} (${periodCursor.value + 1}/${stages.length})',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: unFocusColor),
                        ),
                      if (subtitle.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            subtitle.value!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: unFocusColor),
                          ),
                        ),
                      if (!isBusy.value &&
                          isErrored.value &&
                          isDismissable.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Tap anywhere to dismiss',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: unFocusColor),
                          ),
                        ),
                      if (isBusy.value &&
                          isCurrentStageSkippable.value &&
                          showSkip.value)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton(
                            onPressed: () {
                              if (skipCompleterRef.value?.isCompleted ==
                                  false) {
                                skipCompleterRef.value?.complete();
                              }
                            },
                            child: const Text('Skip optional stage'),
                          ),
                        ),
                      Text(
                        '${DateTime.now().year} © Solsynth LLC',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: unFocusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapStage {
  final String label;
  final bool isCritical;
  final Future<void> Function() action;

  const _BootstrapStage({
    required this.label,
    required this.isCritical,
    required this.action,
  });
}
