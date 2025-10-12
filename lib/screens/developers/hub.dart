import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/dev_project.dart';
import 'package:island/models/developer.dart';
import 'package:island/models/publisher.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers_form.dart';
import 'package:island/screens/developers/project_detail_view.dart';
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

@riverpod
Future<List<DevProject>> devProjects(Ref ref, String pubName) async {
  if (pubName.isEmpty) return [];
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/develop/developers/$pubName/projects');
  return (resp.data as List)
      .map((e) => DevProject.fromJson(e))
      .cast<DevProject>()
      .toList();
}

class DeveloperHubScreen extends HookConsumerWidget {
  final String? initialPublisherName;
  final String? initialProjectId;

  const DeveloperHubScreen({
    super.key,
    this.initialPublisherName,
    this.initialProjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final developers = ref.watch(developersProvider);
    final currentDeveloper = useState<SnDeveloper?>(
      developers.value?.firstOrNull,
    );

    final projects =
        currentDeveloper.value?.publisher?.name != null
            ? ref.watch(
              devProjectsProvider(currentDeveloper.value!.publisher!.name),
            )
            : const AsyncValue<List<DevProject>>.data([]);

    final currentProject = useState<DevProject?>(
      projects.value?.where((p) => p.id == initialProjectId).firstOrNull,
    );

    final developerStats = ref.watch(
      developerStatsProvider(currentDeveloper.value?.publisher?.name),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('Solar Network Cloud'),
        actions: [
          if (currentProject.value != null)
            ProjectSelector(
              currentDeveloper: currentDeveloper.value,
              currentProject: currentProject.value,
              onProjectChanged: (value) {
                currentProject.value = value;
              },
            ),
          if (!isWide)
            DeveloperSelector(
              isReadOnly: false,
              currentDeveloper: currentDeveloper.value,
              onDeveloperChanged: (value) {
                currentDeveloper.value = value;
              },
            ),
          const Gap(8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = isWide ? 800.0 : double.infinity;

          return Center(
            child:
                currentProject.value != null
                    ? ProjectDetailView(
                      publisherName: currentDeveloper.value!.publisher!.name,
                      project: currentProject.value!,
                      onBackToHub: () {
                        currentProject.value = null;
                      },
                    )
                    : ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: developerStats.when(
                        data:
                            (stats) => SingleChildScrollView(
                              child:
                                  currentDeveloper.value == null
                                      ? ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 640,
                                        ),
                                        child: _DeveloperUnselectedWidget(
                                          onDeveloperSelected: (developer) {
                                            currentDeveloper.value = developer;
                                          },
                                        ),
                                      ).center()
                                      : isWide
                                      ? Column(
                                        spacing: 8,
                                        children: [
                                          DeveloperSelector(
                                            isReadOnly: true,
                                            currentDeveloper:
                                                currentDeveloper.value,
                                            onDeveloperChanged: (value) {
                                              currentDeveloper.value = value;
                                            },
                                          ),
                                          if (stats != null)
                                            _DeveloperStatsWidget(
                                              stats: stats,
                                            ).padding(horizontal: 12),
                                          Card(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Symbols.folder_code,
                                                      ),
                                                      const Gap(12),
                                                      Text(
                                                        'projects',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .titleMedium,
                                                      ).tr(),
                                                      const Spacer(),
                                                      IconButton(
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        icon: const Icon(
                                                          Symbols.add,
                                                        ),
                                                        onPressed: () {
                                                          context.pushNamed(
                                                            'developerProjectNew',
                                                            pathParameters: {
                                                              'name':
                                                                  currentDeveloper
                                                                      .value!
                                                                      .publisher!
                                                                      .name,
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (projects
                                                        .value
                                                        ?.isNotEmpty ??
                                                    false)
                                                  ...(projects.value?.map(
                                                        (
                                                          project,
                                                        ) => _ProjectListTile(
                                                          project: project,
                                                          publisherName:
                                                              currentDeveloper
                                                                  .value!
                                                                  .publisher!
                                                                  .name,
                                                          onProjectSelected: (
                                                            selectedProject,
                                                          ) {
                                                            currentProject
                                                                    .value =
                                                                selectedProject;
                                                          },
                                                        ),
                                                      ) ??
                                                      [])
                                                else
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    child: Center(
                                                      child:
                                                          Text(
                                                            'noProjects',
                                                          ).tr(),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                      : Column(
                                        spacing: 12,
                                        children: [
                                          if (stats != null)
                                            _DeveloperStatsWidget(
                                              stats: stats,
                                            ).padding(horizontal: 16),
                                          Card(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'projects',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .titleMedium,
                                                      ).tr(),
                                                      const Spacer(),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Symbols.add,
                                                        ),
                                                        onPressed: () {
                                                          context.pushNamed(
                                                            'developerProjectNew',
                                                            pathParameters: {
                                                              'name':
                                                                  currentDeveloper
                                                                      .value!
                                                                      .publisher!
                                                                      .name,
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (projects
                                                        .value
                                                        ?.isNotEmpty ??
                                                    false)
                                                  ...(projects.value?.map(
                                                        (
                                                          project,
                                                        ) => _ProjectListTile(
                                                          project: project,
                                                          publisherName:
                                                              currentDeveloper
                                                                  .value!
                                                                  .publisher!
                                                                  .name,
                                                          onProjectSelected: (
                                                            selectedProject,
                                                          ) {
                                                            currentProject
                                                                    .value =
                                                                selectedProject;
                                                          },
                                                        ),
                                                      ) ??
                                                      [])
                                                else
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    child: Center(
                                                      child:
                                                          Text(
                                                            'noProjects',
                                                          ).tr(),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
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
                    ),
          );
        },
      ),
    );
  }
}

class DeveloperSelector extends HookConsumerWidget {
  final bool isReadOnly;
  final SnDeveloper? currentDeveloper;
  final ValueChanged<SnDeveloper?> onDeveloperChanged;

  const DeveloperSelector({
    super.key,
    required this.isReadOnly,
    required this.currentDeveloper,
    required this.onDeveloperChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final developers = ref.watch(developersProvider);

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
                            currentDeveloper?.id == item.id
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

    if (isReadOnly || currentDeveloper == null) {
      return ProfilePictureWidget(
        radius: 16,
        fileId: currentDeveloper?.publisher?.picture?.id,
      ).center().padding(right: 8);
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton2<SnDeveloper>(
        alignment: Alignment.centerRight,
        value: currentDeveloper,
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
        onChanged: onDeveloperChanged,
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
          iconEnabledColor: Theme.of(context).appBarTheme.foregroundColor!,
          iconDisabledColor: Theme.of(context).appBarTheme.foregroundColor!,
        ),
      ),
    );
  }
}

class ProjectSelector extends HookConsumerWidget {
  final SnDeveloper? currentDeveloper;
  final DevProject? currentProject;
  final ValueChanged<DevProject?> onProjectChanged;

  const ProjectSelector({
    super.key,
    required this.currentDeveloper,
    required this.currentProject,
    required this.onProjectChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentDeveloper == null) {
      return const SizedBox.shrink();
    }

    final projects = ref.watch(
      devProjectsProvider(currentDeveloper!.publisher!.name),
    );

    if (projects.value == null) {
      return const SizedBox.shrink();
    }

    final List<DropdownMenuItem<DevProject>> projectsMenu =
        projects.value!
            .map(
              (item) => DropdownMenuItem<DevProject>(
                value: item,
                child: ListTile(
                  minTileHeight: 48,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    item.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      currentProject?.id == item.id
                          ? const Icon(Icons.check)
                          : null,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            )
            .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton2<DevProject>(
        value: currentProject,
        hint: CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            '?',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ).center().padding(right: 8),
        items: projectsMenu,
        onChanged: onProjectChanged,
        selectedItemBuilder: (context) {
          final isWider = isWiderScreen(context);
          return projectsMenu
              .map(
                (e) =>
                    isWider
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                e.value?.name.isNotEmpty ?? false
                                    ? e.value!.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Text(
                              e.value?.name ?? '?',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ],
                        ).padding(right: 8)
                        : CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            e.value?.name.isNotEmpty ?? false
                                ? e.value!.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
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
          iconEnabledColor: Theme.of(context).appBarTheme.foregroundColor!,
          iconDisabledColor: Theme.of(context).appBarTheme.foregroundColor!,
        ),
      ),
    );
  }
}

class _ProjectListTile extends HookConsumerWidget {
  final DevProject project;
  final String publisherName;
  final ValueChanged<DevProject>? onProjectSelected;

  const _ProjectListTile({
    required this.project,
    required this.publisherName,
    this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      leading: const Icon(Symbols.folder_managed),
      title: Text(project.name),
      subtitle: Text(project.description ?? ''),
      contentPadding: const EdgeInsets.only(left: 16, right: 17),
      trailing: PopupMenuButton(
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Symbols.edit),
                    const SizedBox(width: 12),
                    Text('edit').tr(),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Symbols.delete, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'delete',
                      style: const TextStyle(color: Colors.red),
                    ).tr(),
                  ],
                ),
              ),
            ],
        onSelected: (value) {
          if (value == 'edit') {
            context.pushNamed(
              'developerProjectEdit',
              pathParameters: {'name': publisherName, 'id': project.id},
            );
          } else if (value == 'delete') {
            showConfirmAlert(
              'deleteProjectHint'.tr(),
              'deleteProject'.tr(),
            ).then((confirm) {
              if (confirm) {
                final client = ref.read(apiClientProvider);
                client.delete(
                  '/develop/developers/$publisherName/projects/${project.id}',
                );
                ref.invalidate(devProjectsProvider(publisherName));
              }
            });
          }
        },
      ),
      onTap: () {
        onProjectSelected?.call(project);
      },
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

class _DeveloperUnselectedWidget extends HookConsumerWidget {
  final ValueChanged<SnDeveloper> onDeveloperSelected;

  const _DeveloperUnselectedWidget({required this.onDeveloperSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final developers = ref.watch(developersProvider);

    final hasDevelopers = developers.value?.isNotEmpty ?? false;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!hasDevelopers) ...[
            const Icon(
              Symbols.info,
              fill: 1,
              size: 32,
            ).padding(bottom: 6, top: 24),
            Text(
              'developerHubUnselectedHint',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ).tr(),
            const Gap(24),
          ],
          if (hasDevelopers)
            ...(developers.value?.map(
                  (developer) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    leading: ProfilePictureWidget(
                      file: developer.publisher?.picture,
                    ),
                    title: Text(developer.publisher!.nick),
                    subtitle: Text('@${developer.publisher!.name}'),
                    onTap: () => onDeveloperSelected(developer),
                  ),
                ) ??
                []),
          const Divider(height: 1),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            leading: const CircleAvatar(child: Icon(Symbols.add)),
            title: Text('enrollDeveloper').tr(),
            subtitle: Text('enrollDeveloperHint').tr(),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _DeveloperEnrollmentSheet(),
              ).then((value) {
                if (value == true) {
                  ref.invalidate(developersProvider);
                }
              });
            },
          ),
        ],
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
