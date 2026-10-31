import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/websocket.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:island/shared/widgets/app_startup_progress.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Flip to `true` to keep the splash stuck on its final bootstrap stage
/// (cannot be skipped), for previewing the startup UI.
/// Debug builds only; release builds never hang regardless of this flag.
const kStuckStartupForPreview = false;

const kDefaultBootstrapRetryTimeouts = <Duration>[
  Duration(milliseconds: 1000),
  Duration(seconds: 2),
  Duration(seconds: 3),
];

/// Vertical space reserved at the bottom of the splash for the progress
/// cluster. The portrait ends above it so the artwork and the cluster never
/// overlap; kept in sync with the bottom scrim height.
const kSplashBottomReserve = 280.0;

/// Top margin of the portrait: slides the artwork down from the safe-area
/// edge, so it reads as a poster rather than a full-bleed header.
const kSplashImageTopInset = 32.0;

/// Bottom clearance of the portrait, deliberately smaller than
/// [kSplashBottomReserve] so the 9:16 poster grows to its widest possible
/// size. The artwork is capped by its aspect ratio, so this only has to keep
/// it clear of the progress cluster; the bottom scrim fades its lower edge.
const kSplashImageBottomInset = 200.0;

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
    final packageVersion = useState<String?>(null);

    useEffect(() {
      PackageInfo.fromPlatform().then((info) {
        final versionStr = info.buildNumber.isNotEmpty
            ? '${info.version}+${info.buildNumber}'
            : info.version;
        packageVersion.value = versionStr;
      }).catchError((_) {});
      return null;
    }, const []);

    final subtitle = useState<String?>(null);
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final hasConnectivity = hasNetworkConnectivityValue(connectivityStatus);
    final stages = useMemoized(
      () => <_BootstrapStage>[
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
            if (Firebase.apps.isEmpty) return;
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
        if (kStuckStartupForPreview && kDebugMode)
          _BootstrapStage(
            label: 'startupStageDebugHang'.tr(),
            isCritical: true,
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
    final sessionExpiredWarning = useState(false);
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
      subtitle.value = null;
      showSkip.value = false;
      warnings.value = [];
      sessionExpiredWarning.value = false;
      final failedStages = <String>[];

      for (var idx = 0; idx < stages.length; idx++) {
        if (phaseNonce.value != phase) return;

        if (!hasNetworkConnectivityValue(
          ref.read(connectivityStatusProvider),
        )) {
          isBusy.value = false;
          isErrored.value = true;
          isDismissable.value = false;
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
        } catch (error) {
          failedStages.add(stage.label);
          final String warning;
          if (error is DioException &&
              error.response?.statusCode == 401) {
            // Session logged out or expired: show a specific, dismissable
            // message instead of the generic retry-failure notice. No retries,
            // no automatic logout.
            sessionExpiredWarning.value = true;
            warning = 'failedToLoadUserInfoUnauthorized'.tr();
          } else {
            warning = 'startupStageFailedAfterRetries'.tr(args: [stage.label]);
          }
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
        if (sessionExpiredWarning.value) {
          subtitle.value = 'failedToLoadUserInfoUnauthorized'.tr();
        } else if (failedStages.length == 1) {
          subtitle.value =
              '${'startupStageFailedAfterRetries'.tr(args: [failedStages.first])} ${'startupTapToContinue'.tr()}';
        } else if (failedStages.isNotEmpty) {
          subtitle.value =
              '${'startupStagesSkipped'.tr(args: ['${failedStages.length}'])} (${failedStages.join(', ')})';
        } else {
          subtitle.value =
              'startupStagesSkipped'.tr(args: ['${warnings.value.length}']);
        }
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
    final wide = isWideScreen(context);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top section: future artwork
            Expanded(
              child: ColoredBox(
                color: colorScheme.surfaceContainer,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                  ClipRect(
                    child: wide
                        ? Center(
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Image.asset(
                                'assets/images/michan/landing.webp',
                                key: const Key('startup-portrait-image'),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/michan/landing.webp',
                            key: const Key('startup-portrait-image'),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                          ),
                  ),
                  // Progress indicator label (bottom-right above the divider)
                  Positioned(
                    right: 16,
                    bottom: 8,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isBusy.value
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.surface.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$percentage%',
                                key: ValueKey(percentage),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
            // Progress divider line separating artwork from the bottom panel
            Container(
              height: 3.0,
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              child: StartupProgressBar(
                progress: progress,
                isErrored: isErrored.value,
                colorScheme: colorScheme,
              ),
            ),
            // Bottom section: app icon, wordmark + version, current stage
            SafeArea(
              top: false,
              child: SizedBox(
                key: const Key('startup-bottom-bar'),
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    SvgPicture.asset(
                      'assets/icons/icon-outline.svg',
                      key: const Key('startup-app-icon'),
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: Text(
                                  'Solar Network',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (packageVersion.value != null &&
                                  packageVersion.value!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'v${packageVersion.value}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          _StageInfo(
                            stages: stages,
                            currentIndex: periodCursor.value,
                            subtitle: subtitle.value,
                            isBusy: isBusy.value,
                            isErrored: isErrored.value,
                            isDismissable: isDismissable.value,
                            textTheme: textTheme,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                    ),
                    if (isBusy.value &&
                        isCurrentStageSkippable.value &&
                        showSkip.value) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (skipCompleterRef.value?.isCompleted == false) {
                            skipCompleterRef.value?.complete();
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'startupSkipOptional'.tr(),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          ],
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
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StageInfo({
    required this.stages,
    required this.currentIndex,
    required this.subtitle,
    required this.isBusy,
    required this.isErrored,
    required this.isDismissable,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = colorScheme.onSurface.withValues(alpha: 0.5);

    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: isErrored ? colorScheme.error : mutedColor,
                fontSize: 13,
              ),
            )
          : isBusy && stages.isNotEmpty && currentIndex < stages.length
          ? Text(
              key: ValueKey('busy-$currentIndex'),
              stages[currentIndex].label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: mutedColor,
                fontSize: 13,
              ),
            )
          : isErrored && isDismissable
          ? Text(
              key: const ValueKey('incomplete'),
              '${'startupIncomplete'.tr()} — ${'startupTapToContinue'.tr()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
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
