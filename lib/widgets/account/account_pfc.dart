import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/account/profile.dart';
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
        math.max(MediaQuery.of(context).size.width - 80, 360).toDouble();
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
                          context.router.pushPath('/account/${data.name}');
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
    dimBackground: true,
  );
}
