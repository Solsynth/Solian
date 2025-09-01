import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/services/time.dart';
import 'package:island/services/timezone/native.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class AccountProfileCard extends HookConsumerWidget {
  final String uname;
  const AccountProfileCard({super.key, required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(uname));
    final width =
        math.min(MediaQuery.of(context).size.width - 80, 360).toDouble();
    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        width: width,
        child: account.when(
          data:
              (data) => Column(
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
                          ProfilePictureWidget(file: data.profile.picture),
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
                      AccountStatusWidget(
                        uname: data.name,
                        padding: EdgeInsets.zero,
                      ),
                      Tooltip(
                        message: 'creditsStatus'.tr(),
                        child: Row(
                          spacing: 6,
                          children: [
                            Icon(
                              Symbols.star,
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
                                Text(
                                  tzInfo.$1.formatOffsetLocal(),
                                ).fontSize(12),
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
                      if (data.badges.isNotEmpty)
                        BadgeList(badges: data.badges).padding(top: 12),
                      LevelingProgressCard(
                        level: data.profile.level,
                        experience: data.profile.experience,
                        progress: data.profile.levelingProgress,
                      ).padding(top: 12),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.pushNamed(
                            'accountProfile',
                            pathParameters: {'name': data.name},
                          );
                        },
                        icon: const Icon(Symbols.launch),
                        label: Text('accountProfileView').tr(),
                      ).padding(top: 12, horizontal: 2),
                    ],
                  ).padding(horizontal: 24, vertical: 16),
                ],
              ),
          error:
              (err, _) => ResponseErrorWidget(
                error: err,
                onRetry: () => ref.invalidate(accountProvider(uname)),
              ),
          loading:
              () => SizedBox(
                width: width,
                height: width,
                child:
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ).center(),
              ),
        ),
      ),
    );
  }
}

class AccountPfcGestureDetector extends StatelessWidget {
  final String uname;
  final Widget child;
  const AccountPfcGestureDetector({
    super.key,
    required this.uname,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTapDown: (details) {
        showAccountProfileCard(context, uname, offset: details.localPosition);
      },
    );
  }
}

Future<void> showAccountProfileCard(
  BuildContext context,
  String uname, {
  Offset? offset,
}) async {
  await showPopupCard<void>(
    offset: offset ?? Offset.zero,
    context: context,
    builder: (context) => AccountProfileCard(uname: uname),
    alignment: Alignment.center,
    dimBackground: true,
  );
}
