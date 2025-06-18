import 'package:auto_route/auto_route.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'hub.g.dart';

@riverpod
Future<SnPublisherStats?> publisherStats(Ref ref, String? uname) async {
  if (uname == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/publishers/$uname/stats');
  return SnPublisherStats.fromJson(resp.data);
}

@RoutePage()
class CreatorHubShellScreen extends StatelessWidget {
  const CreatorHubShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = isWideScreen(context);
    if (isWide) {
      return Row(
        children: [
          SizedBox(width: 360, child: const CreatorHubScreen(isAside: true)),
          const VerticalDivider(width: 1),
          Expanded(child: AutoRouter()),
        ],
      );
    }
    return AutoRouter();
  }
}

@RoutePage()
class CreatorHubScreen extends HookConsumerWidget {
  final bool isAside;
  const CreatorHubScreen({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    if (isWide && !isAside) {
      return Container(color: Theme.of(context).colorScheme.surface);
    }

    final publishers = ref.watch(publishersManagedProvider);
    final currentPublisher = useState<SnPublisher?>(
      publishers.value?.firstOrNull,
    );

    void updatePublisher() {
      context.router
          .push(EditPublisherRoute(name: currentPublisher.value!.name))
          .then((value) async {
            if (value == null) return;
            final data = await ref.refresh(publishersManagedProvider.future);
            currentPublisher.value =
                data
                    .where((e) => e.id == currentPublisher.value!.id)
                    .firstOrNull;
          });
    }

    void deletePublisher() {
      showConfirmAlert('deletePublisherHint'.tr(), 'deletePublisher'.tr()).then(
        (confirm) {
          if (confirm) {
            final client = ref.watch(apiClientProvider);
            client.delete('/publishers/${currentPublisher.value!.name}');
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

    return AppScaffold(
      appBar: AppBar(
        leading: !isWide ? const PageBackButton() : null,
        title: Text('creatorHub').tr(),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<SnPublisher>(
              alignment: Alignment.centerRight,
              value: currentPublisher.value,
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
              items: [...publishersMenu],
              onChanged: (value) {
                currentPublisher.value = value;
              },
              selectedItemBuilder: (context) {
                return [
                  ...publishersMenu.map(
                    (e) => ProfilePictureWidget(
                      radius: 16,
                      fileId: e.value?.picture?.id,
                    ).center().padding(right: 8),
                  ),
                ];
              },
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: const EdgeInsets.only(left: 14, right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                width: 320,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 64,
                padding: EdgeInsets.only(left: 14, right: 14),
              ),
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 19,
                iconEnabledColor:
                    Theme.of(context).appBarTheme.foregroundColor!,
                iconDisabledColor:
                    Theme.of(context).appBarTheme.foregroundColor!,
              ),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: publisherStats.when(
        data:
            (stats) => SingleChildScrollView(
              child:
                  currentPublisher.value == null
                      ? Column(
                        children: [
                          const Gap(24),
                          const Icon(Symbols.info, size: 32).padding(bottom: 4),
                          Text(
                            'creatorHubUnselectedHint',
                            textAlign: TextAlign.center,
                          ).tr(),
                          const Gap(24),
                          const Divider(height: 1),
                          ...(publishers.value?.map(
                                (publisher) => ListTile(
                                  leading: ProfilePictureWidget(
                                    fileId: publisher.picture?.id,
                                  ),
                                  title: Text(publisher.nick),
                                  subtitle: Text('@${publisher.name}'),
                                  onTap: () {
                                    currentPublisher.value = publisher;
                                  },
                                ),
                              ) ??
                              []),
                          ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Symbols.add),
                            ),
                            title: Text('createPublisher').tr(),
                            subtitle: Text('createPublisherHint').tr(),
                            trailing: const Icon(Symbols.chevron_right),
                            onTap: () {
                              context.router.push(NewPublisherRoute()).then((
                                value,
                              ) {
                                if (value != null) {
                                  ref.invalidate(publishersManagedProvider);
                                }
                              });
                            },
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          if (stats != null)
                            _PublisherStatsWidget(
                              stats: stats,
                            ).padding(vertical: 12, horizontal: 12),
                          ListTile(
                            minTileHeight: 48,
                            title: Text('stickers').tr(),
                            trailing: Icon(Symbols.chevron_right),
                            leading: const Icon(Symbols.ar_stickers),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            onTap: () {
                              context.router.push(
                                StickersRoute(
                                  pubName: currentPublisher.value!.name,
                                ),
                              );
                            },
                          ),
                          ListTile(
                            minTileHeight: 48,
                            title: Text('posts').tr(),
                            trailing: Icon(Symbols.chevron_right),
                            leading: const Icon(Symbols.sticky_note_2),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            onTap: () {
                              context.router.push(
                                CreatorPostListRoute(
                                  pubName: currentPublisher.value!.name,
                                ),
                              );
                            },
                          ),
                          Divider(height: 1).padding(vertical: 8),
                          ListTile(
                            minTileHeight: 48,
                            title: Text('editPublisher').tr(),
                            trailing: Icon(Symbols.chevron_right),
                            leading: const Icon(Symbols.edit),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            onTap: () {
                              updatePublisher();
                            },
                          ),
                          ListTile(
                            minTileHeight: 48,
                            title: Text('deletePublisher').tr(),
                            trailing: Icon(Symbols.chevron_right),
                            leading: const Icon(Symbols.delete),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            onTap: () {
                              deletePublisher();
                            },
                          ),
                        ],
                      ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _PublisherStatsWidget extends StatelessWidget {
  final SnPublisherStats stats;
  const _PublisherStatsWidget({required this.stats});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                statValue,
                style: Theme.of(context).textTheme.headlineMedium,
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
    );
  }
}
