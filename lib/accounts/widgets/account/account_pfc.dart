import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/badge.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/timezone/native.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class AccountProfileCard extends HookConsumerWidget {
  final String uname;
  const AccountProfileCard({super.key, required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(uname));
    final width = math
        .min(MediaQuery.of(context).size.width - 80, 360)
        .toDouble();

    final child = account.when(
      data: (data) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data.profile.background != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CloudImageWidget(file: data.profile.background),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    child: Badge(
                      isLabelVisible: true,
                      padding: EdgeInsets.all(2),
                      label: Icon(
                        Symbols.launch,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      offset: Offset(4, 28),
                      child: ProfilePictureWidget(file: data.profile.picture),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(AccountProfileRoute(name: data.name));
                    },
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AccountName(
                          account: data,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('@${data.name}').fontSize(12),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              AccountStatusWidget(uname: data.name, padding: EdgeInsets.zero),
              Tooltip(
                message: 'creditsStatus'.tr(),
                child: Row(
                  spacing: 6,
                  children: [
                    Icon(
                      Symbols.attribution,
                      size: 17,
                      fill: 1,
                    ).padding(right: 2),
                    Text(
                      '${data.profile.socialCredits.toStringAsFixed(2)} pts',
                    ).fontSize(12),
                    switch (data.profile.socialCreditsLevel) {
                      -1 => Text('socialCreditsLevelPoor').tr(),
                      0 => Text('socialCreditsLevelNormal').tr(),
                      1 => Text('socialCreditsLevelGood').tr(),
                      2 => Text('socialCreditsLevelExcellent').tr(),
                      _ => Text('unknown').tr(),
                    }.fontSize(12),
                  ],
                ),
              ),
              if (data.automatedId != null)
                Row(
                  spacing: 6,
                  children: [
                    Icon(
                      Symbols.smart_toy,
                      size: 17,
                      fill: 1,
                    ).padding(right: 2),
                    Text('accountAutomated').tr().fontSize(12),
                  ],
                ),
              if (data.profile.timeZone.isNotEmpty && !kIsWeb)
                () {
                  try {
                    final tzInfo = getTzInfo(data.profile.timeZone);
                    return Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Symbols.alarm,
                          size: 17,
                          fill: 1,
                        ).padding(right: 2),
                        Text(
                          tzInfo.$2.formatCustomGlobal('HH:mm'),
                        ).fontSize(12),
                        Text(tzInfo.$1.formatOffsetLocal()).fontSize(12),
                      ],
                    ).padding(top: 2);
                  } catch (e) {
                    return Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Symbols.alarm,
                          size: 17,
                          fill: 1,
                        ).padding(right: 2),
                        Text('timezoneNotFound'.tr()).fontSize(12),
                      ],
                    ).padding(top: 2);
                  }
                }(),
              Row(
                spacing: 6,
                children: [
                  Icon(Symbols.stairs, size: 17, fill: 1).padding(right: 2),
                  Text(
                    'levelingProgressLevel'.tr(
                      args: [data.profile.level.toString()],
                    ),
                  ).fontSize(12),
                  Expanded(
                    child: Tooltip(
                      message:
                          '${(data.profile.levelingProgress * 100).toStringAsFixed(2)}%',
                      child: LinearProgressIndicator(
                        value: data.profile.levelingProgress,
                        stopIndicatorRadius: 0,
                        trackGap: 0,
                        minHeight: 4,
                      ).padding(top: 1),
                    ),
                  ),
                ],
              ).padding(top: 2),
              if (data.badges.isNotEmpty)
                BadgeList(badges: data.badges).padding(top: 12),
              ActivityPresenceWidget(
                uname: uname,
                isCompact: true,
                compactPadding: const EdgeInsets.only(top: 12),
              ),
            ],
          ).padding(horizontal: 24, vertical: 16),
        ],
      ),
      error: (err, _) => ResponseErrorWidget(
        error: err,
        onRetry: () => ref.invalidate(accountProvider(uname)),
      ),
      loading: () => SizedBox(
        width: width,
        height: width,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ).center(),
      ),
    );

    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: width,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: child,
          ),
        ),
      ),
    );
  }
}

class AccountPfcRegion extends StatelessWidget {
  final String? uname;
  final Widget child;
  const AccountPfcRegion({super.key, required this.uname, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTapDown: (details) {
        if (uname != null) {
          showAccountProfileCard(
            context,
            uname!,
            offset: details.localPosition,
          );
        }
      },
    );
  }
}

bool _isShowingProfileCard = false;

Future<void> showAccountProfileCard(
  BuildContext context,
  String uname, {
  Offset? offset,
}) async {
  if (_isShowingProfileCard) return;
  _isShowingProfileCard = true;
  try {
    await showPopupCard<void>(
      offset: offset ?? Offset.zero,
      context: context,
      builder: (context) => AccountProfileCard(uname: uname),
      alignment: Alignment.center,
      dimBackground: true,
    );
  } finally {
    _isShowingProfileCard = false;
  }
}
