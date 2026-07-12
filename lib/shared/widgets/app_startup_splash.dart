import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/websocket.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:island/shared/widgets/app_startup_progress.dart';
import 'package:styled_widget/styled_widget.dart';

const kDebugStartup = false;

const kDefaultBootstrapRetryTimeouts = <Duration>[
  Duration(milliseconds: 1000),
  Duration(seconds: 2),
  Duration(seconds: 3),
];

class StartupSplashScreen extends HookConsumerWidget {
  final bool runBootstrap;
  final VoidCallback onCompleted;
  final List<Duration> retryTimeouts;
  final bool showCompleted;

  const StartupSplashScreen({
    super.key,
    required this.runBootstrap,
    required this.onCompleted,
    this.retryTimeouts = kDefaultBootstrapRetryTimeouts,
    this.showCompleted = false,
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
          subtitle.value = 'startupRetryFailed'.tr(
            args: [stageLabel, '${idx + 1}', '${retryTimeouts.length}'],
          );
        }
      }
    }

    final subtitle = useState<String?>(null);
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final hasConnectivity = hasNetworkConnectivityValue(connectivityStatus);
    final stages = useMemoized(
      () => <_BootstrapStage>[
        _BootstrapStage(
          label: 'startupStageHealthCheck'.tr(),
          isCritical: true,
          action: () async {
            await runWithTimeoutRetries(
              stageLabel: 'startupStageHealthCheck'.tr(),
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
          label: 'startupStageLoadProfile'.tr(),
          isCritical: true,
          action: () async {
            await ref
                .read(userInfoProvider.notifier)
                .fetchUserForBootstrap(retryTimeouts: retryTimeouts);
          },
        ),
        _BootstrapStage(
          label: 'startupStageConnectGateway'.tr(),
          isCritical: true,
          action: () async {
            await ref.read(websocketStateProvider.notifier).connect();
          },
        ),
        _BootstrapStage(
          label: 'startupStagePushNotifications'.tr(),
          isCritical: false,
          action: () async {
            final user = await ref.read(userInfoProvider.future);
            if (!context.mounted || user == null) return;
            final apiClient = ref.read(solarNetworkClientProvider).dio;
            await subscribePushNotification(
              apiClient,
              context: context,
            ).timeout(const Duration(seconds: 1), onTimeout: () {});
          },
        ),
        _BootstrapStage(
          label: 'startupStageLocalNotifications'.tr(),
          isCritical: false,
          action: () async {
            await initializeLocalNotifications(ref);
          },
        ),
        _BootstrapStage(
          label: 'startupStageAudioAssets'.tr(),
          isCritical: false,
          action: () async {
            if (kIsWeb || (!Platform.isIOS && !Platform.isMacOS)) return;
            await ref.read(audioSessionProvider.future);
          },
        ),
        _BootstrapStage(
          label: 'Loading plugins',
          isCritical: false,
          action: () async {
            final manager = PluginManager();
            await manager.initialize();
            await manager.loadAllAtStartup();
          },
        ),
        if (kDebugStartup)
          _BootstrapStage(
            label: 'startupStageDebugHang'.tr(),
            isCritical: false,
            action: () async {
              await Completer<void>().future;
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

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          subtitle.value = 'startupNoInternet'.tr();
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
              subtitle.value = 'startupSkippedStage'.tr(args: [stage.label]);
            }
          }
        } catch (_) {
          final warning = 'startupStageFailedAfterRetries'.tr(
            args: [stage.label],
          );
          warnings.value = [...warnings.value, warning];
          subtitle.value = '$warning ${'startupLimitedFunctionality'.tr()}';
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
        subtitle.value = 'startupStagesSkipped'.tr(
          args: ['${warnings.value.length}'],
        );
      }
    }

    useEffect(() {
      if (showCompleted) {
        isBusy.value = false;
        isErrored.value = false;
        isDismissable.value = true;
        subtitle.value = null;
        return null;
      }
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
        subtitle.value = 'startupNoInternet'.tr();
        return null;
      }
      Future(() => runStages());
      return () {
        phaseNonce.value++;
      };
    }, [runBootstrap, hasConnectivity, showCompleted]);

    final progress = stages.isEmpty
        ? 0.0
        : (periodCursor.value + (isBusy.value ? 0.5 : 1.0)) / stages.length;
    final percentage = (progress * 100).round();

    return Material(
      color: colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          if (isBusy.value) return;
          if (isDismissable.value) {
            onCompleted();
          } else {
            Future(() => runStages());
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isBusy.value
                            ? Text(
                                '$percentage%',
                                key: ValueKey(percentage),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                key: ValueKey('idle-progress-label'),
                                height: 18,
                              ),
                      ),
                      const SizedBox(height: 8),
                      StartupProgressBar(
                        progress: progress,
                        isErrored: isErrored.value,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  StartupProgressIcon(
                    isBusy: isBusy.value,
                    isErrored: isErrored.value,
                    isDismissable: isDismissable.value,
                    isWaitingForConnectivity: isWaitingForConnectivity.value,
                    colorScheme: colorScheme,
                  ),
                  const Spacer(flex: 2),
                  _StageInfo(
                    stages: stages,
                    currentIndex: periodCursor.value,
                    subtitle: subtitle.value,
                    isBusy: isBusy.value,
                    isErrored: isErrored.value,
                    isDismissable: isDismissable.value,
                    showSkip: showSkip.value,
                    isCurrentStageSkippable: isCurrentStageSkippable.value,
                    onSkip: () {
                      if (skipCompleterRef.value?.isCompleted == false) {
                        skipCompleterRef.value?.complete();
                      }
                    },
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 24 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Text(
                      'startupCopyright'.tr(args: ['${DateTime.now().year}']),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ).center(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageInfo extends StatelessWidget {
  final List<_BootstrapStage> stages;
  final int currentIndex;
  final String? subtitle;
  final bool isBusy;
  final bool isErrored;
  final bool isDismissable;
  final bool showSkip;
  final bool isCurrentStageSkippable;
  final VoidCallback onSkip;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StageInfo({
    required this.stages,
    required this.currentIndex,
    required this.subtitle,
    required this.isBusy,
    required this.isErrored,
    required this.isDismissable,
    required this.showSkip,
    required this.isCurrentStageSkippable,
    required this.onSkip,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = colorScheme.onSurface.withValues(alpha: 0.5);
    final dimColor = colorScheme.onSurface.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex > 0)
            AnimatedOpacity(
              opacity: 0.8,
              duration: const Duration(milliseconds: 300),
              child: Text(
                stages[currentIndex - 1].label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: dimColor,
                  fontSize: 11,
                ),
              ),
            ),
          if (currentIndex > 0) const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: subtitle != null
                ? Text(
                    key: ValueKey('subtitle-$subtitle'),
                    subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      fontSize: 13,
                    ),
                  )
                : isBusy
                ? Column(
                    key: ValueKey('busy-$currentIndex'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stages[currentIndex].label,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentIndex + 1} / ${stages.length}',
                        style: textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                          fontSize: 12,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  )
                : isErrored && isDismissable
                ? Column(
                    key: const ValueKey('incomplete'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'startupIncomplete'.tr(),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'startupTapToContinue'.tr(),
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          if (currentIndex < stages.length - 1) ...[
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: isBusy ? 0.8 : 0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                stages[currentIndex + 1].label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: dimColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],
          if (isBusy && isCurrentStageSkippable && showSkip) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'startupSkipOptional'.tr(),
                style: TextStyle(color: colorScheme.primary, fontSize: 12),
              ),
            ),
          ],
        ],
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
