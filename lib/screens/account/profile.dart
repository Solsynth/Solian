import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'profile.g.dart';

@riverpod
Future<SnAccount> account(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/accounts/$uname");
  return SnAccount.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> accountBadges(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/accounts/$uname/badges");
  return List<SnAccountBadge>.from(
    resp.data.map((x) => SnAccountBadge.fromJson(x)),
  );
}

@RoutePage()
class AccountProfileScreen extends HookConsumerWidget {
  final String name;
  const AccountProfileScreen({
    super.key,
    @PathParam("name") required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(name));

    final iconShadow = Shadow(
      color: Colors.black54,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return account.when(
      data:
          (data) => AppScaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  leading: PageBackButton(shadows: [iconShadow]),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        data.profile.backgroundId != null
                            ? CloudImageWidget(
                              fileId: data.profile.backgroundId!,
                            )
                            : Container(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                    title: Text(
                      data.nick,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        shadows: [iconShadow],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      ProfilePictureWidget(
                        fileId: data.profile.pictureId!,
                        radius: 32,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Text(data.nick).fontSize(20),
                                Text(
                                  '@${data.name}',
                                ).fontSize(14).opacity(0.85),
                              ],
                            ),
                            AccountStatusWidget(
                              uname: name,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).padding(horizontal: 24, top: 24, bottom: 8),
                ),
                if (data.badges.isNotEmpty)
                  SliverToBoxAdapter(
                    child: BadgeList(
                      badges: data.badges,
                    ).padding(horizontal: 24, bottom: 24),
                  )
                else
                  const SliverGap(4),
                SliverToBoxAdapter(
                  child: LevelingProgressCard(
                    level: data.profile.level,
                    experience: data.profile.experience,
                    progress: data.profile.levelingProgress,
                  ).padding(horizontal: 20, bottom: 24),
                ),
                SliverToBoxAdapter(
                  child: const Divider(height: 1).padding(bottom: 24),
                ),
                if (data.profile.bio != null && data.profile.bio!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('bio').tr().bold(),
                        Text(data.profile.bio!),
                      ],
                    ).padding(horizontal: 24),
                  ),
              ],
            ),
          ),
      error:
          (error, stackTrace) => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: Text(error.toString())),
          ),
      loading:
          () => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
