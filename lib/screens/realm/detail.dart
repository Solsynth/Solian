import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/network.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/realm/realms.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'detail.g.dart';

@riverpod
Future<SnRealmMember?> realmIdentity(Ref ref, String realmSlug) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/realms/$realmSlug/members/me');
  return SnRealmMember.fromJson(response.data);
}

@RoutePage()
class RealmDetailScreen extends HookConsumerWidget {
  final String slug;
  const RealmDetailScreen({super.key, @PathParam("slug") required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realmState = ref.watch(realmProvider(slug));
    final realmIdentity = ref.watch(realmIdentityProvider(slug));

    final isModerator = realmIdentity.when(
      loading: () => false,
      error: (error, _) => false,
      data: (identity) => (identity?.role ?? 0) >= 50,
    );

    const iconShadow = Shadow(
      color: Colors.black54,
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
                  leading: PageBackButton(shadows: [iconShadow]),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        realm!.backgroundId != null
                            ? CloudImageWidget(fileId: realm.backgroundId!)
                            : Container(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                    title: Text(
                      realm.name,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        shadows: [iconShadow],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.people, shadows: [iconShadow]),
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
                    if (isModerator)
                      _RealmActionMenu(realmSlug: slug, iconShadow: iconShadow),
                    const Gap(8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          realm.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
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
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, shadows: [iconShadow]),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              onTap: () {
                context.router.replace(EditRealmRoute(slug: realmSlug));
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
            PopupMenuItem(
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
                    if (context.mounted) context.router.maybePop(true);
                  }
                });
              },
            ),
          ],
    );
  }
}

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
        memberNotifier.reset();
        await memberNotifier.loadMore();
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
            child:
                memberState.error != null
                    ? Center(child: Text(memberState.error!))
                    : ListView.builder(
                      itemCount: memberState.members.length + 1,
                      itemBuilder: (context, index) {
                        if (index == memberState.members.length) {
                          if (memberState.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (memberState.members.length < memberState.total) {
                            memberNotifier.loadMore(
                              offset: memberState.members.length,
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final member = memberState.members[index];
                        return ListTile(
                          leading: ProfilePictureWidget(
                            fileId: member.account!.profile.pictureId,
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
