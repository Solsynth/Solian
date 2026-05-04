import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/auth/captcha.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class CheckInScreen extends HookConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);
    final isCheckingIn = useState(false);

    Future<void> checkIn({String? captchaTk}) async {
      final client = ref.read(solarNetworkClientProvider);
      isCheckingIn.value = true;
      try {
        await client.accounts.checkIn(captchaToken: captchaTk);
        ref.invalidate(checkInResultTodayProvider);
        await ref.read(userInfoProvider.notifier).fetchUser();
      } catch (err) {
        if (err is DioException &&
            err.response?.statusCode == 423 &&
            context.mounted) {
          final nextCaptchaTk = await CaptchaScreen.show(context);
          if (nextCaptchaTk == null) return;
          return await checkIn(captchaTk: nextCaptchaTk);
        }
        showErrorAlert(err);
      } finally {
        isCheckingIn.value = false;
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('checkInTemple').tr(), centerTitle: true),
      body: todayResult.when(
        data: (result) => Stack(
          children: [
            _CheckInContent(result: result, onCheckIn: () => checkIn()),
            if (isCheckingIn.value)
              ColoredBox(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                child: _CheckInLoadingOverlay(),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Icon(
                  Symbols.error,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                Text('error').tr().fontSize(16).bold(),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInContent extends StatelessWidget {
  final SnCheckInResult? result;
  final VoidCallback onCheckIn;

  const _CheckInContent({required this.result, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final report = result?.fortuneReport;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TempleHeader(date: DateTime.now()),
                    const Gap(24),
                    if (result == null)
                      _CheckInPrompt(onCheckIn: onCheckIn)
                    else ...[
                      _FortuneCard(
                        level: result!.level,
                        poem: report?.poem,
                        summary: report?.summary,
                      ),
                      if (report != null) ...[
                        const Gap(16),
                        _FortuneDetails(report: report),
                      ] else
                        _FallbackMessage(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempleHeader extends StatelessWidget {
  final DateTime date;

  const _TempleHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Symbols.temple_buddhist,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const Gap(12),
        Text(
          'checkInTempleTitle'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(4),
        Text(
          DateFormat.yMMMMEEEEd().format(date),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CheckInPrompt extends StatelessWidget {
  final VoidCallback onCheckIn;

  const _CheckInPrompt({required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Symbols.local_fire_department,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const Gap(16),
            Text(
              'checkInNone'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'checkInTempleHint'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: onCheckIn,
              icon: const Icon(Symbols.auto_awesome),
              label: Text('checkInDrawToday'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FortuneCard extends StatelessWidget {
  final int level;
  final String? poem;
  final String? summary;

  const _FortuneCard({required this.level, this.poem, this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = _getLevelColor(context, level);

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              levelColor.withValues(alpha: 0.1),
              levelColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  'checkInResultLevel$level'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: levelColor,
                  ),
                ),
              ),
              if (poem?.isNotEmpty ?? false) ...[
                const Gap(20),
                Text(
                  poem!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (summary?.isNotEmpty ?? false) ...[
                const Gap(16),
                Text(
                  summary!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(BuildContext context, int level) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (level) {
      case 4:
        return Colors.amber;
      case 3:
        return Colors.green;
      case 2:
        return colorScheme.primary;
      case 1:
        return Colors.orange;
      case 0:
        return Colors.red;
      case 5:
        return Colors.pink;
      default:
        return colorScheme.primary;
    }
  }
}

class _FortuneDetails extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const _FortuneDetails({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(
              Symbols.auto_awesome,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            Text(
              'fortuneDetails'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(12),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _FortuneItem(
                icon: Symbols.volunteer_activism,
                label: 'checkInFortuneWish'.tr(),
                value: report.wish,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.favorite,
                label: 'checkInFortuneLove'.tr(),
                value: report.love,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.school,
                label: 'checkInFortuneStudy'.tr(),
                value: report.study,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.work,
                label: 'checkInFortuneCareer'.tr(),
                value: report.career,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.spa,
                label: 'checkInFortuneHealth'.tr(),
                value: report.health,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.travel_explore,
                label: 'checkInFortuneLostItem'.tr(),
                value: report.lostItem,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FortuneItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FortuneItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(4),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Icon(
                Symbols.info,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              Expanded(
                child: Text(
                  'checkInReportPending'.tr(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInLoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                  Icon(
                    Symbols.temple_buddhist,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const Gap(20),
            Text(
              'checkInTempleLoading'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'checkInTempleLoadingHint'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
