import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/event_calendar.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/color.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/fortune_graph.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'profile.g.dart';

@riverpod
Future<SnAccount> account(Ref ref, String uname) async {
  if (uname == 'me') {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo.hasValue && userInfo.value != null) {
      return userInfo.value!;
    }
  }
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

@riverpod
Future<Color?> accountAppbarForcegroundColor(Ref ref, String uname) async {
  final account = await ref.watch(accountProvider(uname).future);
  if (account.profile.background == null) return null;
  final palette = await PaletteGenerator.fromImageProvider(
    CloudImageWidget.provider(
      fileId: account.profile.background!.id,
      serverUrl: ref.watch(serverUrlProvider),
    ),
  );
  final dominantColor = palette.dominantColor?.color;
  if (dominantColor == null) return null;
  return dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
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
    final now = DateTime.now();

    final account = ref.watch(accountProvider(name));
    final accountEvents = ref.watch(
      eventCalendarProvider(
        EventCalendarQuery(uname: name, year: now.year, month: now.month),
      ),
    );
    final appbarColor = ref.watch(accountAppbarForcegroundColorProvider(name));

    final appbarShadow = Shadow(
      color: appbarColor.value?.invert ?? Colors.transparent,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return account.when(
      data:
          (data) => AppScaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  foregroundColor: appbarColor.value,
                  expandedHeight: 180,
                  pinned: true,
                  leading: PageBackButton(
                    color: appbarColor.value,
                    shadows: [appbarShadow],
                  ),
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            data.profile.background?.id != null
                                ? CloudImageWidget(
                                  file: data.profile.background,
                                )
                                : Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).appBarTheme.backgroundColor,
                                ),
                      ),
                      FlexibleSpaceBar(
                        title: Text(
                          data.nick,
                          style: TextStyle(
                            color:
                                appbarColor.value ??
                                Theme.of(context).appBarTheme.foregroundColor,
                            shadows: [appbarShadow],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfilePictureWidget(
                          file: data.profile.picture,
                          radius: 32,
                        ),
                        const Gap(20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(data.nick).fontSize(20),
                                  const Gap(6),
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
                    ),
                  ),
                ),
                if (data.badges.isNotEmpty)
                  SliverToBoxAdapter(
                    child: BadgeList(
                      badges: data.badges,
                    ).padding(horizontal: 24, bottom: 24),
                  ),
                SliverToBoxAdapter(
                  child: Column(
                    spacing: 12,
                    children: [
                      LevelingProgressCard(
                        level: data.profile.level,
                        experience: data.profile.experience,
                        progress: data.profile.levelingProgress,
                      ),
                      if (data.profile.verification != null)
                        VerificationStatusCard(
                          mark: data.profile.verification!,
                        ),
                    ],
                  ).padding(horizontal: 20),
                ),

                SliverToBoxAdapter(
                  child: const Divider(height: 1).padding(vertical: 24),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('bio').tr().bold(),
                      Text(
                        data.profile.bio.isEmpty
                            ? 'descriptionNone'.tr()
                            : data.profile.bio,
                      ),
                    ],
                  ).padding(horizontal: 24),
                ),

                SliverToBoxAdapter(
                  child: const Divider(height: 1).padding(top: 24),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      FortuneGraphWidget(
                        events: accountEvents,
                        eventCalanderUser: data.name,
                      ),
                    ],
                  ).padding(all: 8),
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
