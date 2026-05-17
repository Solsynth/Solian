import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network/cf_ip_speed_test.dart';
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
    StreamSubscription<CfIpTestProgress>? subscription;

    useEffect(() {
      return () {
        subscription?.cancel();
      };
    }, []);

    void startTest() {
      phase.value = 'tcp';
      isRunning.value = true;
      errorMessage.value = null;
      tcpResults.value = [];
      httpResults.value = [];
      downloadResults.value = [];
      selectedIps.value = {};

      subscription = runCfIpSpeedTest(
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
      ).listen(
        (event) {
          switch (event) {
            case CfIpTcpPingProgress p:
              phase.value = 'tcp';
              progress.value = p.phase;
              availableCount.value = p.availableCount;
              currentIp.value = p.currentIp;
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
            case CfIpTestError e:
              phase.value = 'error';
              isRunning.value = false;
              errorMessage.value = e.message;
              subscription?.cancel();
          }
        },
        onError: (err) {
          phase.value = 'error';
          isRunning.value = false;
          errorMessage.value = err.toString();
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
      body: Column(
        children: [
          _ProgressBar(
            phase: phase.value,
            progress: progress.value,
            availableCount: availableCount.value,
            currentIp: currentIp.value,
            isRunning: isRunning.value,
            quickTest: quickTest.value,
            onQuickTestChanged: (value) => quickTest.value = value,
            onStart: startTest,
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
            ),
          ),
        ],
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
  final VoidCallback onStart;

  const _ProgressBar({
    required this.phase,
    required this.progress,
    required this.availableCount,
    required this.currentIp,
    required this.isRunning,
    required this.quickTest,
    required this.onQuickTestChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isRunning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                Text(
                  phase == 'tcp'
                      ? 'phaseTcpPing'.tr()
                      : phase == 'http'
                          ? 'phaseHttpPing'.tr()
                          : phase == 'download'
                              ? 'phaseDownload'.tr()
                              : phase == 'complete'
                                  ? 'phaseComplete'.tr()
                                  : '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress!.total > 0 ? progress!.current / progress!.total : 0,
              ),
              const SizedBox(height: 4),
              Text(
                '${progress!.current}/${progress!.total} ${'ipsTested'.tr()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (currentIp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'testingIp'.tr(args: [currentIp!]),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (phase == 'tcp')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${'available'.tr()}: $availableCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            if (phase == 'idle' || phase == 'complete') ...[
              if (phase == 'idle')
                SwitchListTile(
                  title: Text('quickTestMode'.tr()),
                  subtitle: Text(quickTest ? 'quickTestOn'.tr() : 'quickTestOff'.tr()),
                  value: quickTest,
                  onChanged: onQuickTestChanged,
                  contentPadding: EdgeInsets.zero,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  onPressed: isRunning ? null : onStart,
                  icon: const Icon(Symbols.play_arrow),
                  label: Text(phase == 'complete' ? 'testAgain'.tr() : 'startTest'.tr()),
                ),
              ),
            ],
          ],
        ),
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

  const _ResultsView({
    required this.phase,
    required this.tcpResults,
    required this.httpResults,
    required this.downloadResults,
    required this.selectedIps,
    required this.onIpSelected,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.error, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(errorMessage!),
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
            Icon(Symbols.speed, size: 64, color: Theme.of(context).colorScheme.primary),
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
      return Center(child: Text('noResults'.tr()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
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
              children: [
                Text('${result.tcpPingMs}ms TCP'),
                if (result.httpPingMs != null)
                  Text(' · ${result.httpPingMs}ms HTTP'),
                if (result.colo != null)
                  Text(' · ${result.colo}'),
                if (result.downloadSpeedMbps != null)
                  Text(' · ${result.downloadSpeedMbps!.toStringAsFixed(2)} MB/s'),
              ].expand((e) => [e]).toList(),
            ),
            trailing: Text(
              '#${index + 1}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}
