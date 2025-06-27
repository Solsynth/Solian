import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/relationship.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/event_calendar.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/color.dart';
import 'package:island/services/time.dart';
import 'package:island/services/timezone/native.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/fortune_graph.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
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
  try {
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
  } catch (_) {
    return null;
  }
}

@riverpod
Future<SnChatRoom?> accountDirectChat(Ref ref, String uname) async {
  final account = await ref.watch(accountProvider(uname).future);
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get("/chat/direct/${account.id}");
    return SnChatRoom.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<SnRelationship?> accountRelationship(Ref ref, String uname) async {
  final account = await ref.watch(accountProvider(uname).future);
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get("/relationships/${account.id}");
    return SnRelationship.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

class AccountProfileScreen extends HookConsumerWidget {
  final String name;
  const AccountProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    final account = ref.watch(accountProvider(name));
    final accountEvents = ref.watch(
      eventCalendarProvider(
        EventCalendarQuery(uname: name, year: now.year, month: now.month),
      ),
    );
    final accountChat = ref.watch(accountDirectChatProvider(name));
    final accountRelationship = ref.watch(accountRelationshipProvider(name));

    final appbarColor = ref.watch(accountAppbarForcegroundColorProvider(name));

    final appbarShadow = Shadow(
      color: appbarColor.value?.invert ?? Colors.transparent,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    Future<void> relationshipAction() async {
      if (accountRelationship.value != null) return;
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        await client.post('/relationships/${account.value!.id}/friends');
        ref.invalidate(accountRelationshipProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> directMessageAction() async {
      if (!account.hasValue) return;
      if (accountChat.value != null) {
        context.push('/chat/${accountChat.value!.id}');
        return;
      }
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.post(
          '/chat/direct',
          data: {'related_user_id': account.value!.id},
        );
        final chat = SnChatRoom.fromJson(resp.data);
        if (context.mounted) context.push('/chat/${chat.id}');
        ref.invalidate(accountDirectChatProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    List<Widget> buildSubcolumn(SnAccount data) {
      return [
        if (data.profile.birthday != null)
          Row(
            spacing: 6,
            children: [
              const Icon(Symbols.cake, size: 17, fill: 1),
              Text(data.profile.birthday!.formatCustom('yyyy-MM-dd')),
              Text('·').bold(),
              Text(
                '${DateTime.now().difference(data.profile.birthday!).inDays ~/ 365} yrs old',
              ),
            ],
          ),
        if (data.profile.location.isNotEmpty)
          Row(
            spacing: 6,
            children: [
              const Icon(Symbols.location_on, size: 17, fill: 1),
              Text(data.profile.location),
            ],
          ),
        if (data.profile.pronouns.isNotEmpty || data.profile.gender.isNotEmpty)
          Row(
            spacing: 6,
            children: [
              const Icon(Symbols.person, size: 17, fill: 1),
              Text(
                data.profile.gender.isEmpty
                    ? 'unspecified'.tr()
                    : data.profile.gender,
              ),
              Text('·').bold(),
              Text(
                data.profile.pronouns.isEmpty
                    ? 'unspecified'.tr()
                    : data.profile.pronouns,
              ),
            ],
          ),
        if (data.profile.firstName.isNotEmpty ||
            data.profile.middleName.isNotEmpty ||
            data.profile.lastName.isNotEmpty)
          Row(
            spacing: 6,
            children: [
              const Icon(Symbols.id_card, size: 17, fill: 1),
              if (data.profile.firstName.isNotEmpty)
                Text(data.profile.firstName),
              if (data.profile.middleName.isNotEmpty)
                Text(data.profile.middleName),
              if (data.profile.lastName.isNotEmpty) Text(data.profile.lastName),
            ],
          ),
      ];
    }

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
                                  AccountName(
                                    account: data,
                                    style: TextStyle(fontSize: 20),
                                  ),
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
                    spacing: 24,
                    children: [
                      if (buildSubcolumn(data).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: buildSubcolumn(data),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('bio').tr().bold(),
                          Text(
                            data.profile.bio.isEmpty
                                ? 'descriptionNone'.tr()
                                : data.profile.bio,
                          ),
                        ],
                      ),
                      if (data.profile.timeZone.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('timeZone').tr().bold(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              spacing: 6,
                              children: [
                                Text(data.profile.timeZone),
                                Text(
                                  getTzInfo(
                                    data.profile.timeZone,
                                  ).$2.formatCustomGlobal('HH:mm'),
                                ),
                                Text(
                                  getTzInfo(
                                    data.profile.timeZone,
                                  ).$1.formatOffsetLocal(),
                                ).fontSize(11),
                                Text(
                                  'UTC${getTzInfo(data.profile.timeZone).$1.formatOffset()}',
                                ).fontSize(11).opacity(0.75),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ).padding(horizontal: 24),
                ),

                SliverToBoxAdapter(
                  child: const Divider(height: 1).padding(top: 24, bottom: 12),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              accountRelationship.value == null
                                  ? null
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              accountRelationship.value == null
                                  ? null
                                  : Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                          onPressed: relationshipAction,
                          label:
                              Text(
                                accountRelationship.value == null
                                    ? 'addFriendShort'
                                    : 'added',
                              ).tr(),
                          icon:
                              accountRelationship.value == null
                                  ? const Icon(Symbols.person_add)
                                  : const Icon(Symbols.person_check),
                        ),
                      ),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: directMessageAction,
                          icon: const Icon(Symbols.message),
                          label:
                              Text(
                                accountChat.value == null
                                    ? 'createDirectMessage'
                                    : 'gotoDirectMessage',
                                maxLines: 1,
                              ).tr(),
                        ),
                      ),
                    ],
                  ).padding(horizontal: 16),
                ),
                SliverToBoxAdapter(
                  child: const Divider(height: 1).padding(top: 12),
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
