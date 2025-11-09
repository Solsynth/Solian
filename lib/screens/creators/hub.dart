import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/publisher.dart';
import 'package:island/models/heatmap.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers_form.dart';
import 'package:island/services/responsive.dart';
import 'package:island/utils/text.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:island/widgets/activity_heatmap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'hub.g.dart';

@riverpod
Future<SnPublisherStats?> publisherStats(Ref ref, String? uname) async {
  if (uname == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/publishers/$uname/stats');
  return SnPublisherStats.fromJson(resp.data);
}

@riverpod
Future<SnHeatmap?> publisherHeatmap(Ref ref, String? uname) async {
  if (uname == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/publishers/$uname/heatmap');
  return SnHeatmap.fromJson(resp.data);
}

@riverpod
Future<SnPublisherMember?> publisherIdentity(Ref ref, String uname) async {
  try {
    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.get(
      '/sphere/publishers/$uname/members/me',
    );
    return SnPublisherMember.fromJson(response.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null; // No identity found, user is not a member
    }
    rethrow;
  }
}

@riverpod
Future<Map<String, bool>> publisherFeatures(Ref ref, String? uname) async {
  if (uname == null) return {};
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/sphere/publishers/$uname/features');
  return Map<String, bool>.from(response.data);
}

@riverpod
Future<List<SnPublisherMember>> publisherInvites(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/publishers/invites');
  return resp.data
      .map((e) => SnPublisherMember.fromJson(e))
      .cast<SnPublisherMember>()
      .toList();
}

@riverpod
class PublisherMemberListNotifier extends _$PublisherMemberListNotifier
    with CursorPagingNotifierMixin<SnPublisherMember> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPublisherMember>> build(String uname) async {
    return fetch();
  }

  @override
  Future<CursorPagingData<SnPublisherMember>> fetch({String? cursor}) async {
    final apiClient = ref.read(apiClientProvider);
    final offset = cursor != null ? int.parse(cursor) : 0;

    final response = await apiClient.get(
      '/sphere/publishers/$uname/members',
      queryParameters: {'offset': offset, 'take': _pageSize},
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final members = data.map((e) => SnPublisherMember.fromJson(e)).toList();

    final hasMore = offset + members.length < total;
    final nextCursor = hasMore ? (offset + members.length).toString() : null;

    return CursorPagingData(
      items: members,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class PublisherSelector extends StatelessWidget {
  final SnPublisher? currentPublisher;
  final List<DropdownMenuItem<SnPublisher>> publishersMenu;
  final ValueChanged<SnPublisher?>? onChanged;
  final bool isReadOnly;

  const PublisherSelector({
    super.key,
    required this.currentPublisher,
    required this.publishersMenu,
    this.onChanged,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly || currentPublisher == null) {
      return ProfilePictureWidget(
        radius: 16,
        fileId: currentPublisher?.picture?.id,
      ).center().padding(right: 8);
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton2<SnPublisher>(
        value: currentPublisher,
        hint: CircleAvatar(
          radius: 16,
          child: Icon(
            Symbols.person,
            color: Theme.of(
              context,
            ).colorScheme.onSecondaryContainer.withOpacity(0.9),
            fill: 1,
          ),
        ).center().padding(right: 8),
        items: publishersMenu,
        onChanged: onChanged,
        selectedItemBuilder: (context) {
          return publishersMenu
              .map(
                (e) => ProfilePictureWidget(
                  radius: 16,
                  fileId: e.value?.picture?.id,
                ).center().padding(right: 8),
              )
              .toList();
        },
        buttonStyleData: ButtonStyleData(
          height: 40,
          padding: const EdgeInsets.only(left: 14, right: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        ),
        dropdownStyleData: DropdownStyleData(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 64,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 19,
          iconEnabledColor:
              isWideScreen(context)
                  ? null
                  : Theme.of(context).appBarTheme.foregroundColor!,
          iconDisabledColor:
              isWideScreen(context)
                  ? null
                  : Theme.of(context).appBarTheme.foregroundColor!,
        ),
      ),
    );
  }
}

class _PublisherUnselectedWidget extends HookConsumerWidget {
  final ValueChanged<SnPublisher> onPublisherSelected;

  const _PublisherUnselectedWidget({required this.onPublisherSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);
    final publisherInvites = ref.watch(publisherInvitesProvider);

    final hasPublishers = publishers.value?.isNotEmpty ?? false;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!hasPublishers) ...[
            const Icon(
              Symbols.info,
              fill: 1,
              size: 32,
            ).padding(bottom: 6, top: 24),
            Text(
              'creatorHubUnselectedHint',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ).tr(),
            const Gap(24),
          ],
          if (hasPublishers)
            ...(publishers.value?.map(
                  (publisher) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    leading: ProfilePictureWidget(file: publisher.picture),
                    title: Text(publisher.nick),
                    subtitle: Text('@${publisher.name}'),
                    onTap: () => onPublisherSelected(publisher),
                  ),
                ) ??
                []),
          const Divider(height: 1),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            leading: const CircleAvatar(child: Icon(Symbols.mail)),
            title: Text('publisherCollabInvitation').tr(),
            subtitle: Text(
              'publisherCollabInvitationCount',
            ).plural(publisherInvites.value?.length ?? 0),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _PublisherInviteSheet(),
              );
            },
          ),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            leading: const CircleAvatar(child: Icon(Symbols.add)),
            title: Text('createPublisher').tr(),
            subtitle: Text('createPublisherHint').tr(),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const NewPublisherScreen(),
              ).then((value) {
                if (value != null) {
                  ref.invalidate(publishersManagedProvider);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class CreatorHubScreen extends HookConsumerWidget {
  const CreatorHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);
    final currentPublisher = useState<SnPublisher?>(
      publishers.value?.firstOrNull,
    );

    void updatePublisher() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder:
            (context) =>
                EditPublisherScreen(name: currentPublisher.value!.name),
      ).then((value) async {
        if (value == null) return;
        final data = await ref.refresh(publishersManagedProvider.future);
        currentPublisher.value =
            data.where((e) => e.id == currentPublisher.value!.id).firstOrNull;
      });
    }

    void deletePublisher() {
      showConfirmAlert('deletePublisherHint'.tr(), 'deletePublisher'.tr()).then(
        (confirm) {
          if (confirm) {
            final client = ref.watch(apiClientProvider);
            client.delete('/sphere/publishers/${currentPublisher.value!.name}');
            ref.invalidate(publishersManagedProvider);
            currentPublisher.value = null;
          }
        },
      );
    }

    final List<DropdownMenuItem<SnPublisher>> publishersMenu = publishers.when(
      data:
          (data) =>
              data
                  .map(
                    (item) => DropdownMenuItem<SnPublisher>(
                      value: item,
                      child: ListTile(
                        minTileHeight: 48,
                        leading: ProfilePictureWidget(
                          radius: 16,
                          fileId: item.picture?.id,
                        ),
                        title: Text(item.nick),
                        subtitle: Text('@${item.name}'),
                        trailing:
                            currentPublisher.value?.id == item.id
                                ? const Icon(Icons.check)
                                : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  )
                  .toList(),
      loading: () => [],
      error: (_, _) => [],
    );

    final publisherStats = ref.watch(
      publisherStatsProvider(currentPublisher.value?.name),
    );

    final publisherHeatmap = ref.watch(
      publisherHeatmapProvider(currentPublisher.value?.name),
    );

    final publisherFeatures = ref.watch(
      publisherFeaturesProvider(currentPublisher.value?.name),
    );

    Widget buildNavigationWidget(bool isWide) {
      final leftItems = [
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('stickers').tr(),
          trailing: Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.ar_stickers),
          onTap: () {
            context.pushNamed(
              'creatorStickers',
              pathParameters: {'name': currentPublisher.value!.name},
            );
          },
        ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('posts').tr(),
          trailing: Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.sticky_note_2),
          onTap: () {
            context.pushNamed(
              'creatorPosts',
              pathParameters: {'name': currentPublisher.value!.name},
            );
          },
        ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('polls').tr(),
          trailing: const Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.poll),
          onTap: () {
            context.pushNamed(
              'creatorPolls',
              pathParameters: {'name': currentPublisher.value!.name},
            );
          },
        ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: const Text('webFeeds').tr(),
          trailing: const Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.rss_feed),
          onTap: () {
            context.push('/creators/${currentPublisher.value!.name}/feeds');
          },
        ),
      ];

      final rightItems = [
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('publisherMembers').tr(),
          trailing: const Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.group),
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder:
                  (context) => _PublisherMemberListSheet(
                    publisherUname: currentPublisher.value!.name,
                  ),
            );
          },
        ),
        ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          title: Text('publisherFeatures').tr(),
          leading: const Icon(Symbols.flag),
          tilePadding: const EdgeInsets.only(left: 16, right: 24),
          minTileHeight: 48,
          children: [
            ...publisherFeatures.when(
              data: (data) {
                return data.entries.map((entry) {
                  final keyPrefix =
                      'publisherFeature${entry.key.capitalizeEachWord()}';
                  return ListTile(
                    minTileHeight: 48,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Icon(
                      Symbols.circle,
                      color: entry.value ? Colors.green : Colors.red,
                      fill: 1,
                      size: 16,
                    ).padding(left: 2, top: 4),
                    title: Text(keyPrefix).tr(),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${keyPrefix}Description').tr(),
                        if (!entry.value) Text('${keyPrefix}Hint').tr().bold(),
                      ],
                    ),
                    isThreeLine: true,
                  );
                }).toList();
              },
              error: (_, _) => [],
              loading: () => [],
            ),
          ],
        ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('editPublisher').tr(),
          trailing: Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.edit),
          onTap: updatePublisher,
        ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('deletePublisher').tr(),
          trailing: Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.delete),
          onTap: deletePublisher,
        ),
      ];

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(children: leftItems),
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(children: rightItems),
              ),
            ),
          ],
        ).padding(horizontal: 12);
      } else {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [...leftItems, const Divider(height: 8), ...rightItems],
          ),
        );
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(backTo: '/account'),
        title: Text('creatorHub').tr(),
        actions: [
          if (!isWideScreen(context))
            PublisherSelector(
              currentPublisher: currentPublisher.value,
              publishersMenu: publishersMenu,
              onChanged: (value) {
                currentPublisher.value = value;
              },
            ),
          const Gap(8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = isWideScreen(context);
          final maxWidth = isWide ? 800.0 : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: publisherStats.when(
                data:
                    (stats) => SingleChildScrollView(
                      child:
                          currentPublisher.value == null
                              ? ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 640),
                                child: _PublisherUnselectedWidget(
                                  onPublisherSelected: (publisher) {
                                    currentPublisher.value = publisher;
                                  },
                                ),
                              ).center()
                              : isWide
                              ? Column(
                                spacing: 8,
                                children: [
                                  const SizedBox.shrink(),
                                  PublisherSelector(
                                    currentPublisher: currentPublisher.value,
                                    publishersMenu: publishersMenu,
                                    onChanged: (value) {
                                      currentPublisher.value = value;
                                    },
                                  ),
                                  if (stats != null)
                                    _PublisherStatsWidget(
                                      stats: stats,
                                      heatmap: publisherHeatmap.value,
                                    ).padding(horizontal: 12),
                                  buildNavigationWidget(true),
                                ],
                              )
                              : Column(
                                spacing: 12,
                                children: [
                                  if (stats != null)
                                    _PublisherStatsWidget(
                                      stats: stats,
                                      heatmap: publisherHeatmap.value,
                                    ).padding(horizontal: 16),
                                  buildNavigationWidget(false),
                                ],
                              ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PublisherStatsWidget extends StatelessWidget {
  final SnPublisherStats stats;
  final SnHeatmap? heatmap;
  const _PublisherStatsWidget({required this.stats, this.heatmap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: _buildStatsCard(
                  context,
                  stats.postsCreated.toString(),
                  'postsCreatedCount',
                ),
              ),
              Expanded(
                child: _buildStatsCard(
                  context,
                  stats.stickerPacksCreated.toString(),
                  'stickerPacksCreatedCount',
                ),
              ),
              Expanded(
                child: _buildStatsCard(
                  context,
                  stats.stickersCreated.toString(),
                  'stickersCreatedCount',
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: _buildStatsCard(
                  context,
                  stats.upvoteReceived.toString(),
                  'upvoteReceived',
                ),
              ),
              Expanded(
                child: _buildStatsCard(
                  context,
                  stats.downvoteReceived.toString(),
                  'downvoteReceived',
                ),
              ),
            ],
          ),
          if (heatmap != null) ActivityHeatmapWidget(heatmap: heatmap!),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    String statValue,
    String statLabel,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Tooltip(
            richMessage: TextSpan(
              text: statLabel.tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: ' '),
                TextSpan(
                  text: statValue,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statValue,
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  statLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).tr(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PublisherMemberState {
  final List<SnPublisherMember> members;
  final bool isLoading;
  final int total;
  final String? error;

  const PublisherMemberState({
    required this.members,
    required this.isLoading,
    required this.total,
    this.error,
  });

  PublisherMemberState copyWith({
    List<SnPublisherMember>? members,
    bool? isLoading,
    int? total,
    String? error,
  }) {
    return PublisherMemberState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
      error: error ?? this.error,
    );
  }
}

final publisherMemberStateProvider = StateNotifierProvider.family<
  PublisherMemberNotifier,
  PublisherMemberState,
  String
>((ref, publisherUname) {
  final apiClient = ref.watch(apiClientProvider);
  return PublisherMemberNotifier(apiClient, publisherUname);
});

class PublisherMemberNotifier extends StateNotifier<PublisherMemberState> {
  final String publisherUname;
  final Dio _apiClient;

  PublisherMemberNotifier(this._apiClient, this.publisherUname)
    : super(
        const PublisherMemberState(members: [], isLoading: false, total: 0),
      );

  Future<void> loadMore({int offset = 0, int take = 20}) async {
    if (state.isLoading) return;
    if (state.total > 0 && state.members.length >= state.total) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get(
        '/sphere/publishers/$publisherUname/members',
        queryParameters: {'offset': offset, 'take': take},
      );

      final total = int.parse(response.headers.value('X-Total') ?? '0');
      final List<dynamic> data = response.data;
      final members = data.map((e) => SnPublisherMember.fromJson(e)).toList();

      state = state.copyWith(
        members: [...state.members, ...members],
        total: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void reset() {
    state = const PublisherMemberState(members: [], isLoading: false, total: 0);
  }
}

class _PublisherMemberListSheet extends HookConsumerWidget {
  final String publisherUname;
  const _PublisherMemberListSheet({required this.publisherUname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisherIdentity = ref.watch(
      publisherIdentityProvider(publisherUname),
    );
    final memberListProvider = publisherMemberListNotifierProvider(
      publisherUname,
    );
    final memberState = ref.watch(publisherMemberStateProvider(publisherUname));
    final memberNotifier = ref.read(
      publisherMemberStateProvider(publisherUname).notifier,
    );

    useEffect(() {
      Future(() {
        memberNotifier.loadMore();
      });
      return null;
    }, []);

    Future<void> invitePerson() async {
      final result = await showModalBottomSheet(
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.post(
          '/publishers/$publisherUname/invites',
          data: {'related_user_id': result.id, 'role': 0},
        );
        // Refresh both providers
        memberNotifier.reset();
        await memberNotifier.loadMore();
        ref.invalidate(memberListProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  'members'.plural(memberState.total),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.person_add),
                  onPressed: invitePerson,
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
                IconButton(
                  icon: const Icon(Symbols.refresh),
                  onPressed: () {
                    memberNotifier.reset();
                    memberNotifier.loadMore();
                    ref.invalidate(memberListProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PagingHelperView(
              provider: memberListProvider,
              futureRefreshable: memberListProvider.future,
              notifierRefreshable: memberListProvider.notifier,
              contentBuilder: (data, widgetCount, endItemView) {
                return ListView.builder(
                  itemCount: widgetCount,
                  itemBuilder: (context, index) {
                    if (index == data.items.length) {
                      return endItemView;
                    }

                    final member = data.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 12),
                      leading: ProfilePictureWidget(
                        fileId: member.account!.profile.picture?.id,
                      ),
                      title: Row(
                        spacing: 6,
                        children: [
                          Flexible(child: Text(member.account!.nick)),
                          if (member.joinedAt == null)
                            const Icon(Symbols.pending_actions, size: 20),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            member.role >= 100
                                ? 'permissionOwner'
                                : member.role >= 50
                                ? 'permissionModerator'
                                : 'permissionMember',
                          ).tr(),
                          Text('·').bold().padding(horizontal: 6),
                          Expanded(child: Text("@${member.account!.name}")),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((publisherIdentity.value?.role ?? 0) >= 50)
                            IconButton(
                              icon: const Icon(Symbols.edit),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder:
                                      (context) => _PublisherMemberRoleSheet(
                                        publisherUname: publisherUname,
                                        member: member,
                                      ),
                                ).then((value) {
                                  if (value != null) {
                                    // Refresh both providers
                                    memberNotifier.reset();
                                    memberNotifier.loadMore();
                                    ref.invalidate(memberListProvider);
                                  }
                                });
                              },
                            ),
                          if ((publisherIdentity.value?.role ?? 0) >= 50)
                            IconButton(
                              icon: const Icon(Symbols.delete),
                              onPressed: () {
                                showConfirmAlert(
                                  'removePublisherMemberHint'.tr(),
                                  'removePublisherMember'.tr(),
                                ).then((confirm) async {
                                  if (confirm != true) return;
                                  try {
                                    final apiClient = ref.watch(
                                      apiClientProvider,
                                    );
                                    await apiClient.delete(
                                      '/publishers/$publisherUname/members/${member.accountId}',
                                    );
                                    // Refresh both providers
                                    memberNotifier.reset();
                                    memberNotifier.loadMore();
                                    ref.invalidate(memberListProvider);
                                  } catch (err) {
                                    showErrorAlert(err);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PublisherMemberRoleSheet extends HookConsumerWidget {
  final String publisherUname;
  final SnPublisherMember member;

  const _PublisherMemberRoleSheet({
    required this.publisherUname,
    required this.member,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleController = useTextEditingController(
      text: member.role.toString(),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Text(
                    'memberRoleEdit'.tr(args: [member.account!.name]),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Autocomplete<int>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const [100, 50, 0];
                    }
                    final int? value = int.tryParse(textEditingValue.text);
                    if (value == null) return const [100, 50, 0];
                    return [100, 50, 0].where(
                      (option) =>
                          option.toString().contains(textEditingValue.text),
                    );
                  },
                  onSelected: (int selection) {
                    roleController.text = selection.toString();
                  },
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'memberRole'.tr(),
                        helperText: 'memberRoleHint'.tr(),
                      ),
                      onTapOutside: (event) => focusNode.unfocus(),
                    );
                  },
                ),
                const Gap(16),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      final newRole = int.parse(roleController.text);
                      if (newRole < 0 || newRole > 100) {
                        throw 'Role must be between 0 and 100';
                      }

                      final apiClient = ref.read(apiClientProvider);
                      await apiClient.patch(
                        '/publishers/$publisherUname/members/${member.accountId}/role',
                        data: newRole,
                      );

                      if (context.mounted) Navigator.pop(context, true);
                    } catch (err) {
                      showErrorAlert(err);
                    }
                  },
                  icon: const Icon(Symbols.save),
                  label: const Text('saveChanges').tr(),
                ),
              ],
            ).padding(vertical: 16, horizontal: 24),
          ],
        ),
      ),
    );
  }
}

class _PublisherInviteSheet extends HookConsumerWidget {
  const _PublisherInviteSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(publisherInvitesProvider);

    Future<void> acceptInvite(SnPublisherMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/publishers/invites/${invite.publisher!.name}/accept',
        );
        ref.invalidate(publisherInvitesProvider);
        ref.invalidate(publishersManagedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnPublisherMember invite) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/publishers/invites/${invite.publisher!.name}/decline',
        );
        ref.invalidate(publisherInvitesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'invites'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            ref.invalidate(publisherInvitesProvider);
          },
        ),
      ],
      child: invites.when(
        data:
            (items) =>
                items.isEmpty
                    ? Center(
                      child:
                          Text(
                            'invitesEmpty',
                            textAlign: TextAlign.center,
                          ).tr(),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final invite = items[index];
                        return ListTile(
                          leading: ProfilePictureWidget(
                            fileId: invite.publisher!.picture?.id,
                            fallbackIcon: Symbols.group,
                          ),
                          title: Text(invite.publisher!.nick),
                          subtitle:
                              Text(
                                invite.role >= 100
                                    ? 'permissionOwner'
                                    : invite.role >= 50
                                    ? 'permissionModerator'
                                    : 'permissionMember',
                              ).tr(),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Symbols.check),
                                onPressed: () => acceptInvite(invite),
                              ),
                              IconButton(
                                icon: const Icon(Symbols.close),
                                onPressed: () => declineInvite(invite),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(publisherInvitesProvider),
            ),
      ),
    );
  }
}
