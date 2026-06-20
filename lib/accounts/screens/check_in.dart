import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/widgets/account/fortune_graph.dart';
import 'package:island/auth/captcha.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:lunar/lunar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

TextStyle checkInSerif(
  BuildContext context, {
  TextStyle? base,
  FontWeight? fontWeight,
  double? height,
  Color? color,
}) {
  return (base ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
    fontWeight: fontWeight,
    height: height,
    color: color,
  );
}

String? checkInResultAsset(int level) {
  if (level < 0 || level > 4) return null;
  return 'assets/images/michan/check-in-result$level.webp';
}

Color checkInResultBackdrop(int level) {
  switch (level) {
    case 0:
      return const Color(0xFF7A587D);
    case 1:
      return const Color(0xFF79709C);
    case 2:
      return const Color(0xFF8DB7EF);
    case 3:
      return const Color(0xFFFEDE81);
    case 4:
      return const Color(0xFFE04A46);
    case 5:
      return const Color(0xFFFFB7C0);
    default:
      return const Color(0xFF8DB7EF);
  }
}

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

    return SheetScaffold(
      titleText: 'checkInTemple'.tr(),
      actions: [
        todayResult.when(
          data: (result) => result == null
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'share'.tr(),
                  onPressed: () {
                    shareCheckInAsScreenshot(context, ref, result);
                  },
                  icon: Icon(Symbols.share_reviews),
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const Gap(8),
      ],
      child: todayResult.when(
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

class _CheckInContent extends ConsumerWidget {
  final SnCheckInResult? result;
  final VoidCallback onCheckIn;

  const _CheckInContent({required this.result, required this.onCheckIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = result?.fortuneReport;
    final now = DateTime.now();

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
                    const Gap(24),
                    if (result == null)
                      _CheckInPrompt(onCheckIn: onCheckIn)
                    else
                      ...(() {
                        final checkInResult = result!;
                        return [
                          FortuneCard(
                            level: checkInResult.level,
                            createdAt: checkInResult.createdAt,
                            poem: report?.poem,
                            summary: report?.summary,
                          ),
                          if (report != null) ...[
                            const Gap(16),
                            FortuneGuidanceCard(report: report),
                            if (checkInResult.tips.isNotEmpty) ...[
                              const Gap(16),
                              FortuneTipsCard(tips: checkInResult.tips),
                            ],
                            const Gap(16),
                            FortuneLuckyGrid(report: report),
                            const Gap(16),
                            FortuneDetails(report: report),
                            const Gap(16),
                            FortuneActionCard(report: report),
                            const Gap(16),
                            FortuneRitualCard(report: report),
                            const Gap(16),
                            Card(
                              margin: EdgeInsets.zero,
                              child: FortuneGraphWidget(
                                events: ref.watch(
                                  eventCalendarProvider(
                                    EventCalendarQuery(
                                      uname: 'me',
                                      year: now.year,
                                      month: now.month,
                                    ),
                                  ),
                                ),
                                eventCalandarUser: 'me',
                              ),
                            ),
                          ] else
                            FallbackMessage(),
                        ];
                      })(),
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

class TempleHeader extends StatelessWidget {
  final DateTime date;

  const TempleHeader({super.key, required this.date});

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
          style: checkInSerif(
            context,
            base: theme.textTheme.headlineSmall,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(4),
        Text(
          DateFormat.yMMMMEEEEd().format(date),
          style: checkInSerif(
            context,
            base: theme.textTheme.bodyMedium,
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

class FortuneCard extends StatelessWidget {
  final int level;
  final DateTime? createdAt;
  final String? poem;
  final String? summary;
  final double? artHeight;
  final bool showSealHeader;

  const FortuneCard({
    super.key,
    required this.level,
    this.createdAt,
    this.poem,
    this.summary,
    this.artHeight,
    this.showSealHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = _getLevelColor(context, level);
    final artAsset = checkInResultAsset(level);
    final artBackdrop = checkInResultBackdrop(level);
    final lunarDate = createdAt != null ? Lunar.fromDate(createdAt!) : null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (artAsset != null) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: artBackdrop,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: artBackdrop.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (artHeight != null)
                          SizedBox(
                            height: artHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(artAsset, fit: BoxFit.contain),
                            ),
                          )
                        else
                          AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(artAsset, fit: BoxFit.contain),
                            ),
                          ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                                stops: const [0.55, 1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(18),
              ],
              if (showSealHeader)
                FortuneSealHeader(
                  level: level,
                  lunarDate: lunarDate,
                  levelColor: levelColor,
                ),
              if (poem?.isNotEmpty ?? false) ...[
                const Gap(8),
                Text(
                  poem!,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
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
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodyMedium,
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
    switch (level) {
      case 4:
        return const Color(0xFFC83B37);
      case 3:
        return const Color(0xFFB8871A);
      case 2:
        return const Color(0xFF447BC8);
      case 1:
        return const Color(0xFF5F5890);
      case 0:
        return const Color(0xFF69496C);
      case 5:
        return const Color(0xFFC85E74);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class FortuneDetails extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneDetails({super.key, required this.report});

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
              style: checkInSerif(
                context,
                base: theme.textTheme.titleMedium,
                fontWeight: FontWeight.w700,
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

class FortuneTipsCard extends StatelessWidget {
  final List<SnFortuneTip> tips;

  const FortuneTipsCard({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.tips_and_updates,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  'checkInFortuneTips'.tr(),
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(12),
            for (final tip in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      tip.isPositive ? Symbols.thumb_up : Symbols.thumb_down,
                      size: 16,
                      color: tip.isPositive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: checkInSerif(
                              context,
                              base: theme.textTheme.bodyMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            tip.content,
                            style: checkInSerif(
                              context,
                              base: theme.textTheme.bodySmall,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FortuneActionCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneActionCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.directions_run,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  'checkInFortuneActions'.tr(),
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ActionItem(
                    icon: Symbols.task_alt,
                    label: 'checkInFortuneLuckyAction'.tr(),
                    value: report.luckyAction,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: _ActionItem(
                    icon: Symbols.block,
                    label: 'checkInFortuneAvoidAction'.tr(),
                    value: report.avoidAction,
                    color: theme.colorScheme.error,
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

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            Icon(icon, size: 16, color: color),
            Text(
              label,
              style: checkInSerif(
                context,
                base: theme.textTheme.bodySmall,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Gap(4),
        Text(
          value,
          style: checkInSerif(
            context,
            base: theme.textTheme.bodyMedium,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class FortuneSealHeader extends StatelessWidget {
  final int level;
  final Lunar? lunarDate;
  final Color levelColor;

  const FortuneSealHeader({
    super.key,
    required this.level,
    required this.lunarDate,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lunarMonth = lunarDate?.getMonthInChinese() ?? '--';
    final lunarDay = lunarDate?.getDayInChinese() ?? '--';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '农\n历',
                style: checkInSerif(
                  context,
                  base: theme.textTheme.bodyMedium,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(10),
              Text(
                lunarMonth,
                style: checkInSerif(
                  context,
                  base: theme.textTheme.headlineMedium,
                  fontWeight: FontWeight.w900,
                  color: levelColor,
                ),
              ),
              const Gap(6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '月',
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w700,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'checkInResultLevel$level'.tr(),
              style: checkInSerif(
                context,
                base: theme.textTheme.headlineMedium,
                fontWeight: FontWeight.w900,
                color: levelColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lunarDay,
              style: checkInSerif(
                context,
                base: theme.textTheme.titleMedium,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FortuneGuidanceCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneGuidanceCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.menu_book,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  'checkInFortuneGuidance'.tr(),
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(12),
            if (report.summaryDetail != null)
              Text(
                report.summaryDetail!,
                style: checkInSerif(
                  context,
                  base: theme.textTheme.bodyMedium,
                  height: 1.75,
                  color: theme.colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FortuneLuckyGrid extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneLuckyGrid({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Symbols.palette, 'checkInFortuneLuckyColor'.tr(), report.luckyColor),
      (
        Symbols.explore,
        'checkInFortuneLuckyDirection'.tr(),
        report.luckyDirection,
      ),
      (Symbols.schedule, 'checkInFortuneLuckyTime'.tr(), report.luckyTime),
      (Symbols.key, 'checkInFortuneLuckyItem'.tr(), report.luckyItem),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 2 ? 2.8 : 3.6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.$1,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: checkInSerif(
                              context,
                              base: Theme.of(context).textTheme.bodySmall,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            item.$3,
                            style: checkInSerif(
                              context,
                              base: Theme.of(context).textTheme.bodyMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FortuneRitualCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneRitualCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.auto_fix_high,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  'checkInFortuneRitual'.tr(),
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              report.ritual,
              style: checkInSerif(
                context,
                base: theme.textTheme.bodyMedium,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
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
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodyMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FallbackMessage extends StatelessWidget {
  const FallbackMessage({super.key});

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/michan/checking-in.webp',
                    height: 168,
                    fit: BoxFit.contain,
                  ),
                  const Gap(18),
                  SizedBox(
                    width: 96,
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(999),
                      color: theme.colorScheme.primary,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const Gap(18),
                  Text(
                    'checkInTempleLoading'.tr(),
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.titleLarge,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    'checkInTempleLoadingHint'.tr(),
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.bodyMedium,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
