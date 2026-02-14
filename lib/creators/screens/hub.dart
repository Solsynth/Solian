import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/activitypub/actor_profile.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide AutoLeadingButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/posts/activity_heatmap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
Future<SnActorStatusResponse> publisherActorStatus(
  Ref ref,
  String? publisherName,
) async {
  if (publisherName == null) throw Exception('Publisher name is required');
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(
    '/sphere/publishers/$publisherName/fediverse',
  );
  return SnActorStatusResponse.fromJson(response.data);
}

@RoutePage()
class CreatorHubListScreen extends StatelessWidget {
  const CreatorHubListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isWideScreen(context)) return const SizedBox.shrink();
    return const CreatorHubContentWidget();
  }
}

final publisherMemberListNotifierProvider = AsyncNotifierProvider.family
    .autoDispose(PublisherMemberListNotifier.new);

class PublisherMemberListNotifier
    extends AsyncNotifier<PaginationState<SnPublisherMember>>
    with AsyncPaginationController<SnPublisherMember> {
  static const int pageSize = 20;

  final String arg;
  PublisherMemberListNotifier(this.arg);

  @override
  FutureOr<PaginationState<SnPublisherMember>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnPublisherMember>> fetch() async {
    final apiClient = ref.read(apiClientProvider);

    final response = await apiClient.get(
      '/sphere/publishers/$arg/members',
      queryParameters: {'offset': fetchedCount.toString(), 'take': pageSize},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final members = response.data
        .map((e) => SnPublisherMember.fromJson(e))
        .cast<SnPublisherMember>()
        .toList();

    return members;
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
        file: currentPublisher?.picture,
      ).center().padding(right: 8);
    }

    // Ensure the selected value is valid
    final currentValue = currentPublisher;
    final isValueValid =
        currentValue != null &&
        publishersMenu.any((item) => item.value?.id == currentValue.id);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<SnPublisher>(
        value: isValueValid ? currentValue : null,
        customButton: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              ProfilePictureWidget(
                radius: 10,
                file: isValueValid ? currentValue.picture : null,
              ),
              Flexible(
                child: Text(
                  isValueValid ? currentValue.nick : 'Select Publisher',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Symbols.keyboard_arrow_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        items: publishersMenu
            .map(
              (item) => DropdownMenuItem<SnPublisher>(
                value: item.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.value?.nick ?? '',
                      style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '@${item.value?.name ?? ''}',
                      style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        isDense: true,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            if (publishers.isLoading)
              Padding(
                padding: const EdgeInsets.all(8),
                child: const CircularProgressIndicator(),
              )
            else
              ...([
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
              ]),
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

// Extracted widget for the Creator Hub content
class CreatorHubContentWidget extends HookConsumerWidget {
  const CreatorHubContentWidget({super.key});

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
        builder: (context) =>
            EditPublisherScreen(name: currentPublisher.value!.name),
      ).then((value) async {
        if (value == null) return;
        final data = await ref.refresh(publishersManagedProvider.future);
        currentPublisher.value = data
            .where((e) => e.id == currentPublisher.value!.id)
            .firstOrNull;
      });
    }

    void deletePublisher() {
      showConfirmAlert(
        'deletePublisherHint'.tr(),
        'deletePublisher'.tr(),
        isDanger: true,
      ).then((confirm) {
        if (confirm) {
          final client = ref.watch(apiClientProvider);
          client.delete('/sphere/publishers/${currentPublisher.value!.name}');
          ref.invalidate(publishersManagedProvider);
          currentPublisher.value = null;
        }
      });
    }

    final List<DropdownMenuItem<SnPublisher>> publishersMenu = publishers.when(
      data: (data) => data
          .map(
            (item) => DropdownMenuItem<SnPublisher>(
              value: item,
              child: ListTile(
                minTileHeight: 48,
                leading: ProfilePictureWidget(radius: 16, file: item.picture),
                title: Text(item.nick),
                subtitle: Text('@${item.name}'),
                trailing: currentPublisher.value?.id == item.id
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

    Widget buildNavigationWidget() {
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
            context.router.push(
              CreatorStickerListRoute(pubName: currentPublisher.value!.name),
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
            context.router.push(
              CreatorPostListRoute(pubName: currentPublisher.value!.name),
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
            context.router.push(
              CreatorPollListRoute(pubName: currentPublisher.value!.name),
            );
          },
        ),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          minTileHeight: 48,
          title: Text('publicationSites').tr(),
          trailing: const Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.web),
          onTap: () {
            context.router.push(
              CreatorSiteListRoute(pubName: currentPublisher.value!.name),
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
            context.router.push(
              CreatorFeedListRoute(pubName: currentPublisher.value!.name),
            );
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
              builder: (context) => _PublisherMemberListSheet(
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
          title: Text('publisherFediverse').tr(),
          trailing: Icon(Symbols.chevron_right),
          leading: const Icon(Symbols.public),
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => _PublisherFediverseSheet(
                publisherUname: currentPublisher.value!.name,
              ),
            );
          },
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

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [...leftItems, const Divider(height: 8), ...rightItems],
        ),
      );
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('creatorHub').tr(),
        actions: [
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
      body: publisherStats.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: currentPublisher.value == null
              ? ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 640),
                  child: _PublisherUnselectedWidget(
                    onPublisherSelected: (publisher) {
                      currentPublisher.value = publisher;
                    },
                  ),
                ).center()
              : Column(
                  spacing: 12,
                  children: [
                    if (stats != null)
                      _PublisherStatsWidget(
                        stats: stats,
                        heatmap: publisherHeatmap.value,
                      ).padding(horizontal: 16),
                    buildNavigationWidget(),
                  ],
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

@RoutePage()
class CreatorHubScreen extends HookConsumerWidget {
  const CreatorHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return AppBackground(
      isRoot: true,
      child: SafeArea(
        child: isWide
            ? Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        child: const CreatorHubContentWidget(),
                      ),
                    ).padding(left: 16, vertical: 16),
                  ),
                  const Gap(8),
                  Flexible(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ),
                      child: const AutoRouter(),
                    ).padding(top: 16),
                  ),
                ],
              )
            : const AutoRouter(),
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
          if (heatmap != null)
            ActivityHeatmapWidget(heatmap: heatmap!, forceDense: true),
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
    final memberNotifier = ref.read(
      publisherMemberListNotifierProvider(publisherUname).notifier,
    );

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
          '/sphere/publishers/invites/$publisherUname',
          data: {'related_user_id': result.id, 'role': 0},
        );
        memberNotifier.refresh();
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
                  'members'.plural(memberNotifier.totalCount ?? 0),
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
                    memberNotifier.refresh();
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
            child: PaginationList(
              provider: memberListProvider,
              notifier: memberListProvider.notifier,
              itemBuilder: (context, index, member) {
                return ListTile(
                  contentPadding: EdgeInsets.only(left: 16, right: 12),
                  leading: ProfilePictureWidget(
                    file: member.account!.profile.picture,
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
                              builder: (context) => _PublisherMemberRoleSheet(
                                publisherUname: publisherUname,
                                member: member,
                              ),
                            ).then((value) {
                              if (value != null) {
                                memberNotifier.refresh();
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
                                final apiClient = ref.watch(apiClientProvider);
                                await apiClient.delete(
                                  '/sphere/publishers/$publisherUname/members/${member.accountId}',
                                );
                                memberNotifier.refresh();
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
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
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
                        '/sphere/publishers/$publisherUname/members/${member.accountId}/role',
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
          '/sphere/publishers/invites/${invite.publisher!.name}/accept',
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
          '/sphere/publishers/invites/${invite.publisher!.name}/decline',
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
        data: (items) => items.isEmpty
            ? Center(
                child: Text('invitesEmpty', textAlign: TextAlign.center).tr(),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final invite = items[index];
                  return ListTile(
                    leading: ProfilePictureWidget(
                      file: invite.publisher!.picture,
                      fallbackIcon: Symbols.group,
                    ),
                    title: Text(invite.publisher!.nick),
                    subtitle: Text(
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
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(publisherInvitesProvider),
        ),
      ),
    );
  }
}

class _PublisherFediverseSheet extends HookConsumerWidget {
  final String publisherUname;

  const _PublisherFediverseSheet({required this.publisherUname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorStatus = ref.watch(publisherActorStatusProvider(publisherUname));
    final apiClient = ref.read(apiClientProvider);
    final isLoading = useState(false);

    Future<void> toggleActor() async {
      final currentStatus = actorStatus.value;
      if (currentStatus == null) return;

      final confirm = await showConfirmAlert(
        currentStatus.enabled
            ? 'publisherFediverseDisableConfirm'.tr()
            : 'publisherFediverseEnableConfirm'.tr(),
        currentStatus.enabled
            ? 'publisherFediverseDisabled'.tr()
            : 'publisherFediverseEnabled'.tr(),
        isDanger: !currentStatus.enabled,
      );
      if (confirm != true) return;

      try {
        isLoading.value = true;
        if (currentStatus.enabled) {
          await apiClient.delete(
            '/sphere/publishers/$publisherUname/fediverse',
          );
        } else {
          await apiClient.post('/sphere/publishers/$publisherUname/fediverse');
        }
        ref.invalidate(publisherActorStatusProvider(publisherUname));
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'publisherFediverse'.tr(),
      child: actorStatus.when(
        data: (status) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            spacing: 16,
            children: [
              Card.outlined(
                child: SwitchListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  value: status.enabled,
                  onChanged: isLoading.value ? null : (_) => toggleActor(),
                  title: Text(
                    status.enabled
                        ? 'publisherFediverseEnabled'.tr()
                        : 'publisherFediverseDisabled'.tr(),
                  ),
                  subtitle: Text(
                    status.enabled
                        ? 'publisherFediverseDisableHint'.tr()
                        : 'publisherFediverseEnableHint'.tr(),
                  ),
                  secondary: isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          status.enabled
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: status.enabled ? Colors.green : Colors.grey,
                        ),
                ),
              ).padding(horizontal: 16),
              if (status.enabled) ...[
                if (status.actor != null) ...[
                  ListTile(
                    leading: ActorPictureWidget(
                      actor: status.actor!,
                      radius: 24,
                    ),
                    title: Text(
                      status.actor!.displayName ??
                          status.actor!.username ??
                          'unknown'.tr(),
                    ),
                    subtitle: Text(
                      '@${status.actor!.username}@${status.actor!.instance.domain}',
                    ),
                    isThreeLine: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                  ),
                  ListTile(
                    leading: const Icon(Symbols.link),
                    title: Text('publisherFediverseActorUri').tr(),
                    subtitle: Text(status.actorUri ?? 'N/A'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                ],
                ListTile(
                  leading: const Icon(Symbols.group),
                  title: Text('publisherFediverseFollowerCount').tr(),
                  subtitle: Text(
                    status.followerCount > 0
                        ? status.followerCount.toString()
                        : 'publisherFediverseNoFollowers'.tr(),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                ),
              ],
              ExpansionTile(
                leading: const Icon(Symbols.info),
                title: Text('publisherFediverseWhatIs').tr(),
                tilePadding: const EdgeInsets.symmetric(horizontal: 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    child: Text('publisherFediverseAbout').tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () =>
              ref.invalidate(publisherActorStatusProvider(publisherUname)),
        ),
      ),
    );
  }
}
