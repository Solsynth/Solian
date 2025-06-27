import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/screens/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:island/models/chat.dart';
import 'package:island/services/color.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/config.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'detail.g.dart';

@riverpod
Future<Color?> realmAppbarForegroundColor(Ref ref, String realmSlug) async {
  final realm = await ref.watch(realmProvider(realmSlug).future);
  if (realm?.background == null) return null;
  final palette = await PaletteGenerator.fromImageProvider(
    CloudImageWidget.provider(
      fileId: realm!.background!.id,
      serverUrl: ref.watch(serverUrlProvider),
    ),
  );
  final dominantColor = palette.dominantColor?.color;
  if (dominantColor == null) return null;
  return dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

@riverpod
Future<SnRealmMember?> realmIdentity(Ref ref, String realmSlug) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/realms/$realmSlug/members/me');
  return SnRealmMember.fromJson(response.data);
}

@riverpod
Future<List<SnChatRoom>> realmChatRooms(Ref ref, String realmSlug) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/realms/$realmSlug/chat');
  return (response.data as List).map((e) => SnChatRoom.fromJson(e)).toList();
}

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

    return AppScaffold(
      body: realmState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data:
            (realm) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  foregroundColor: appbarColor.value,
                  leading: PageBackButton(
                    color: appbarColor.value,
                    shadows: [iconShadow],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        realm!.background?.id != null
                            ? CloudImageWidget(fileId: realm.background!.id)
                            : Container(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                    title: Text(
                      realm.name,
                      style: TextStyle(
                        color:
                            appbarColor.value ??
                            Theme.of(context).appBarTheme.foregroundColor,
                        shadows: [iconShadow],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.people, shadows: [iconShadow]),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder:
                              (context) =>
                                  _RealmMemberListSheet(realmSlug: slug),
                        );
                      },
                    ),
                    _RealmActionMenu(realmSlug: slug, iconShadow: iconShadow),
                    const Gap(8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: ref
                      .watch(realmIdentityProvider(slug))
                      .when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                        data:
                            (identity) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ExpansionTile(
                                  title: const Text('description').tr(),
                                  initiallyExpanded: identity == null,
                                  tilePadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  children: [
                                    Text(
                                      realm.description,
                                      style: const TextStyle(fontSize: 16),
                                    ).padding(
                                      horizontal: 16,
                                      bottom: 16,
                                      top: 8,
                                    ),
                                  ],
                                ),
                                if (identity == null && realm.isPublic)
                                  FilledButton.tonalIcon(
                                    onPressed: () async {
                                      try {
                                        final apiClient = ref.read(
                                          apiClientProvider,
                                        );
                                        await apiClient.post(
                                          '/realms/$slug/members/me',
                                        );
                                        ref.invalidate(
                                          realmIdentityProvider(slug),
                                        );
                                        ref.invalidate(realmsJoinedProvider);
                                      } catch (err) {
                                        showErrorAlert(err);
                                      }
                                    },
                                    icon: const Icon(Symbols.add),
                                    label: const Text('joinRealm').tr(),
                                  ).padding(horizontal: 16, vertical: 4)
                                else
                                  const SizedBox.shrink(),
                              ],
                            ),
                      ),
                ),
                const SliverToBoxAdapter(child: Divider(height: 1)),
                Consumer(
                  builder: (context, ref, _) {
                    final chatRooms = ref.watch(realmChatRoomsProvider(slug));
                    return chatRooms.when(
                      loading:
                          () => const SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      error:
                          (error, _) => SliverToBoxAdapter(
                            child: Center(child: Text('Error: $error')),
                          ),
                      data: (rooms) {
                        if (rooms.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return ChatRoomListTile(
                              room: rooms[index],
                              onTap: () {
                                context.push('/chat/${rooms[index].id}');
                              },
                            );
                          }, childCount: rooms.length),
                        );
                      },
                    );
                  },
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
      itemBuilder:
          (context) => [
            if (isModerator)
              PopupMenuItem(
                onTap: () {
                  context.pushReplacement('/realms/$realmSlug/edit');
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
              data:
                  (identity) =>
                      (identity?.role ?? 0) >= 100
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
                              ).then((confirm) {
                                if (confirm) {
                                  final client = ref.watch(apiClientProvider);
                                  client.delete('/realms/$realmSlug');
                                  ref.invalidate(realmsJoinedProvider);
                                  if (context.mounted) {
                                    context.pop(true);
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
                              ).then((confirm) {
                                if (confirm) {
                                  final client = ref.watch(apiClientProvider);
                                  client.delete(
                                    '/realms/$realmSlug/members/me',
                                  );
                                  ref.invalidate(realmsJoinedProvider);
                                  if (context.mounted) {
                                    context.pop(true);
                                  }
                                }
                              });
                            },
                          ),
              loading:
                  () => const PopupMenuItem(
                    enabled: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (_, _) => PopupMenuItem(
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
                      ).then((confirm) {
                        if (confirm) {
                          final client = ref.watch(apiClientProvider);
                          client.delete('/realms/$realmSlug/members/me');
                          ref.invalidate(realmsJoinedProvider);
                          if (context.mounted) {
                            context.pop(true);
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

@riverpod
class RealmMemberListNotifier extends _$RealmMemberListNotifier
    with CursorPagingNotifierMixin<SnRealmMember> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnRealmMember>> build(String realmSlug) async {
    return fetch();
  }

  @override
  Future<CursorPagingData<SnRealmMember>> fetch({String? cursor}) async {
    final apiClient = ref.read(apiClientProvider);
    final offset = cursor != null ? int.parse(cursor) : 0;

    final response = await apiClient.get(
      '/realms/$realmSlug/members',
      queryParameters: {'offset': offset, 'take': _pageSize},
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final members = data.map((e) => SnRealmMember.fromJson(e)).toList();

    final hasMore = offset + members.length < total;
    final nextCursor = hasMore ? (offset + members.length).toString() : null;

    return CursorPagingData(
      items: members,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

// Keep the old provider for backward compatibility
final realmMemberStateProvider =
    StateNotifierProvider.family<RealmMemberNotifier, RealmMemberState, String>(
      (ref, realmSlug) {
        final apiClient = ref.watch(apiClientProvider);
        return RealmMemberNotifier(apiClient, realmSlug);
      },
    );

class RealmMemberNotifier extends StateNotifier<RealmMemberState> {
  final String realmSlug;
  final Dio _apiClient;

  RealmMemberNotifier(this._apiClient, this.realmSlug)
    : super(const RealmMemberState(members: [], isLoading: false, total: 0));

  Future<void> loadMore({int offset = 0, int take = 20}) async {
    if (state.isLoading) return;
    if (state.total > 0 && state.members.length >= state.total) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get(
        '/realms/$realmSlug/members',
        queryParameters: {'offset': offset, 'take': take},
      );

      final total = int.parse(response.headers.value('X-Total') ?? '0');
      final List<dynamic> data = response.data;
      final members = data.map((e) => SnRealmMember.fromJson(e)).toList();

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
    state = const RealmMemberState(members: [], isLoading: false, total: 0);
  }
}

class _RealmMemberListSheet extends HookConsumerWidget {
  final String realmSlug;
  const _RealmMemberListSheet({required this.realmSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realmIdentity = ref.watch(realmIdentityProvider(realmSlug));
    final memberListProvider = realmMemberListNotifierProvider(realmSlug);

    // For backward compatibility and to show total count in the header
    final memberState = ref.watch(realmMemberStateProvider(realmSlug));
    final memberNotifier = ref.read(
      realmMemberStateProvider(realmSlug).notifier,
    );

    useEffect(() {
      Future(() {
        memberNotifier.loadMore();
      });
      return null;
    }, []);

    Future<void> invitePerson() async {
      final result = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.post(
          '/realms/invites/$realmSlug',
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
                    // Refresh both providers
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
                          if ((realmIdentity.value?.role ?? 0) >= 50)
                            IconButton(
                              icon: const Icon(Symbols.edit),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder:
                                      (context) => _RealmMemberRoleSheet(
                                        realmSlug: realmSlug,
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
                                    final apiClient = ref.watch(
                                      apiClientProvider,
                                    );
                                    await apiClient.delete(
                                      '/realms/$realmSlug/members/${member.accountId}',
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

class RealmMemberState {
  final List<SnRealmMember> members;
  final bool isLoading;
  final int total;
  final String? error;

  const RealmMemberState({
    required this.members,
    required this.isLoading,
    required this.total,
    this.error,
  });

  RealmMemberState copyWith({
    List<SnRealmMember>? members,
    bool? isLoading,
    int? total,
    String? error,
  }) {
    return RealmMemberState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      total: total ?? this.total,
      error: error ?? this.error,
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
                        '/realms/$realmSlug/members/${member.accountId}/role',
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
