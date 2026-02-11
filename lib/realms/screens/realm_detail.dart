import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/core/services/color.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/services/color_extraction.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/core/network.dart';
import 'package:island/core/config.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _RealmPinnedPostsPageView extends HookConsumerWidget {
  final String realmSlug;

  const _RealmPinnedPostsPageView({required this.realmSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: 'realm-$realmSlug-pinned',
        initialFilter: PostListQuery(realm: realmSlug, pinned: true),
      ),
    );
    final pinnedPosts = ref.watch(provider);
    final pageController = usePageController();
    final currentPage = useState(0);

    useEffect(() {
      void listener() {
        currentPage.value = pageController.page?.round() ?? 0;
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [pageController]);

    return pinnedPosts.when(
      data: (data) {
        if (data.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Symbols.push_pin),
              title: Text('pinnedPosts'.tr()),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              collapsedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              children: [
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: pageController,
                        itemCount: data.items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              child: Card(
                                child: PostActionableItem(
                                  item: data.items[index],
                                  borderRadius: 8,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            data.items.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == currentPage.value
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

final realmAppbarForegroundColorProvider = FutureProvider.autoDispose
    .family<Color?, String>((ref, realmSlug) async {
      final realm = await ref.watch(realmProvider(realmSlug).future);
      if (realm?.background == null) return null;
      final colors = await ColorExtractionService.getColorsFromImage(
        CloudImageWidget.provider(
          file: realm!.background!,
          serverUrl: ref.watch(serverUrlProvider),
        ),
      );
      if (colors.isEmpty) return null;
      final dominantColor = colors.first;
      return dominantColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;
    });

final realmIdentityProvider = FutureProvider.autoDispose
    .family<SnRealmMember?, String>((ref, realmSlug) async {
      try {
        final apiClient = ref.watch(apiClientProvider);
        final response = await apiClient.get(
          '/pass/realms/$realmSlug/members/me',
        );
        return SnRealmMember.fromJson(response.data);
      } catch (err) {
        if (err is DioException && err.response?.statusCode == 404) {
          return null; // No identity found, user is not a member
        }
        rethrow;
      }
    });

final realmChatRoomsProvider = FutureProvider.autoDispose
    .family<List<SnChatRoom>, String>((ref, realmSlug) async {
      final apiClient = ref.watch(apiClientProvider);
      final response = await apiClient.get('/messager/realms/$realmSlug/chat');
      return (response.data as List)
          .map((e) => SnChatRoom.fromJson(e))
          .toList();
    });

@RoutePage()
class RealmDetailScreen extends HookConsumerWidget {
  final String slug;

  const RealmDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realmState = ref.watch(realmProvider(slug));
    final appbarColor = ref.watch(realmAppbarForegroundColorProvider(slug));

    final iconShadow = Shadow(
      color: appbarColor.value?.invert ?? Colors.black54,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    final realmIdentity = ref.watch(realmIdentityProvider(slug));
    final realmChatRooms = ref.watch(realmChatRoomsProvider(slug));

    Widget realmDescriptionWidget(SnRealm realm) => Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          title: const Text('description').tr(),
          initiallyExpanded:
              realmIdentity.hasValue && realmIdentity.value == null,
          tilePadding: EdgeInsets.only(left: 24, right: 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              realm.description,
              style: const TextStyle(fontSize: 16),
            ).padding(horizontal: 20, bottom: 16, top: 8),
          ],
        ),
      ),
    );

    Widget realmActionWidget(SnRealm realm) => Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: FilledButton.tonalIcon(
        onPressed: () async {
          try {
            final apiClient = ref.read(apiClientProvider);
            await apiClient.post('/pass/realms/$slug/members/me');
            ref.invalidate(realmIdentityProvider(slug));
            ref.invalidate(realmsJoinedProvider);
            showSnackBar('realmJoinSuccess'.tr());
          } catch (err) {
            showErrorAlert(err);
          }
        },
        icon: const Icon(Symbols.add),
        label: const Text('realmJoin').tr(),
      ).padding(all: 16),
    );

    Widget realmChatRoomListWidget(SnRealm realm) => Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'chatTabGroup',
          ).tr().bold().padding(horizontal: 24, top: 12, bottom: 4),
          realmChatRooms.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (rooms) {
              if (rooms.isEmpty) {
                return Text(
                  'dataEmpty',
                ).tr().padding(horizontal: 24, bottom: 12);
              }
              return Column(
                children: [
                  for (final room in rooms)
                    ChatRoomListTile(
                      room: room,
                      onTap: () {
                        context.router.push(ChatRoomRoute(id: room.id));
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: isWideScreen(context)
          ? realmState.when(
              data: (realm) => AppBar(
                foregroundColor: appbarColor.value,
                leading: PageBackButton(
                  color: appbarColor.value,
                  shadows: [iconShadow],
                ),
                flexibleSpace: Stack(
                  children: [
                    Positioned.fill(
                      child: realm!.background != null
                          ? CloudImageWidget(file: realm.background!)
                          : Container(
                              color: Theme.of(
                                context,
                              ).appBarTheme.backgroundColor,
                            ),
                    ),
                    FlexibleSpaceBar(
                      title: Text(
                        realm.name,
                        style: TextStyle(
                          color:
                              appbarColor.value ??
                              Theme.of(context).appBarTheme.foregroundColor,
                          shadows: [iconShadow],
                        ),
                      ),
                      background: Container(),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.people, shadows: [iconShadow]),
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) =>
                            _RealmMemberListSheet(realmSlug: slug),
                      );
                    },
                  ),
                  _RealmActionMenu(realmSlug: slug, iconShadow: iconShadow),
                  const Gap(8),
                ],
              ),
              error: (_, _) => AppBar(leading: PageBackButton()),
              loading: () => AppBar(leading: PageBackButton()),
            )
          : null,
      body: realmState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (realm) => isWideScreen(context)
            ? Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _RealmPinnedPostsPageView(realmSlug: slug),
                        ),
                        SliverPostList(
                          query: PostListQuery(realm: slug, pinned: false),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        realmIdentity.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (identity) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              realmDescriptionWidget(realm!),
                              if (identity == null && realm.isCommunity)
                                realmActionWidget(realm)
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        realmChatRoomListWidget(realm!),
                      ],
                    ),
                  ),
                ],
              ).padding(horizontal: 8, top: 8)
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    foregroundColor: appbarColor.value,
                    leading: PageBackButton(
                      color: appbarColor.value,
                      shadows: [iconShadow],
                    ),
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: realm!.background != null
                              ? CloudImageWidget(file: realm.background!)
                              : Container(
                                  color: Theme.of(
                                    context,
                                  ).appBarTheme.backgroundColor,
                                ),
                        ),
                        FlexibleSpaceBar(
                          title: Text(
                            realm.name,
                            style: TextStyle(
                              color:
                                  appbarColor.value ??
                                  Theme.of(context).appBarTheme.foregroundColor,
                              shadows: [iconShadow],
                            ),
                          ),
                          background:
                              Container(), // Empty container since background is handled by Stack
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.people, shadows: [iconShadow]),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) =>
                                _RealmMemberListSheet(realmSlug: slug),
                          );
                        },
                      ),
                      _RealmActionMenu(realmSlug: slug, iconShadow: iconShadow),
                      const Gap(8),
                    ],
                  ),
                  SliverGap(4),
                  SliverToBoxAdapter(
                    child: realmIdentity.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (identity) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          realmDescriptionWidget(realm),
                          if (identity == null && realm.isCommunity)
                            realmActionWidget(realm)
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: realmChatRoomListWidget(realm)),
                  SliverToBoxAdapter(
                    child: _RealmPinnedPostsPageView(realmSlug: slug),
                  ),
                  SliverPostList(
                    query: PostListQuery(realm: slug, pinned: false),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RealmActionMenu extends HookConsumerWidget {
  final String realmSlug;
  final Shadow iconShadow;

  const _RealmActionMenu({required this.realmSlug, required this.iconShadow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realmIdentity = ref.watch(realmIdentityProvider(realmSlug));
    final isModerator = realmIdentity.when(
      data: (identity) => (identity?.role ?? 0) >= 50,
      loading: () => false,
      error: (_, _) => false,
    );

    return PopupMenuButton(
      icon: Icon(Icons.more_vert, shadows: [iconShadow]),
      itemBuilder: (context) => [
        if (isModerator)
          PopupMenuItem(
            onTap: () {
              context.router.push(RealmEditRoute(slug: realmSlug));
            },
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const Gap(12),
                const Text('editRealm').tr(),
              ],
            ),
          ),
        realmIdentity.when(
          data: (identity) => (identity?.role ?? 0) >= 100
              ? PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const Gap(12),
                      const Text(
                        'deleteRealm',
                        style: TextStyle(color: Colors.red),
                      ).tr(),
                    ],
                  ),
                  onTap: () {
                    showConfirmAlert(
                      'deleteRealmHint'.tr(),
                      'deleteRealm'.tr(),
                      isDanger: true,
                    ).then((confirm) {
                      if (confirm) {
                        final client = ref.watch(apiClientProvider);
                        client.delete('/pass/realms/$realmSlug');
                        ref.invalidate(realmsJoinedProvider);
                        if (context.mounted) {
                          context.router.pop(true);
                        }
                      }
                    });
                  },
                )
              : PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const Gap(12),
                      Text(
                        'leaveRealm',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ).tr(),
                    ],
                  ),
                  onTap: () {
                    showConfirmAlert(
                      'leaveRealmHint'.tr(),
                      'leaveRealm'.tr(),
                    ).then((confirm) async {
                      if (confirm) {
                        final client = ref.watch(apiClientProvider);
                        await client.delete(
                          '/pass/realms/$realmSlug/members/me',
                        );
                        ref.invalidate(realmsJoinedProvider);
                        if (context.mounted) {
                          context.router.pop(true);
                        }
                      }
                    });
                  },
                ),
          loading: () => const PopupMenuItem(
            enabled: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.error,
                ),
                const Gap(12),
                Text(
                  'leaveRealm',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ).tr(),
              ],
            ),
            onTap: () {
              showConfirmAlert('leaveRealmHint'.tr(), 'leaveRealm'.tr()).then((
                confirm,
              ) async {
                if (confirm) {
                  final client = ref.watch(apiClientProvider);
                  await client.delete('/pass/realms/$realmSlug/members/me');
                  ref.invalidate(realmsJoinedProvider);
                  if (context.mounted) {
                    context.router.pop(true);
                  }
                }
              });
            },
          ),
        ),
      ],
    );
  }
}

final realmMemberListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family(RealmMemberListNotifier.new);

class RealmMemberListNotifier
    extends AsyncNotifier<PaginationState<SnRealmMember>>
    with AsyncPaginationController<SnRealmMember> {
  String arg;
  RealmMemberListNotifier(this.arg);

  static const int pageSize = 20;

  @override
  Future<List<SnRealmMember>> fetch() async {
    final apiClient = ref.read(apiClientProvider);

    final response = await apiClient.get(
      '/pass/realms/$arg/members',
      queryParameters: {
        'offset': fetchedCount,
        'take': pageSize,
        'withStatus': true,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((e) => SnRealmMember.fromJson(e)).toList();
  }
}

class _RealmMemberListSheet extends HookConsumerWidget {
  final String realmSlug;
  const _RealmMemberListSheet({required this.realmSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberListProvider = realmMemberListNotifierProvider(realmSlug);

    final memberListState = ref.watch(memberListProvider);
    final memberListNotifier = ref.watch(memberListProvider.notifier);
    final realmIdentity = ref.watch(realmIdentityProvider(realmSlug));

    Future<void> invitePerson() async {
      final result = await showModalBottomSheet(
        isScrollControlled: true,
        useRootNavigator: true,
        context: context,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.post(
          '/pass/realms/invites/$realmSlug',
          data: {'related_user_id': result.id, 'role': 0},
        );
        // Refresh the provider
        memberListNotifier.refresh();
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Widget buildMemberListHeader() {
      return Padding(
        padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
        child: Row(
          children: [
            Consumer(
              builder: (context, ref, _) {
                return Text(
                  'members'.plural(memberListState.value?.totalCount ?? 0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                );
              },
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
                // Refresh the provider
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
      );
    }

    Widget buildMemberListContent() {
      return Expanded(
        child: PaginationList(
          provider: memberListProvider,
          notifier: memberListProvider.notifier,
          itemBuilder: (context, index, member) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 16, right: 12),
              leading: AccountPfcRegion(
                uname: member.account!.name,
                child: ProfilePictureWidget(
                  file: member.account!.profile.picture,
                ),
              ),
              title: Row(
                spacing: 6,
                children: [
                  Flexible(
                    child: Text(
                      member.account!.nick,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (member.status != null)
                    AccountStatusLabel(status: member.status!),
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
                  if ((realmIdentity.value?.role ?? 0) >= 50)
                    IconButton(
                      icon: const Icon(Symbols.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => _RealmMemberRoleSheet(
                            realmSlug: realmSlug,
                            member: member,
                          ),
                        ).then((value) {
                          if (value != null) {
                            // Refresh the provider
                            ref.invalidate(memberListProvider);
                          }
                        });
                      },
                    ),
                  if ((realmIdentity.value?.role ?? 0) >= 50)
                    IconButton(
                      icon: const Icon(Symbols.delete),
                      onPressed: () {
                        showConfirmAlert(
                          'removeRealmMemberHint'.tr(),
                          'removeRealmMember'.tr(),
                        ).then((confirm) async {
                          if (confirm != true) return;
                          try {
                            final apiClient = ref.watch(apiClientProvider);
                            await apiClient.delete(
                              '/pass/realms/$realmSlug/members/${member.accountId}',
                            );
                            // Refresh the provider
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
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          buildMemberListHeader(),
          const Divider(height: 1),
          buildMemberListContent(),
        ],
      ),
    );
  }
}

class _RealmMemberRoleSheet extends HookConsumerWidget {
  final String realmSlug;
  final SnRealmMember member;

  const _RealmMemberRoleSheet({required this.realmSlug, required this.member});

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
                        '/pass/realms/$realmSlug/members/${member.accountId}/role',
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
