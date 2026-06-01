import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'check_in.g.dart';

@riverpod
Future<SnCheckInResult?> checkInResultToday(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getCheckInResultToday();
}

@riverpod
Future<SnNotableDay?> nextNotableDay(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final day = await client.accounts.getNextNotableDay();
  if (day == null) return null;

  if (day.localizableKey != null) {
    final key = 'notableDay${day.localizableKey}';
    if (key.trExists()) {
      return day.copyWith(
        localName: key.tr(),
        date: day.date.toLocal().copyWith(hour: 0, second: 0),
      );
    }
  }
  return day.copyWith(date: day.date.toLocal().copyWith(hour: 0, second: 0));
}

@riverpod
Future<SnNotableDay?> recentNotableDay(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final day = await client.accounts.getRecentNotableDay();
  if (day == null) return null;

  if (day.localizableKey != null) {
    final key = 'notableDay${day.localizableKey}';
    if (key.trExists()) {
      return day.copyWith(
        localName: key.tr(),
        date: day.date.toLocal().copyWith(hour: 0, second: 0),
      );
    }
  }
  return day.copyWith(date: day.date.toLocal().copyWith(hour: 0, second: 0));
}

@riverpod
Future<SnFortuneSaying> randomFortuneSaying(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getRandomFortuneSaying();
}

class CheckInWidget extends ConsumerWidget {
  final EdgeInsets? margin;
  final VoidCallback? onChecked;
  const CheckInWidget({super.key, this.margin, this.onChecked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);

    return Card(
      margin:
          margin ?? EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) {
                      return Text(
                        result == null
                            ? 'checkInNone'
                            : 'checkInResultLevel${result.level}',
                        textAlign: TextAlign.start,
                      ).tr().fontSize(15).bold();
                    },
                    loading: () => Text('checkInNone').tr().fontSize(15).bold(),
                    error: (err, stack) =>
                        Text('error').tr().fontSize(15).bold(),
                  ),
                ).padding(right: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) {
                      if (result == null) {
                        return Text('checkInNoneHint').tr().fontSize(11);
                      }
                      final report = result.fortuneReport;
                      return Text(
                        report?.summary ??
                            report?.poem ??
                            'checkInViewTemple'.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).fontSize(11);
                    },
                    loading: () => Text('checkInNoneHint').tr().fontSize(11),
                    error: (err, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('error').tr().fontSize(15).bold(),
                        Text(err.toString()).fontSize(11),
                      ],
                    ),
                  ),
                ).alignment(Alignment.centerLeft),
              ],
            ),
          ),
          Row(
            spacing: 8,
            children: [
              IconButton.outlined(
                iconSize: 16,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -2,
                ),
                onPressed: () {
                  context.router.push(const CheckInRoute());
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) => Icon(
                      result == null
                          ? Symbols.local_fire_department
                          : Symbols.temple_buddhist,
                      key: ValueKey(result != null),
                    ),
                    loading: () => const Icon(Symbols.refresh),
                    error: (_, _) => const Icon(Symbols.error),
                  ),
                ),
              ),
              IconButton.outlined(
                iconSize: 16,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -2,
                ),
                onPressed: () {
                  context.router.push(EventHubRoute(name: 'me'));
                },
                icon: const Icon(Symbols.event),
              ),
            ],
          ),
        ],
      ).padding(horizontal: 16, vertical: 12),
    );
  }
}

class CheckInActivityWidget extends StatelessWidget {
  final SnTimelineEvent item;
  const CheckInActivityWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final result = SnCheckInResult.fromJson(item.data);
    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePictureWidget(file: result.account!.profile.picture, radius: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Symbols.local_fire_department, size: 14),
                  const Gap(4),
                  Text('checkIn').fontSize(11).tr(),
                ],
              ).opacity(0.85),
              Text('checkInActivityTitle')
                  .tr(
                    args: [
                      result.account!.nick,
                      DateFormat.yMd().format(result.createdAt),
                      'checkInResultLevel${result.level}'.tr(),
                    ],
                  )
                  .fontSize(13)
                  .padding(left: 2),
            ],
          ),
        ),
      ],
    ).padding(horizontal: 16, vertical: 12);
  }
}
