import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/developer.dart';
import 'package:island/models/publisher.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'hub.g.dart';

@riverpod
Future<DeveloperStats?> developerStats(Ref ref, String? uname) async {
  if (uname == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/develop/developers/$uname/stats');
  return DeveloperStats.fromJson(resp.data);
}

@riverpod
Future<List<SnDeveloper>> developers(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/develop/developers');
  return resp.data
      .map((e) => SnDeveloper.fromJson(e))
      .cast<SnDeveloper>()
      .toList();
}

class DeveloperHubShellScreen extends StatelessWidget {
  final Widget child;
  const DeveloperHubShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = isWideScreen(context);
    if (isWide) {
      return AppBackground(
        isRoot: true,
        child: Row(
          children: [
            Flexible(flex: 2, child: const DeveloperHubScreen(isAside: true)),
            const VerticalDivider(width: 1),
            Flexible(flex: 3, child: child),
          ],
        ),
      );
    }
    return AppBackground(isRoot: true, child: child);
  }
}

class DeveloperHubScreen extends HookConsumerWidget {
  final bool isAside;
  const DeveloperHubScreen({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    if (isWide && !isAside) {
      return Container(color: Theme.of(context).colorScheme.surface);
    }

    final developers = ref.watch(developersProvider);
    final currentDeveloper = useState<SnDeveloper?>(
      developers.value?.firstOrNull,
    );

    final List<DropdownMenuItem<SnDeveloper>> developersMenu = developers.when(
      data:
          (data) =>
              data
                  .map(
                    (item) => DropdownMenuItem<SnDeveloper>(
                      value: item,
                      child: ListTile(
                        minTileHeight: 48,
                        leading: ProfilePictureWidget(
                          radius: 16,
                          fileId: item.publisher?.picture?.id,
                        ),
                        title: Text(item.publisher!.nick),
                        subtitle: Text('@${item.publisher!.name}'),
                        trailing:
                            currentDeveloper.value?.id == item.id
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

    final developerStats = ref.watch(
      developerStatsProvider(currentDeveloper.value?.publisher?.name),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: !isWide ? const PageBackButton() : null,
        title: Text('developerHub').tr(),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<SnDeveloper>(
              alignment: Alignment.centerRight,
              value: currentDeveloper.value,
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
              items: [...developersMenu],
              onChanged: (value) {
                currentDeveloper.value = value;
              },
              selectedItemBuilder: (context) {
                return [
                  ...developersMenu.map(
                    (e) => ProfilePictureWidget(
                      radius: 16,
                      fileId: e.value?.publisher?.picture?.id,
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
      body: developerStats.when(
        data:
            (stats) => SingleChildScrollView(
              child:
                  currentDeveloper.value == null
                      ? Column(
                        children: [
                          const Gap(24),
                          const Icon(Symbols.info, size: 32).padding(bottom: 4),
                          Text(
                            'developerHubUnselectedHint',
                            textAlign: TextAlign.center,
                          ).tr(),
                          const Gap(24),
                          const Divider(height: 1),
                          ...(developers.value?.map(
                                (developer) => ListTile(
                                  leading: ProfilePictureWidget(
                                    file: developer.publisher?.picture,
                                  ),
                                  title: Text(developer.publisher!.nick),
                                  subtitle: Text(
                                    '@${developer.publisher!.name}',
                                  ),
                                  onTap: () {
                                    currentDeveloper.value = developer;
                                  },
                                ),
                              ) ??
                              []),
                          ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Symbols.add),
                            ),
                            title: Text('enrollDeveloper').tr(),
                            subtitle: Text('enrollDeveloperHint').tr(),
                            trailing: const Icon(Symbols.chevron_right),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder:
                                    (_) => const _DeveloperEnrollmentSheet(),
                              ).then((value) {
                                if (value == true) {
                                  ref.invalidate(developersProvider);
                                }
                              });
                            },
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          if (stats != null)
                            _DeveloperStatsWidget(
                              stats: stats,
                            ).padding(vertical: 12, horizontal: 12),
                          ListTile(
                            minTileHeight: 48,
                            title: Text('customApps').tr(),
                            trailing: Icon(Symbols.chevron_right),
                            leading: const Icon(Symbols.apps),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            onTap: () {
                              context.pushNamed(
                                'developerApps',
                                pathParameters: {
                                  'name':
                                      currentDeveloper.value!.publisher!.name,
                                },
                              );
                            },
                          ),
                        ],
                      ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => ResponseErrorWidget(
              error: err,
              onRetry: () {
                ref.invalidate(
                  developerStatsProvider(
                    currentDeveloper.value?.publisher!.name,
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _DeveloperStatsWidget extends StatelessWidget {
  final DeveloperStats stats;
  const _DeveloperStatsWidget({required this.stats});

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
                  stats.totalCustomApps.toString(),
                  'totalCustomApps',
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

class _DeveloperEnrollmentSheet extends HookConsumerWidget {
  const _DeveloperEnrollmentSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);

    Future<void> enroll(SnPublisher publisher) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post('/develop/developers/${publisher.name}/enroll');
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'enrollDeveloper'.tr(),
      child: publishers.when(
        data:
            (items) =>
                items.isEmpty
                    ? Center(
                      child:
                          Text(
                            'noDevelopersToEnroll',
                            textAlign: TextAlign.center,
                          ).tr(),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final publisher = items[index];
                        return ListTile(
                          leading: ProfilePictureWidget(
                            fileId: publisher.picture?.id,
                            fallbackIcon: Symbols.group,
                          ),
                          title: Text(publisher.nick),
                          subtitle: Text('@${publisher.name}'),
                          onTap: () => enroll(publisher),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(publishersManagedProvider),
            ),
      ),
    );
  }
}
