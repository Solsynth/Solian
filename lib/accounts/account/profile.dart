import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_widgets/account/account_name.dart';
import 'package:island/accounts/accounts_widgets/account/activity_presence.dart';
import 'package:island/accounts/accounts_widgets/account/badge.dart';
import 'package:island/accounts/accounts_widgets/account/fortune_graph.dart';
import 'package:island/accounts/accounts_widgets/account/leveling_progress.dart';
import 'package:island/accounts/accounts_widgets/account/status.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/developers/developers_models/developer.dart';
import 'package:island/posts/posts_models/publisher.dart';
import 'package:island/accounts/accounts_models/relationship.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/core/services/color.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/timezone/native.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/markdown.dart';
import 'package:island/reports/reports_widgets/safety/abuse_report_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/services/color_extraction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'profile.g.dart';

class _AccountBasicInfo extends StatelessWidget {
  final SnAccount data;
  final String uname;
  final AsyncValue<SnDeveloper?> accountDeveloper;

  const _AccountBasicInfo({
    required this.data,
    required this.uname,
    required this.accountDeveloper,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Builder(
        builder: (context) {
          final hasBackground = data.profile.background != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWideScreen(context) && hasBackground)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: CloudImageWidget(
                          file: data.profile.background,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -24,
                      left: 16,
                      child: ProfilePictureWidget(
                        file: data.profile.picture,
                        radius: 32,
                      ),
                    ),
                  ],
                ),
              Builder(
                builder: (context) {
                  final showBackground = isWideScreen(context) && hasBackground;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: showBackground ? 0 : 20,
                    children: [
                      if (!showBackground)
                        ProfilePictureWidget(
                          file: data.profile.picture,
                          radius: 32,
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: AccountName(
                                    account: data,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isWideScreen(context))
                                  Flexible(
                                    child: Text(
                                      '@${data.name}',
                                    ).fontSize(11).padding(bottom: 2.5),
                                  ),
                              ],
                            ),
                            if (!isWideScreen(context))
                              Text(
                                '@${data.name}',
                              ).fontSize(11).padding(bottom: 2.5),
                            Text(
                              (data.profile.bio.isNotEmpty)
                                  ? data.profile.bio
                                  : 'descriptionNone'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (accountDeveloper.value != null)
                              Row(
                                spacing: 7,
                                children: [
                                  const Icon(Symbols.smart_toy, size: 18),
                                  Text(
                                    'botAutomatedBy'.tr(
                                      args: [
                                        accountDeveloper.value!.publisher!.nick,
                                      ],
                                    ),
                                  ).fontSize(13),
                                ],
                              ).opacity(0.75).padding(top: 4),
                            const Gap(4),
                            AccountStatusWidget(
                              uname: uname,
                              padding: EdgeInsets.zero,
                            ),
                            const Gap(8),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              uri: Uri.parse(
                                'https://solian.app/@${data.name}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Symbols.share),
                      ),
                    ],
                  ).padding(
                    left: 16,
                    right: 16,
                    top: 16 + (showBackground ? 16 : 0),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountProfileBio extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileBio({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
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
  }
}

class _AccountProfileDetail extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileDetail({required this.data});

  List<Widget> _buildSubcolumn() {
    return [
      Row(
        spacing: 6,
        children: [
          const Icon(Symbols.join, size: 17, fill: 1),
          Text(
            'joinedAt'.tr(args: [data.createdAt.formatCustom('yyyy-MM-dd')]),
          ),
        ],
      ),
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
            if (data.profile.firstName.isNotEmpty) Text(data.profile.firstName),
            if (data.profile.middleName.isNotEmpty)
              Text(data.profile.middleName),
            if (data.profile.lastName.isNotEmpty) Text(data.profile.lastName),
          ],
        ),
      Tooltip(
        message: 'creditsStatus'.tr(),
        child: Row(
          spacing: 6,
          children: [
            Icon(Symbols.attribution, size: 17, fill: 1).padding(right: 2),
            Text('${data.profile.socialCredits.toStringAsFixed(2)} pts'),
            Text('·').bold(),
            switch (data.profile.socialCreditsLevel) {
              -1 => Text('socialCreditsLevelPoor').tr(),
              0 => Text('socialCreditsLevelNormal').tr(),
              1 => Text('socialCreditsLevelGood').tr(),
              2 => Text('socialCreditsLevelExcellent').tr(),
              _ => Text('unknown').tr(),
            },
          ],
        ),
      ),
      InkWell(
        child: Row(
          spacing: 6,
          children: [
            Icon(Symbols.fingerprint, size: 17, fill: 1).padding(right: 2),
            Flexible(
              child: Text(
                data.id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: data.id));
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          if (_buildSubcolumn().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: _buildSubcolumn(),
            ),
          if (data.profile.timeZone.isNotEmpty && !kIsWeb)
            Builder(
              builder: (context) {
                try {
                  final tzInfo = getTzInfo(data.profile.timeZone);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('timeZone').tr().bold(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        spacing: 6,
                        children: [
                          Text(data.profile.timeZone),
                          Text(tzInfo.$2.formatCustomGlobal('HH:mm')),
                          Text(tzInfo.$1.formatOffsetLocal()).fontSize(11),
                          Text(
                            'UTC${tzInfo.$1.formatOffset()}',
                          ).fontSize(11).opacity(0.75),
                        ],
                      ),
                    ],
                  );
                } catch (e) {
                  // Hide timezone section if timezone is invalid
                  return const SizedBox.shrink();
                }
              },
            ),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );
  }
}

class _AccountProfileLinks extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileLinks({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('links').tr().bold().padding(horizontal: 24, top: 12, bottom: 4),
          for (final link in data.profile.links)
            ListTile(
              title: Text(link.name.capitalizeEachWord()),
              subtitle: Text(link.url),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              trailing: const Icon(Symbols.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              onTap: () {
                if (!link.url.startsWith('http') && !link.url.contains('://')) {
                  launchUrlString('https://${link.url}');
                } else {
                  launchUrlString(link.url);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _AccountProfileContacts extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileContacts({required this.data});

  @override
  Widget build(BuildContext context) {
    final publicContacts = data.contacts.where((c) => c.isPublic).toList();
    if (publicContacts.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'contactMethod',
          ).tr().bold().padding(horizontal: 24, top: 12, bottom: 4),
          for (final contact in publicContacts)
            ListTile(
              title: Text(contact.content),
              subtitle: Text(switch (contact.type) {
                0 => 'contactMethodTypeEmail'.tr(),
                1 => 'contactMethodTypePhone'.tr(),
                _ => 'contactMethodTypeAddress'.tr(),
              }),
              leading: Icon(switch (contact.type) {
                0 => Symbols.mail,
                1 => Symbols.phone,
                _ => Symbols.home,
              }),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              trailing: const Icon(Symbols.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              onTap: () {
                switch (contact.type) {
                  case 0:
                    launchUrlString('mailto:${contact.content}');
                  case 1:
                    launchUrlString('tel:${contact.content}');
                  default:
                    // For address, maybe copy to clipboard or do nothing
                    Clipboard.setData(ClipboardData(text: contact.content));
                }
              },
            ),
        ],
      ),
    );
  }
}

class _AccountPublisherList extends StatelessWidget {
  final List<SnPublisher> publishers;

  const _AccountPublisherList({required this.publishers});

  @override
  Widget build(BuildContext context) {
    if (publishers.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'publishers',
          ).tr().bold().padding(horizontal: 24, top: 12, bottom: 4),
          for (final publisher in publishers)
            ListTile(
              title: Text(publisher.nick),
              subtitle: Text(
                publisher.bio.isNotEmpty
                    ? publisher.bio
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .join('\n')
                    : 'descriptionNone'.tr(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              leading: ProfilePictureWidget(
                file: publisher.picture,
                borderRadius: publisher.type == 1 ? 8 : null,
              ),
              isThreeLine: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              trailing: const Icon(Symbols.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              onTap: () {
                Navigator.pop(context, true);
                context.pushNamed(
                  'publisherProfile',
                  pathParameters: {'name': publisher.name},
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  final SnAccount data;
  final AsyncValue<SnRelationship?> accountRelationship;
  final AsyncValue<SnChatRoom?> accountChat;
  final VoidCallback relationshipAction;
  final VoidCallback blockAction;
  final VoidCallback directMessageAction;

  const _AccountAction({
    required this.data,
    required this.accountRelationship,
    required this.accountChat,
    required this.relationshipAction,
    required this.blockAction,
    required this.directMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        spacing: 8,
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
                    label: Text(
                      accountRelationship.value == null
                          ? 'addFriendShort'
                          : 'added',
                    ).tr(),
                    icon: accountRelationship.value == null
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
                    label: Text(
                      accountRelationship.value == null
                          ? 'blockUser'
                          : 'unblockUser',
                    ).tr(),
                    icon: accountRelationship.value == null
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
                  label: Text(
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
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.error,
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

@riverpod
Future<SnAccount> account(Ref ref, String uname) async {
  if (uname == 'me') {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo.hasValue && userInfo.value != null) {
      return userInfo.value!;
    }
  }
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/pass/accounts/$uname");
  return SnAccount.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> accountBadges(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/pass/accounts/$uname/badges");
  return List<SnAccountBadge>.from(
    resp.data.map((x) => SnAccountBadge.fromJson(x)),
  );
}

@riverpod
Future<Color?> accountAppbarForcegroundColor(Ref ref, String uname) async {
  try {
    final account = await ref.watch(accountProvider(uname).future);
    if (account.profile.background == null) return null;
    final colors = await ColorExtractionService.getColorsFromImage(
      CloudImageWidget.provider(
        file: account.profile.background!,
        serverUrl: ref.watch(serverUrlProvider),
      ),
    );
    if (colors.isEmpty) return null;
    final dominantColor = colors.first;
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
    final resp = await apiClient.get("/messager/chat/direct/${account.id}");
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
    final resp = await apiClient.get("/pass/relationships/${account.id}");
    return SnRelationship.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<SnDeveloper?> accountBotDeveloper(Ref ref, String uname) async {
  final account = await ref.watch(accountProvider(uname).future);
  if (account.automatedId == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get(
      "/develop/bots/${account.automatedId}/developer",
    );
    return SnDeveloper.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<List<SnPublisher>> accountPublishers(Ref ref, String id) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get('/sphere/publishers/of/$id');
    return resp.data
        .map((e) => SnPublisher.fromJson(e))
        .cast<SnPublisher>()
        .toList();
  } catch (err) {
    return [];
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
    final accountDeveloper = ref.watch(accountBotDeveloperProvider(name));

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
        await client.post('/pass/relationships/${account.value!.id}/friends');
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
          await client.post('/pass/relationships/${account.value!.id}/block');
        } else {
          await client.delete('/pass/relationships/${account.value!.id}/block');
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
          '/messager/chat/direct',
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

    final user = ref.watch(userInfoProvider);
    final isCurrentUser = useMemoized(
      () => user.value?.id == account.value?.id,
      [user, account],
    );

    return account.when(
      data: (data) {
        final accountPublishers = ref.watch(accountPublishersProvider(data.id));
        return AppScaffold(
          isNoBackground: false,
          appBar: isWideScreen(context)
              ? AppBar(
                  foregroundColor: appbarColor.value,
                  leading: PageBackButton(
                    color: appbarColor.value,
                    shadows: [appbarShadow],
                  ),
                  title: Text(
                    data.nick,
                    style: TextStyle(
                      color:
                          appbarColor.value ??
                          Theme.of(context).appBarTheme.foregroundColor,
                      shadows: [appbarShadow],
                    ),
                  ),
                )
              : null,
          body: isWideScreen(context)
              ? Row(
                  children: [
                    Flexible(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _AccountBasicInfo(
                              data: data,
                              uname: name,
                              accountDeveloper: accountDeveloper,
                            ).padding(horizontal: 4, top: 20),
                          ),
                          if (data.badges.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Card(
                                child: BadgeList(
                                  badges: data.badges,
                                ).padding(horizontal: 26, vertical: 20),
                              ).padding(left: 2, right: 4),
                            ),
                          SliverToBoxAdapter(
                            child: Column(
                              spacing: 12,
                              children: [
                                LevelingProgressCard(
                                  level: data.profile.level,
                                  experience: data.profile.experience,
                                  progress: data.profile.levelingProgress,
                                ).padding(left: 2, right: 4),
                                if (data.profile.verification != null)
                                  Card(
                                    margin: EdgeInsets.zero,
                                    child: VerificationStatusCard(
                                      mark: data.profile.verification!,
                                    ),
                                  ),
                              ],
                            ).padding(horizontal: 4, top: 8),
                          ),
                          SliverToBoxAdapter(
                            child: _AccountProfileBio(
                              data: data,
                            ).padding(top: 4),
                          ),
                          if (data.profile.links.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _AccountProfileLinks(data: data),
                            ),
                          if (data.contacts.any((c) => c.isPublic))
                            SliverToBoxAdapter(
                              child: _AccountProfileContacts(data: data),
                            ),
                          SliverToBoxAdapter(
                            child: _AccountProfileDetail(data: data),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: CustomScrollView(
                        slivers: [
                          SliverGap(18),
                          SliverToBoxAdapter(
                            child: ActivityPresenceWidget(
                              uname: name,
                            ).padding(horizontal: 4, top: 4, bottom: 4),
                          ),
                          SliverToBoxAdapter(
                            child: _AccountPublisherList(
                              publishers: accountPublishers.value ?? [],
                            ),
                          ),
                          if (user.value != null && !isCurrentUser)
                            SliverToBoxAdapter(
                              child: _AccountAction(
                                data: data,
                                accountRelationship: accountRelationship,
                                accountChat: accountChat,
                                relationshipAction: relationshipAction,
                                blockAction: blockAction,
                                directMessageAction: directMessageAction,
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Card(
                              child: FortuneGraphWidget(
                                events: accountEvents,
                                eventCalandarUser: data.name,
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
                            child: data.profile.background != null
                                ? CloudImageWidget(
                                    file: data.profile.background,
                                  )
                                : Container(
                                    color: Theme.of(
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
                    SliverToBoxAdapter(
                      child: _AccountBasicInfo(
                        data: data,
                        uname: name,
                        accountDeveloper: accountDeveloper,
                      ).padding(horizontal: 4, top: 8),
                    ),
                    if (data.badges.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Card(
                          child: BadgeList(
                            badges: data.badges,
                          ).padding(horizontal: 26, vertical: 20),
                        ).padding(horizontal: 4),
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
                      child: _AccountProfileBio(
                        data: data,
                      ).padding(horizontal: 4),
                    ),
                    if (data.profile.links.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _AccountProfileLinks(
                          data: data,
                        ).padding(horizontal: 4),
                      ),
                    if (data.contacts.any((c) => c.isPublic))
                      SliverToBoxAdapter(
                        child: _AccountProfileContacts(
                          data: data,
                        ).padding(horizontal: 4),
                      ),
                    SliverToBoxAdapter(
                      child: ActivityPresenceWidget(
                        uname: name,
                      ).padding(horizontal: 8, top: 4, bottom: 4),
                    ),
                    SliverToBoxAdapter(
                      child: _AccountPublisherList(
                        publishers: accountPublishers.value ?? [],
                      ).padding(horizontal: 4),
                    ),
                    SliverToBoxAdapter(
                      child: _AccountProfileDetail(
                        data: data,
                      ).padding(horizontal: 4),
                    ),
                    if (user.value != null && !isCurrentUser)
                      SliverToBoxAdapter(
                        child: _AccountAction(
                          data: data,
                          accountRelationship: accountRelationship,
                          accountChat: accountChat,
                          relationshipAction: relationshipAction,
                          blockAction: blockAction,
                          directMessageAction: directMessageAction,
                        ).padding(horizontal: 4),
                      ),
                    SliverToBoxAdapter(
                      child: Card(
                        child: FortuneGraphWidget(
                          events: accountEvents,
                          eventCalandarUser: data.name,
                        ),
                      ).padding(horizontal: 4),
                    ),
                  ],
                ),
        );
      },
      error: (error, stackTrace) => AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: Center(child: Text(error.toString())),
      ),
      loading: () => AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
