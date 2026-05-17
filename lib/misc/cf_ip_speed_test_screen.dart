import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network/cf_ip_speed_test.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class CfIpSpeedTestScreen extends HookConsumerWidget {
  const CfIpSpeedTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = useState<String>('idle');
    final progress = useState<CfIpTestPhase?>(null);
    final availableCount = useState(0);
    final currentIp = useState<String?>(null);
    final tcpResults = useState<List<CfIpTestResult>>([]);
    final httpResults = useState<List<CfIpTestResult>>([]);
    final downloadResults = useState<List<CfIpTestResult>>([]);
    final selectedIps = useState<Set<String>>({});
    final isRunning = useState(false);
    final errorMessage = useState<String?>(null);
    final quickTest = useState(true);
    final enableIpv4 = useState(true);
    final enableIpv6 = useState(true);
    final cancelToken = useState<CfIpTestCancelToken?>(null);
    StreamSubscription<CfIpTestProgress>? subscription;

    useEffect(() {
      return () {
        cancelToken.value?.cancel();
        subscription?.cancel();
      };
    }, []);

    void stopTest() {
      cancelToken.value?.cancel();
      subscription?.cancel();
      subscription = null;
      isRunning.value = false;
      currentIp.value = null;
    }

    void skipStage() {
      cancelToken.value?.requestSkipStage();
    }

    void startTest() {
      stopTest();
      phase.value = 'tcp';
      isRunning.value = true;
      errorMessage.value = null;
      tcpResults.value = [];
      httpResults.value = [];
      downloadResults.value = [];
      selectedIps.value = {};

      final token = CfIpTestCancelToken();
      cancelToken.value = token;

      subscription =
          runCfIpSpeedTest(
            ipRangesV4: cfIpv4Ranges,
            ipRangesV6: cfIpv6Ranges,
            ipCount: 200,
            tcpPingTimes: 4,
            maxRoutines: 200,
            httpPingCount: 50,
            httpPingTimes: 2,
            downloadCount: 10,
            httpUrl: ref.read(serverUrlProvider),
            downloadUrl: 'https://speed.cloudflare.com/__down?bytes=50000000',
            tcpTimeout: const Duration(seconds: 2),
            httpTimeout: const Duration(seconds: 5),
            downloadTimeout: const Duration(seconds: 10),
            quickTest: quickTest.value,
            enableIpv4: enableIpv4.value,
            enableIpv6: enableIpv6.value,
            cancelToken: token,
          ).listen(
            (event) {
              if (token.cancelled) return;
              switch (event) {
                case CfIpTcpPingProgress p:
                  phase.value = 'tcp';
                  progress.value = p.phase;
                  availableCount.value = p.availableCount;
                  currentIp.value = p.currentIp;
                  tcpResults.value = p.results;
                case CfIpHttpPingProgress p:
                  phase.value = 'http';
                  progress.value = p.phase;
                  httpResults.value = p.results;
                case CfIpDownloadProgress p:
                  phase.value = 'download';
                  progress.value = p.phase;
                  downloadResults.value = p.results;
                case CfIpTestComplete c:
                  phase.value = 'complete';
                  isRunning.value = false;
                  downloadResults.value = c.results;
                  subscription?.cancel();
                  currentIp.value = null;
                case CfIpTestError e:
                  phase.value = 'error';
                  isRunning.value = false;
                  errorMessage.value = e.message;
                  subscription?.cancel();
                  currentIp.value = null;
              }
            },
            onError: (err) {
              phase.value = 'error';
              isRunning.value = false;
              errorMessage.value = err.toString();
              currentIp.value = null;
              subscription?.cancel();
            },
          );
    }

    void applyFastestIp() {
      final allResults = downloadResults.value.isNotEmpty
          ? downloadResults.value
          : httpResults.value.isNotEmpty
          ? httpResults.value
          : tcpResults.value;

      if (allResults.isEmpty) return;

      final fastest = allResults.first;
      ref.read(appSettingsProvider.notifier).setIpOverrideList([
        IpOverride(ip: fastest.ip),
      ]);
      ref.read(appSettingsProvider.notifier).setIpOverrideEnabled(true);
      showSnackBar('settingsApplied'.tr());
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('cfIpSpeedTest').tr(),
        actions: [
          if (phase.value == 'complete' && !isRunning.value)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton(
                onPressed: applyFastestIp,
                child: Text('applyFastest').tr(),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: isWiderScreen(context)
            ? Padding(
                padding: EdgeInsets.all(isWidestScreen(context) ? 24 : 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: isWidestScreen(context) ? 420 : 380,
                      child: _ProgressBar(
                        phase: phase.value,
                        progress: progress.value,
                        availableCount: availableCount.value,
                        currentIp: currentIp.value,
                        isRunning: isRunning.value,
                        quickTest: quickTest.value,
                        onQuickTestChanged: (value) => quickTest.value = value,
                        enableIpv4: enableIpv4.value,
                        enableIpv6: enableIpv6.value,
                        onIpv4Changed: (value) => enableIpv4.value = value,
                        onIpv6Changed: (value) => enableIpv6.value = value,
                        onStart: startTest,
                        onStop: stopTest,
                        onSkipStage: skipStage,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ResultsView(
                        phase: phase.value,
                        tcpResults: tcpResults.value,
                        httpResults: httpResults.value,
                        downloadResults: downloadResults.value,
                        selectedIps: selectedIps.value,
                        onIpSelected: (ip) {
                          final newSet = Set<String>.from(selectedIps.value);
                          if (newSet.contains(ip)) {
                            newSet.remove(ip);
                          } else if (newSet.length < 10) {
                            newSet.add(ip);
                          }
                          selectedIps.value = newSet;
                        },
                        errorMessage: errorMessage.value,
                        onRetry: startTest,
                        onStop: stopTest,
                        onSkipStage: skipStage,
                        compactRows: true,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _ProgressBar(
                    phase: phase.value,
                    progress: progress.value,
                    availableCount: availableCount.value,
                    currentIp: currentIp.value,
                    isRunning: isRunning.value,
                    quickTest: quickTest.value,
                    onQuickTestChanged: (value) => quickTest.value = value,
                    enableIpv4: enableIpv4.value,
                    enableIpv6: enableIpv6.value,
                    onIpv4Changed: (value) => enableIpv4.value = value,
                    onIpv6Changed: (value) => enableIpv6.value = value,
                    onStart: startTest,
                    onStop: stopTest,
                    onSkipStage: skipStage,
                  ),
                  Expanded(
                    child: _ResultsView(
                      phase: phase.value,
                      tcpResults: tcpResults.value,
                      httpResults: httpResults.value,
                      downloadResults: downloadResults.value,
                      selectedIps: selectedIps.value,
                      onIpSelected: (ip) {
                        final newSet = Set<String>.from(selectedIps.value);
                        if (newSet.contains(ip)) {
                          newSet.remove(ip);
                        } else if (newSet.length < 10) {
                          newSet.add(ip);
                        }
                        selectedIps.value = newSet;
                      },
                      errorMessage: errorMessage.value,
                      onRetry: startTest,
                      onStop: stopTest,
                      onSkipStage: skipStage,
                      compactRows: false,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String phase;
  final CfIpTestPhase? progress;
  final int availableCount;
  final String? currentIp;
  final bool isRunning;
  final bool quickTest;
  final ValueChanged<bool> onQuickTestChanged;
  final bool enableIpv4;
  final bool enableIpv6;
  final ValueChanged<bool> onIpv4Changed;
  final ValueChanged<bool> onIpv6Changed;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSkipStage;

  const _ProgressBar({
    required this.phase,
    required this.progress,
    required this.availableCount,
    required this.currentIp,
    required this.isRunning,
    required this.quickTest,
    required this.onQuickTestChanged,
    required this.enableIpv4,
    required this.enableIpv6,
    required this.onIpv4Changed,
    required this.onIpv6Changed,
    required this.onStart,
    required this.onStop,
    required this.onSkipStage,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final phaseLabel = phase == 'tcp'
        ? 'phaseTcpPing'.tr()
        : phase == 'http'
        ? 'phaseHttpPing'.tr()
        : phase == 'download'
        ? 'phaseDownload'.tr()
        : phase == 'complete'
        ? 'phaseComplete'.tr()
        : 'cfIpSpeedTest'.tr();
    final canSkipStage = phase == 'tcp'
        ? availableCount > 0
        : phase == 'http'
        ? progress != null && progress!.current > 0
        : phase == 'download'
        ? progress != null && progress!.current > 0
        : false;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isRunning
                      ? CircularProgressIndicator(padding: EdgeInsets.all(12))
                      : Icon(Symbols.speed, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phaseLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRunning
                            ? 'Testing Cloudflare IPs'
                            : 'Choose settings and start the scan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (phase == 'tcp' && availableCount > 0)
                  _MiniStat(label: 'available'.tr(), value: '$availableCount'),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress!.total > 0
                      ? progress!.current / progress!.total
                      : 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress!.current}/${progress!.total} ${'ipsTested'.tr()}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (currentIp != null) ...[
              const SizedBox(height: 12),
              _StatusRow(
                icon: Symbols.hourglass_top,
                label: 'testingIp'.tr(args: [currentIp!]),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  selected: quickTest,
                  label: Text(
                    quickTest ? 'quickTestOn'.tr() : 'quickTestOff'.tr(),
                  ),
                  onSelected: isRunning ? null : onQuickTestChanged,
                ),
                FilterChip(
                  selected: enableIpv4,
                  label: const Text('IPv4'),
                  onSelected: isRunning ? null : onIpv4Changed,
                ),
                FilterChip(
                  selected: enableIpv6,
                  label: const Text('IPv6'),
                  onSelected: isRunning ? null : onIpv6Changed,
                ),
                ActionChip(
                  avatar: Icon(
                    isRunning ? Symbols.hourglass_bottom : Symbols.play_arrow,
                    size: 18,
                  ),
                  label: Text(
                    phase == 'complete' ? 'testAgain'.tr() : 'startTest'.tr(),
                  ),
                  onPressed: isRunning ? null : onStart,
                ),
                if (isRunning && canSkipStage)
                  ActionChip(
                    avatar: const Icon(Symbols.skip_next, size: 18),
                    label: Text('Skip stage'),
                    onPressed: onSkipStage,
                  ),
                if (isRunning)
                  ActionChip(
                    avatar: const Icon(Symbols.stop, size: 18),
                    label: Text('stop'.tr()),
                    onPressed: onStop,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final String phase;
  final List<CfIpTestResult> tcpResults;
  final List<CfIpTestResult> httpResults;
  final List<CfIpTestResult> downloadResults;
  final Set<String> selectedIps;
  final void Function(String ip) onIpSelected;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onStop;
  final VoidCallback onSkipStage;
  final bool compactRows;

  const _ResultsView({
    required this.phase,
    required this.tcpResults,
    required this.httpResults,
    required this.downloadResults,
    required this.selectedIps,
    required this.onIpSelected,
    required this.errorMessage,
    required this.onRetry,
    required this.onStop,
    required this.onSkipStage,
    required this.compactRows,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.error,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text('retry'.tr())),
          ],
        ),
      );
    }

    if (phase == 'idle') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.speed,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('cfIpSpeedTestDesc'.tr(), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final displayResults = downloadResults.isNotEmpty
        ? downloadResults
        : httpResults.isNotEmpty
        ? httpResults
        : tcpResults;
    if (displayResults.isEmpty && phase != 'tcp') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.wifi_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('No reachable IPs found', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Try disabling quick test mode or run again with a different network.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text('retry'.tr())),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      itemCount: displayResults.length,
      itemBuilder: (context, index) {
        final result = displayResults[index];
        final isSelected = selectedIps.contains(result.ip);
        final canSelect = selectedIps.length < 10 || isSelected;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: canSelect && phase == 'complete'
                  ? (_) => onIpSelected(result.ip)
                  : null,
            ),
            title: Text(
              result.ip,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${result.tcpPingMs}ms TCP'),
                if (result.httpPingMs != null)
                  Text(' · ${result.httpPingMs}ms HTTP'),
                if (result.colo != null) Text(' · ${result.colo}'),
                if (result.downloadSpeedMbps != null)
                  Text(
                    ' · ${result.downloadSpeedMbps!.toStringAsFixed(2)} MB/s',
                  ),
              ].expand((e) => [e]).toList(),
            ),
            trailing: Text(
              '#${index + 1}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            dense: compactRows,
            visualDensity: compactRows
                ? VisualDensity.compact
                : VisualDensity.standard,
          ),
        );
      },
    );
  }
}
