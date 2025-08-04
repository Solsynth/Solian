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
import 'package:island/services/responsive.dart';
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
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/safety/abuse_report_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
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
  final resp = await apiClient.get("/id/accounts/$uname");
  return SnAccount.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> accountBadges(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/id/accounts/$uname/badges");
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
  final userInfo = ref.watch(userInfoProvider);
  if (userInfo.value == null) return null;
  final account = await ref.watch(accountProvider(uname).future);
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get("/sphere/chat/direct/${account.id}");
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
  final userInfo = ref.watch(userInfoProvider);
  if (userInfo.value == null) return null;
  final account = await ref.watch(accountProvider(uname).future);
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get("/id/relationships/${account.id}");
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
        await client.post('/id/relationships/${account.value!.id}/friends');
        ref.invalidate(accountRelationshipProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> blockAction() async {
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        if (accountRelationship.value == null) {
          await client.post('/id/relationships/${account.value!.id}/block');
        } else {
          await client.delete('/id/relationships/${account.value!.id}/block');
        }
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
        context.pushNamed(
          'chatRoom',
          pathParameters: {'id': accountChat.value!.id},
        );
        return;
      }
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.post(
          '/sphere/chat/direct',
          data: {'related_user_id': account.value!.id},
        );
        final chat = SnChatRoom.fromJson(resp.data);
        if (context.mounted) {
          context.pushNamed('chatRoom', pathParameters: {'id': chat.id});
        }
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

    final user = ref.watch(userInfoProvider);

    Widget accountBasicInfo(SnAccount data) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfilePictureWidget(file: data.profile.picture, radius: 32),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AccountName(account: data, style: TextStyle(fontSize: 20)),
                    const Gap(6),
                    Flexible(
                      child: Text(
                        '@${data.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).fontSize(14).opacity(0.85),
                    ),
                  ],
                ),
                AccountStatusWidget(uname: name, padding: EdgeInsets.zero),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  uri: Uri.parse('https://id.solian.app/@${data.name}'),
                ),
              );
            },
            icon: const Icon(Symbols.share),
          ),
        ],
      ),
    );

    Widget accountProfileBio(SnAccount data) => Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('bio').tr().bold().fontSize(15).padding(bottom: 8),
          if (data.profile.bio.isEmpty)
            Text('descriptionNone').tr().italic()
          else
            MarkdownTextContent(
              content: data.profile.bio,
              linesMargin: EdgeInsets.zero,
            ),
        ],
      ).padding(horizontal: 24, vertical: 20),
    );

    Widget accountProfileDetail(SnAccount data) => Card(
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
                      getTzInfo(data.profile.timeZone).$1.formatOffsetLocal(),
                    ).fontSize(11),
                    Text(
                      'UTC${getTzInfo(data.profile.timeZone).$1.formatOffset()}',
                    ).fontSize(11).opacity(0.75),
                  ],
                ),
              ],
            ),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );

    Widget accountAction(SnAccount data) => Card(
      child: Column(
        children: [
          Row(
            spacing: 8,
            children: [
              if (accountRelationship.value == null ||
                  accountRelationship.value!.status > -100)
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
              if (accountRelationship.value == null ||
                  accountRelationship.value!.status <= -100)
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
                    onPressed: blockAction,
                    label:
                        Text(
                          accountRelationship.value == null
                              ? 'blockUser'
                              : 'unblockUser',
                        ).tr(),
                    icon:
                        accountRelationship.value == null
                            ? const Icon(Symbols.block)
                            : const Icon(Symbols.person_cancel),
                  ),
                ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
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
              IconButton.filled(
                onPressed: () {
                  showAbuseReportSheet(
                    context,
                    resourceIdentifier: 'account/${data.id}',
                  );
                },
                icon: Icon(
                  Symbols.flag,
                  color: Theme.of(context).colorScheme.onError,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ).padding(horizontal: 16, vertical: 8),
    );

    return account.when(
      data:
          (data) => AppScaffold(
            isNoBackground: false,
            appBar:
                isWideScreen(context)
                    ? AppBar(
                      foregroundColor: appbarColor.value,
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
                                    Theme.of(
                                      context,
                                    ).appBarTheme.foregroundColor,
                                shadows: [appbarShadow],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : null,
            body:
                isWideScreen(context)
                    ? Row(
                      children: [
                        Flexible(
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(child: accountBasicInfo(data)),
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
                                      Card(
                                        child: VerificationStatusCard(
                                          mark: data.profile.verification!,
                                        ),
                                      ),
                                  ],
                                ).padding(horizontal: 4, top: 8),
                              ),
                              SliverToBoxAdapter(
                                child: accountProfileBio(data).padding(top: 4),
                              ),
                              SliverToBoxAdapter(
                                child: accountProfileDetail(data),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: CustomScrollView(
                            slivers: [
                              SliverGap(24),
                              if (user.value != null)
                                SliverToBoxAdapter(child: accountAction(data)),
                              SliverToBoxAdapter(
                                child: Card(
                                  child: FortuneGraphWidget(
                                    events: accountEvents,
                                    eventCalanderUser: data.name,
                                    margin: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).padding(horizontal: 24)
                    : CustomScrollView(
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
                                        Theme.of(
                                          context,
                                        ).appBarTheme.foregroundColor,
                                    shadows: [appbarShadow],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(child: accountBasicInfo(data)),
                        if (data.badges.isNotEmpty)
                          SliverToBoxAdapter(
                            child: BadgeList(
                              badges: data.badges,
                            ).padding(horizontal: 24, bottom: 24),
                          ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              LevelingProgressCard(
                                level: data.profile.level,
                                experience: data.profile.experience,
                                progress: data.profile.levelingProgress,
                              ).padding(top: 8, horizontal: 8, bottom: 4),
                              if (data.profile.verification != null)
                                Card(
                                  child: VerificationStatusCard(
                                    mark: data.profile.verification!,
                                  ),
                                ).padding(horizontal: 4),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: accountProfileBio(data).padding(horizontal: 4),
                        ),
                        SliverToBoxAdapter(
                          child: accountProfileDetail(
                            data,
                          ).padding(horizontal: 4),
                        ),
                        if (user.value != null)
                          SliverToBoxAdapter(
                            child: accountAction(data).padding(horizontal: 4),
                          ),
                        SliverToBoxAdapter(
                          child: Card(
                            child: FortuneGraphWidget(
                              events: accountEvents,
                              eventCalanderUser: data.name,
                            ),
                          ).padding(horizontal: 4),
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
