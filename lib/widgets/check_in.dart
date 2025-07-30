import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

class CheckInWidget extends HookConsumerWidget {
  final EdgeInsets? margin;
  const CheckInWidget({super.key, this.margin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);

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
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              width: 56,
              height: 56,
              child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(DateFormat('EEE').format(DateTime.now()))
                          .fontSize(16)
                          .bold()
                          .textColor(
                            Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                      Text(DateFormat('MM/dd').format(DateTime.now()))
                          .fontSize(12)
                          .textColor(
                            Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                    ],
                  ).center(),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: todayResult.when(
                data: (result) {
                  if (result == null) return _CheckInNoneWidget();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'checkInResultLevel${result.level}',
                      ).tr().fontSize(15).bold(),
                      Text(
                        result.tips
                            .map(
                              (e) => '${e.isPositive ? '宜' : '忌'} ${e.title}',
                            )
                            .join('  ·  '),
                      ).fontSize(11),
                    ],
                  );
                },
                loading: () => _CheckInNoneWidget(),
                error:
                    (err, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('error').tr().fontSize(15).bold(),
                        Text(err.toString()).fontSize(11),
                      ],
                    ),
              ),
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

class _CheckInNoneWidget extends StatelessWidget {
  const _CheckInNoneWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('checkInNone').tr().fontSize(15).bold(),
        Text('checkInNoneHint').tr().fontSize(11),
      ],
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
