import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/models/fortune.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/auth/captcha.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/account/event_calendar_content.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'check_in.g.dart';

@riverpod
Future<SnCheckInResult?> checkInResultToday(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final resp = await client.get('/pass/accounts/me/check-in');
    return SnCheckInResult.fromJson(resp.data);
  } catch (err) {
    if (err is DioException) {
      if (err.response?.statusCode == 404) {
        return null;
      }
    }
    rethrow;
  }
}

@riverpod
Future<SnNotableDay?> nextNotableDay(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final resp = await client.get('/pass/notable/me/next');
    final day = SnNotableDay.fromJson(resp.data);
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
  } catch (err) {
    return null;
  }
}

@riverpod
Future<SnNotableDay?> recentNotableDay(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final resp = await client.get('/pass/notable/me/recent');
    final day = SnNotableDay.fromJson(resp.data[0]);
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
  } catch (err) {
    return null;
  }
}

@riverpod
Future<SnFortuneSaying> randomFortuneSaying(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/pass/fortune/random');
  return SnFortuneSaying.fromJson(resp.data[0]);
}

class CheckInWidget extends HookConsumerWidget {
  final EdgeInsets? margin;
  final VoidCallback? onChecked;
  const CheckInWidget({super.key, this.margin, this.onChecked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);

    // Update time every second for live progress
    final currentTime = useState(DateTime.now());
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        currentTime.value = DateTime.now();
      });
      return timer.cancel;
    }, []);

    Future<void> checkIn({String? captchatTk}) async {
      final client = ref.read(apiClientProvider);
      try {
        await client.post(
          '/pass/accounts/me/check-in',
          data: captchatTk == null ? null : jsonEncode(captchatTk),
        );
        ref.invalidate(checkInResultTodayProvider);
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
        onChecked?.call();
      } catch (err) {
        if (err is DioException) {
          if (err.response?.statusCode == 423 && context.mounted) {
            final captchaTk = await CaptchaScreen.show(context);
            if (captchaTk == null) return;
            return await checkIn(captchatTk: captchaTk);
          }
        }
        showErrorAlert(err);
      }
    }

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
                      return Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children:
                            result.tips
                                .map((e) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        e.isPositive
                                            ? Symbols.thumb_up
                                            : Symbols.thumb_down,
                                        size: 12,
                                      ),
                                      const Gap(4),
                                      Text(e.title).fontSize(11),
                                    ],
                                  );
                                })
                                .toList()
                                .expand(
                                  (widget) => [
                                    widget,
                                    Text('  ·  ').fontSize(11),
                                  ],
                                )
                                .toList()
                              ..removeLast(),
                      );
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              IconButton.outlined(
                iconSize: 16,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -2,
                ),
                onPressed: () {
                  if (todayResult.value == null) {
                    checkIn();
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SheetScaffold(
                        titleText: 'eventCalendar'.tr(),
                        child: EventCalendarContent(name: 'me', isSheet: true),
                      ),
                    );
                  }
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) => Icon(
                      result == null
                          ? Symbols.local_fire_department
                          : Symbols.event,
                      key: ValueKey(result != null),
                    ),
                    loading: () => const Icon(Symbols.refresh),
                    error: (_, _) => const Icon(Symbols.error),
                  ),
                ),
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
        ProfilePictureWidget(
          fileId: result.account!.profile.picture?.id,
          radius: 12,
        ),
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
