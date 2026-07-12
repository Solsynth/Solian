import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/discovery/search.dart';
import 'package:island/realms/widgets/realm_list_tile.dart';
import 'package:island/realms/widgets/realm_tile.dart';
import 'package:island/realms/widgets/realm_form_content.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'realms.g.dart';

@riverpod
Future<List<SnRealm>> realmsJoined(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.realms.getRealms();
  return resp.items;
}

@riverpod
Future<SnRealm?> realm(Ref ref, String? identifier) async {
  if (identifier == null) return null;
  final client = ref.watch(solarNetworkClientProvider);
  return await client.realms.getRealm(identifier);
}

@RoutePage()
class RealmListScreen extends HookConsumerWidget {
  const RealmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realms = ref.watch(realmsJoinedProvider);
    final realmInvites = ref.watch(realmInvitesProvider);
    final userInfo = ref.watch(userInfoProvider);
    final realmDisplayMode = ref.watch(
      appSettingsProvider.select((settings) => settings.realmDisplayMode),
    );
    final isCardMode = realmDisplayMode == kRealmDisplayModeCard;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: const Text('realms').tr(),
        actions: [
          IconButton(
            icon: Icon(isCardMode ? Symbols.view_list : Symbols.grid_view),
            tooltip:
                (isCardMode
                        ? 'realmSwitchToListView'
                        : 'realmSwitchToCardView')
                    .tr(),
            onPressed: () {
              ref
                  .read(appSettingsProvider.notifier)
                  .setRealmDisplayMode(
                    isCardMode ? kRealmDisplayModeList : kRealmDisplayModeCard,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Symbols.travel_explore),
            onPressed: () => context.router.push(
              UniversalSearchRoute(initialTab: SearchTab.realms),
            ),
          ),
          IconButton(
            icon: Badge(
              label: Text(
                realmInvites.when(
                  data: (invites) => invites.length.toString(),
                  error: (_, _) => '0',
                  loading: () => '0',
                ),
              ),
              isLabelVisible: realmInvites.when(
                data: (invites) => invites.isNotEmpty,
                error: (_, _) => false,
                loading: () => false,
              ),
              child: const Icon(Symbols.email),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (_) => const _RealmInviteSheet(),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: userInfo.value != null
          ? FloatingActionButton(
              child: const Icon(Symbols.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => const _RealmCreateSheet(),
                );
              },
            ).padding(bottom: MediaQuery.of(context).padding.bottom)
          : null,
      body: userInfo.value == null
          ? const ResponseUnauthorizedWidget()
          : ExtendedRefreshIndicator(
              child: realms.when(
                data: (value) => Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: MediaQuery.of(context).padding.bottom + 8,
                        ),
                        itemCount: value.length,
                        itemBuilder: (context, item) {
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: isCardMode
                                ? RealmListTile(realm: value[item])
                                : RealmTile(realm: value[item]),
                          ).padding(horizontal: 8).center();
                        },
                        separatorBuilder: (_, _) => const Gap(8),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ResponseErrorWidget(
                  error: e,
                  onRetry: () => ref.invalidate(realmsJoinedProvider),
                ),
              ),
              onRefresh: () => ref.refresh(realmsJoinedProvider.future),
            ),
    );
  }
}

@riverpod
Future<List<SnRealmMember>> realmInvites(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get('/passport/realms/invites');
  return (resp.data as List).map((e) => SnRealmMember.fromJson(e)).toList();
}

class _RealmInviteSheet extends HookConsumerWidget {
  const _RealmInviteSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(realmInvitesProvider);

    Future<void> acceptInvite(SnRealmMember invite) async {
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.dio.post(
          '/passport/realms/invites/${invite.realm!.slug}/accept',
        );
        ref.invalidate(realmInvitesProvider);
        ref.invalidate(realmsJoinedProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> declineInvite(SnRealmMember invite) async {
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.dio.post(
          '/passport/realms/invites/${invite.realm!.slug}/decline',
        );
        ref.invalidate(realmInvitesProvider);
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
            ref.invalidate(realmInvitesProvider);
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
                      file: invite.realm!.picture,
                      fallbackIcon: Symbols.group,
                    ),
                    title: Text(invite.realm!.name),
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
          onRetry: () => ref.invalidate(realmInvitesProvider),
        ),
      ),
    );
  }
}

class _RealmCreateSheet extends HookConsumerWidget {
  const _RealmCreateSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: 'createRealm'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: RealmFormContent(
          isInSheet: true,
          onSubmit: () => ref.invalidate(realmsJoinedProvider),
        ),
      ),
    );
  }
}
