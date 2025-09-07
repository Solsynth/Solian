import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/auth/captcha.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:styled_widget/styled_widget.dart';

part 'check_in.g.dart';

@riverpod
Future<SnCheckInResult?> checkInResultToday(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final resp = await client.get('/id/accounts/me/check-in');
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
    final resp = await client.get('/id/notable/me/next');
    return SnNotableDay.fromJson(resp.data);
  } catch (err) {
    return null;
  }
}

class CheckInWidget extends HookConsumerWidget {
  final EdgeInsets? margin;
  final VoidCallback? onChecked;
  const CheckInWidget({super.key, this.margin, this.onChecked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);
    final nextNotableDay = ref.watch(nextNotableDayProvider);

    final userinfo = ref.watch(userInfoProvider);
    final isAdult = useMemoized(() {
      final birthday = userinfo.value?.profile.birthday;
      if (birthday == null) return false;
      final now = DateTime.now();
      final age =
          now.year -
          birthday.year -
          ((now.month < birthday.month ||
                  (now.month == birthday.month && now.day < birthday.day))
              ? 1
              : 0);
      return age >= 18;
    }, [userinfo]);

    Future<void> checkIn({String? captchatTk}) async {
      final client = ref.read(apiClientProvider);
      try {
        await client.post(
          '/id/accounts/me/check-in',
          data: captchatTk == null ? null : jsonEncode(captchatTk),
        );
        ref.invalidate(checkInResultTodayProvider);
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
        onChecked?.call();
      } catch (err) {
        if (err is DioException) {
          if (err.response?.statusCode == 423 && context.mounted) {
            final captchaTk = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => CaptchaScreen()));
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
                Row(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      switch (DateTime.now().weekday) {
                        6 || 7 => Symbols.weekend,
                        _ => isAdult ? Symbols.work : Symbols.school,
                      },
                      fill: 1,
                      size: 16,
                    ).padding(right: 2),
                    Text(DateFormat('EEE').format(DateTime.now()))
                        .fontSize(16)
                        .bold()
                        .textColor(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                    Text(DateFormat('MM/dd').format(DateTime.now()))
                        .fontSize(16)
                        .textColor(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                    Expanded(
                      child: AnimatedSwitcher(
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
                          loading:
                              () =>
                                  Text('checkInNone').tr().fontSize(15).bold(),
                          error:
                              (err, stack) =>
                                  Text('error').tr().fontSize(15).bold(),
                        ),
                      ).alignment(Alignment.centerLeft),
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Text('notableDayNext')
                        .tr(args: [nextNotableDay.value?.localName ?? 'idk'])
                        .fontSize(12),
                    if (nextNotableDay.value != null)
                      SlideCountdown(
                        decoration: const BoxDecoration(),
                        style: const TextStyle(fontSize: 12),
                        separatorStyle: const TextStyle(fontSize: 12),
                        padding: EdgeInsets.zero,
                        duration: nextNotableDay.value?.date.difference(
                          DateTime.now(),
                        ),
                      ),
                  ],
                ),
                const Gap(6),
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
                    error:
                        (err, stack) => Column(
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
          IconButton.outlined(
            onPressed: () {
              if (todayResult.valueOrNull == null) {
                checkIn();
              } else {
                context.pushNamed(
                  'accountCalendar',
                  pathParameters: {'name': 'me'},
                );
              }
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: todayResult.when(
                data:
                    (result) => Icon(
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
      ).padding(horizontal: 16, vertical: 12),
    );
  }
}

class CheckInActivityWidget extends StatelessWidget {
  final SnActivity item;
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
