import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ConnectivitySelfCheckScreen extends HookConsumerWidget {
  const ConnectivitySelfCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final isRunning = useState(false);
    final results = useState<List<_SelfCheckResult>>([]);
    final errorMessage = useState<String?>(null);
    final mode = ref.watch(ipOverrideModeProvider);
    final settings = ref.watch(ipOverrideSettingsProvider);
    final domains = ref.watch(ipOverrideDomainsProvider);
    final serverUrl = ref.watch(serverUrlProvider);
    final serverUri = Uri.parse(serverUrl);

    final probeHosts = mode == IpOverrideMode.mixed
        ? domains.where((domain) => !domain.startsWith('.')).toList()
        : [serverUri.host];
    final canTestOverride =
        probeHosts.isNotEmpty &&
        settings.overrides.isNotEmpty &&
        mode != IpOverrideMode.off;

    Dio buildClient(
      String host, {
      IpOverrideConnectionFactory? connectionFactory,
    }) {
      final dio = Dio(
        BaseOptions(
          baseUrl:
              '${serverUri.scheme}://$host${serverUri.hasPort ? ':${serverUri.port}' : ''}',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          receiveDataWhenStatusError: true,
          validateStatus: (_) => true,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (connectionFactory != null) {
        dio.httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.connectionFactory = connectionFactory;
            return client;
          },
        );
      }

      return dio;
    }

    Future<_SelfCheckResult> runCheck({
      required String label,
      required Dio client,
    }) async {
      final stopwatch = Stopwatch()..start();
      try {
        final response = await client.get(
          '/',
          options: Options(validateStatus: (_) => true),
        );
        stopwatch.stop();
        final code = response.statusCode ?? 0;
        return _SelfCheckResult(
          label: label,
          isSuccess: true,
          statusCode: code,
          duration: stopwatch.elapsed,
          details: 'connectivitySelfCheckSuccess'.tr(),
        );
      } catch (err) {
        stopwatch.stop();
        return _SelfCheckResult(
          label: label,
          isSuccess:
              err is DioException &&
              err.type != DioExceptionType.connectionTimeout,
          duration: stopwatch.elapsed,
          details: err is DioException && err.error is SocketException
              ? (err.message ?? err.error?.toString() ?? err.toString())
              : err.toString(),
        );
      } finally {
        client.close(force: true);
      }
    }

    Future<_SelfCheckResult> runCheckAverage({
      required String label,
      required Dio Function() clientBuilder,
      int attempts = 3,
    }) async {
      final runs = <_SelfCheckResult>[];
      for (var i = 0; i < attempts; i++) {
        runs.add(await runCheck(label: label, client: clientBuilder()));
      }

      final successes = runs.where((run) => run.isSuccess).toList();
      final avgMs = successes.isEmpty
          ? null
          : (successes
                        .map((run) => run.duration.inMicroseconds)
                        .reduce((a, b) => a + b) /
                    successes.length) /
                1000.0;

      return _SelfCheckResult(
        label: label,
        isSuccess: successes.isNotEmpty,
        statusCode: runs.lastOrNull?.statusCode,
        duration: Duration(microseconds: (avgMs ?? 0).round() * 1000),
        details: 'connectivitySelfCheckAttempts'.tr(
          args: [
            successes.length.toString(),
            attempts.toString(),
            avgMs == null ? '-' : avgMs.toStringAsFixed(0),
          ],
        ),
        attempts: attempts,
        successCount: successes.length,
      );
    }

    Future<void> runSelfCheck() async {
      isRunning.value = true;
      errorMessage.value = null;

      try {
        final nextResults = <_SelfCheckResult>[];

        for (final host in probeHosts) {
          nextResults.add(
            await runCheckAverage(
              label: 'connectivitySelfCheckTarget'.tr(args: [host]),
              clientBuilder: () => buildClient(host),
            ),
          );
        }

        if (canTestOverride) {
          for (final host in probeHosts) {
            for (final override in settings.overrides) {
              nextResults.add(
                await runCheckAverage(
                  label: 'connectivitySelfCheckWithOverrideIp'.tr(
                    args: [
                      host,
                      override.port == null
                          ? override.ip
                          : '${override.ip}:${override.port}',
                    ],
                  ),
                  clientBuilder: () => buildClient(
                    host,
                    connectionFactory: createIpOverrideConnectionFactory(
                      domainSuffix: host,
                      ip: override.ip,
                      port: override.port,
                    ),
                  ),
                ),
              );
            }
          }
        }

        results.value = nextResults;
      } catch (err) {
        errorMessage.value = err.toString();
      } finally {
        isRunning.value = false;
      }
    }

    final overrideSummary = settings.overrides.isEmpty
        ? 'connectivitySelfCheckNoOverride'.tr()
        : settings.overrides
              .map(
                (entry) =>
                    entry.port == null ? entry.ip : '${entry.ip}:${entry.port}',
              )
              .join(', ');

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('connectivitySelfCheck').tr()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = isWide ? 1240.0 : constraints.maxWidth;
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: EdgeInsets.all(isWide ? 24 : 16),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          scheme.primaryContainer.withOpacity(0.75),
                          scheme.secondaryContainer.withOpacity(0.55),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: scheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 24 : 18),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 340,
                                  child: _OverviewPanel(
                                    isRunning: isRunning.value,
                                    canTestOverride: canTestOverride,
                                    probeHosts: probeHosts,
                                    overrideSummary: overrideSummary,
                                    onRun: runSelfCheck,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _ResultsSurface(
                                    errorMessage: errorMessage.value,
                                    canTestOverride: canTestOverride,
                                    results: results.value,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _OverviewPanel(
                                  isRunning: isRunning.value,
                                  canTestOverride: canTestOverride,
                                  probeHosts: probeHosts,
                                  overrideSummary: overrideSummary,
                                  onRun: runSelfCheck,
                                ),
                                const SizedBox(height: 16),
                                _ResultsSurface(
                                  errorMessage: errorMessage.value,
                                  canTestOverride: canTestOverride,
                                  results: results.value,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelfCheckResult {
  final String label;
  final bool isSuccess;
  final int? statusCode;
  final Duration duration;
  final String details;
  final int attempts;
  final int successCount;

  const _SelfCheckResult({
    required this.label,
    required this.isSuccess,
    required this.duration,
    required this.details,
    this.attempts = 1,
    this.successCount = 0,
    this.statusCode,
  });
}

class _SelfCheckResultCard extends StatelessWidget {
  final _SelfCheckResult result;

  const _SelfCheckResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isSuccess
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isSuccess ? Symbols.check_circle : Symbols.error,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'connectivitySelfCheckAvgDuration'.tr(
                args: [
                  result.successCount > 0
                      ? result.duration.inMilliseconds.toString()
                      : '-',
                ],
              ),
            ),
            Text(
              'connectivitySelfCheckAttempts'.tr(
                args: [
                  result.successCount.toString(),
                  result.attempts.toString(),
                  result.duration.inMilliseconds.toString(),
                ],
              ),
            ),
            if (result.statusCode != null) ...[
              const SizedBox(height: 4),
              Text(
                'connectivitySelfCheckStatus'.tr(
                  args: [result.statusCode.toString()],
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(result.details).opacity(0.85),
          ],
        ),
      ),
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  final bool isRunning;
  final bool canTestOverride;
  final List<String> probeHosts;
  final String overrideSummary;
  final VoidCallback onRun;

  const _OverviewPanel({
    required this.isRunning,
    required this.canTestOverride,
    required this.probeHosts,
    required this.overrideSummary,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.surface.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Symbols.health_and_safety),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'connectivitySelfCheck'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'connectivitySelfCheckSubtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              icon: Symbols.language,
              label: 'Server',
              value: probeHosts.join(', '),
            ),
            _StatusChip(
              icon: Symbols.dns,
              label: 'Override',
              value: overrideSummary,
            ),
            _StatusChip(
              icon: Symbols.toggle_on,
              label: 'Override check',
              value: canTestOverride ? 'Ready' : 'Unavailable',
              tone: canTestOverride ? _ChipTone.good : _ChipTone.warn,
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: isRunning ? null : onRun,
          icon: isRunning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Symbols.play_arrow),
          label: Text('connectivitySelfCheckRun'.tr()),
        ),
        const SizedBox(height: 16),
        Text(
          canTestOverride
              ? 'connectivitySelfCheckReadyHelper'.tr(
                  args: [probeHosts.join(', ')],
                )
              : 'connectivitySelfCheckUnavailableHelper'.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ResultsSurface extends StatelessWidget {
  final String? errorMessage;
  final bool canTestOverride;
  final List<_SelfCheckResult> results;

  const _ResultsSurface({
    required this.errorMessage,
    required this.canTestOverride,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (errorMessage != null) ...[
              Card(
                color: scheme.errorContainer,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(errorMessage!),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (!canTestOverride)
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Symbols.info),
                  title: Text('connectivitySelfCheckUnavailable'.tr()),
                  subtitle: Text('connectivitySelfCheckUnavailableHelper'.tr()),
                ),
              ),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.network_check,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'connectivitySelfCheckEmptyTitle'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'connectivitySelfCheckEmptyHelper'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final result in results)
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 1100
                          ? 360
                          : double.infinity,
                      child: _SelfCheckResultCard(result: result),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum _ChipTone { neutral, good, warn }

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _ChipTone tone;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    this.tone = _ChipTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = switch (tone) {
      _ChipTone.good => scheme.primaryContainer,
      _ChipTone.warn => scheme.tertiaryContainer,
      _ChipTone.neutral => scheme.surface.withOpacity(0.6),
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
