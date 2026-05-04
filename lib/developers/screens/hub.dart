import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/developers/screens/project_detail_view.dart';
import 'package:island/developers/models/dev_project.dart';
import 'package:island/developers/models/developer.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'hub.g.dart';

@riverpod
Future<DeveloperStats?> developerStats(Ref ref, String? uname) async {
  if (uname == null) return null;
  final apiClient = ref.watch(solarNetworkClientProvider).dio;
  final resp = await apiClient.get('/develop/developers/$uname/stats');
  return DeveloperStats.fromJson(resp.data);
}

@riverpod
Future<List<SnDeveloper>> developers(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider).dio;
  final resp = await client.get('/develop/developers');
  return resp.data
      .map((e) => SnDeveloper.fromJson(e))
      .cast<SnDeveloper>()
      .toList();
}

@riverpod
Future<List<SnDevProject>> devProjects(Ref ref, String pubName) async {
  if (pubName.isEmpty) return [];
  final client = ref.watch(solarNetworkClientProvider).dio;
  final resp = await client.get('/develop/developers/$pubName/projects');
  return (resp.data as List)
      .map((e) => SnDevProject.fromJson(e))
      .cast<SnDevProject>()
      .toList();
}

@RoutePage()
class DeveloperHubListScreen extends StatelessWidget {
  const DeveloperHubListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isWideScreen(context)) return const SizedBox.shrink();
    return const DeveloperHubContentWidget();
  }
}

class _ConsoleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SnDeveloper? currentDeveloper;
  final ValueChanged<SnDeveloper?> onDeveloperChanged;

  const _ConsoleAppBar({
    required this.currentDeveloper,
    required this.onDeveloperChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Symbols.menu),
        onPressed: () {
          rootScaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Text('developerHub').tr(),
      actions: [
        DeveloperSelector(
          isReadOnly: false,
          currentDeveloper: currentDeveloper,
          onDeveloperChanged: (value) {
            // Close all nested routes and clear project focus when switching developers
            context.router.navigate(const DeveloperHubListRoute());
            onDeveloperChanged(value);
          },
        ),
        const Gap(8),
      ],
    );
  }
}

// Main Content Section
class _MainContentSection extends HookConsumerWidget {
  final SnDeveloper? currentDeveloper;
  final AsyncValue<List<SnDevProject>> projects;
  final AsyncValue<DeveloperStats?> developerStats;
  final ValueChanged<SnDevProject> onProjectSelected;
  final ValueChanged<SnDeveloper> onDeveloperSelected;
  final VoidCallback onCreateProject;

  const _MainContentSection({
    required this.currentDeveloper,
    required this.projects,
    required this.developerStats,
    required this.onProjectSelected,
    required this.onDeveloperSelected,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: developerStats.when(
        data: (stats) => currentDeveloper == null
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 640),
                child: _DeveloperUnselectedWidget(
                  onDeveloperSelected: onDeveloperSelected,
                ),
              ).alignment(Alignment.topCenter)
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Developer Stats
                    if (stats != null) ...[
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Gap(16),
                      _DeveloperStatsWidget(stats: stats),
                      const Gap(24),
                    ],

                    // Projects Section
                    Row(
                      children: [
                        Text(
                          'Projects',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: onCreateProject,
                          icon: const Icon(Symbols.add),
                          label: const Text('Create Project'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),

                    // Projects List
                    projects.value?.isNotEmpty ?? false
                        ? Column(
                            children: projects.value!
                                .map(
                                  (project) => _ProjectListTile(
                                    project: project,
                                    publisherName:
                                        currentDeveloper!.publisher!.name,
                                    onProjectSelected: onProjectSelected,
                                  ),
                                )
                                .toList(),
                          )
                        : Container(
                            padding: const EdgeInsets.all(48),
                            alignment: Alignment.center,
                            child: Text(
                              'No projects available',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ResponseErrorWidget(
          error: err,
          onRetry: () {
            ref.invalidate(
              developerStatsProvider(currentDeveloper?.publisher?.name),
            );
          },
        ),
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

    final List<DropdownItem<SnDeveloper>> developersMenu = developers.when(
      data: (data) => data
          .map(
            (item) => DropdownItem<SnDeveloper>(
              height: 54,
              value: item,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.publisher?.nick ?? '',
                    style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '@${item.publisher?.name ?? ''}',
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
      loading: () => [],
      error: (_, _) => [],
    );

    if (isReadOnly || currentDeveloper == null) {
      return ProfilePictureWidget(
        radius: 16,
        file: currentDeveloper?.publisher?.picture,
      ).center().padding(right: 8);
    }

    // Ensure the selected value is valid
    final currentValue = currentDeveloper;
    final isValueValid =
        currentValue != null &&
        developersMenu.any((item) => item.value?.id == currentValue.id);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<SnDeveloper>(
        valueListenable: ValueNotifier<SnDeveloper?>(
          isValueValid ? currentValue : null,
        ),
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
                file: isValueValid ? currentValue.publisher?.picture : null,
              ),
              Flexible(
                child: Text(
                  isValueValid
                      ? currentValue.publisher!.nick
                      : 'Select Developer',
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
        items: developersMenu,
        onChanged: onDeveloperChanged,
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}

class ProjectSelector extends HookConsumerWidget {
  final SnDeveloper? currentDeveloper;
  final SnDevProject? currentProject;
  final ValueChanged<SnDevProject?> onProjectChanged;

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

    // Ensure the selected value is valid
    final currentValue = currentProject;
    final isValueValid =
        currentValue != null &&
        projects.value!.any((p) => p.id == currentValue.id);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<SnDevProject>(
        valueListenable: ValueNotifier(isValueValid ? currentValue : null),
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
              Expanded(
                child: Text(
                  isValueValid ? currentValue.name : 'Select Project',
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
        items: projects.value!
            .map(
              (project) => DropdownItem<SnDevProject>(
                value: project,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name,
                      style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (project.description.isNotEmpty)
                      Text(
                        project.description,
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
        onChanged: onProjectChanged,
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}

class _ProjectListTile extends HookConsumerWidget {
  final SnDevProject project;
  final String publisherName;
  final ValueChanged<SnDevProject>? onProjectSelected;

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
      subtitle: Text(project.description),
      contentPadding: const EdgeInsets.only(left: 16, right: 17),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
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
                Text('delete', style: const TextStyle(color: Colors.red)).tr(),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'edit') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SheetScaffold(
                titleText: 'editProject'.tr(),
                child: ProjectForm(
                  publisherName: publisherName,
                  project: project,
                ),
              ),
            ).then((value) {
              if (value != null) {
                ref.invalidate(devProjectsProvider(publisherName));
              }
            });
          } else if (value == 'delete') {
            showConfirmAlert(
              'deleteProjectHint'.tr(),
              'deleteProject'.tr(),
              isDanger: true,
            ).then((confirm) {
              if (confirm) {
                final client = ref.read(solarNetworkClientProvider).dio;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasDevelopers) ...[
            if (developers.isLoading)
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
                  'developerHubUnselectedHint',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ).tr(),
              ]),
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

class ProjectForm extends HookConsumerWidget {
  final String publisherName;
  final SnDevProject? project;

  const ProjectForm({super.key, required this.publisherName, this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = project != null;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: project?.name ?? '');
    final slugController = useTextEditingController(text: project?.slug ?? '');
    final descriptionController = useTextEditingController(
      text: project?.description ?? '',
    );
    final submitting = useState(false);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        submitting.value = true;
        final client = ref.read(apiClientProvider);
        final data = {
          'name': nameController.text,
          'slug': slugController.text,
          'description': descriptionController.text,
        };

        final resp = isEditing
            ? await client.put(
                '/develop/developers/$publisherName/projects/${project!.id}',
                data: data,
              )
            : await client.post(
                '/develop/developers/$publisherName/projects',
                data: data,
              );

        if (!context.mounted) return;
        Navigator.of(context).pop(SnDevProject.fromJson(resp.data));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return Column(
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'name'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'fieldCannotBeEmpty'.tr();
                  }
                  return null;
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              TextFormField(
                controller: slugController,
                decoration: InputDecoration(
                  labelText: 'slug'.tr(),

                  helperText: 'slugHint'.tr(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'fieldCannotBeEmpty'.tr();
                  }
                  return null;
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'description'.tr(),

                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: null,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
        ),
        const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: submitting.value ? null : submit,
            icon: const Icon(Symbols.save),
            label: Text(isEditing ? 'saveChanges'.tr() : 'create'.tr()),
          ),
        ),
      ],
    ).padding(horizontal: 24, vertical: 16);
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
        data: (items) => items.isEmpty
            ? Center(
                child: Text(
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
                      file: publisher.picture,
                      fallbackIcon: Symbols.group,
                    ),
                    title: Text(publisher.nick),
                    subtitle: Text('@${publisher.name}'),
                    onTap: () => enroll(publisher),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(publishersManagedProvider),
        ),
      ),
    );
  }
}

// Extracted widget for the Developer Hub content
class DeveloperHubContentWidget extends HookConsumerWidget {
  final String? initialPublisherName;
  final String? initialProjectId;

  const DeveloperHubContentWidget({
    super.key,
    this.initialPublisherName,
    this.initialProjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final developers = ref.watch(developersProvider);
    final currentDeveloper = useState<SnDeveloper?>(
      developers.value?.firstOrNull,
    );

    final projects = currentDeveloper.value?.publisher?.name != null
        ? ref.watch(
            devProjectsProvider(currentDeveloper.value!.publisher!.name),
          )
        : const AsyncValue<List<SnDevProject>>.data([]);

    final currentProject = useState<SnDevProject?>(
      projects.value?.where((p) => p.id == initialProjectId).firstOrNull,
    );

    final developerStats = ref.watch(
      developerStatsProvider(currentDeveloper.value?.publisher?.name),
    );

    return AppScaffold(
      appBar: _ConsoleAppBar(
        currentDeveloper: currentDeveloper.value,
        onDeveloperChanged: (value) {
          currentDeveloper.value = value;
          currentProject.value = null;
        },
      ),
      body: Column(
        children: [
          // Main Content
          if (currentProject.value != null)
            Expanded(
              child: ProjectDetailView(
                publisherName: currentDeveloper.value!.publisher!.name,
                project: currentProject.value!,
                onBackToHub: () {
                  currentProject.value = null;
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: _MainContentSection(
                  currentDeveloper: currentDeveloper.value,
                  projects: projects,
                  developerStats: developerStats,
                  onProjectSelected: (project) {
                    currentProject.value = project;
                  },
                  onDeveloperSelected: (developer) {
                    currentDeveloper.value = developer;
                    currentProject.value = null;
                  },
                  onCreateProject: () {
                    if (currentDeveloper.value != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => SheetScaffold(
                          titleText: 'createProject'.tr(),
                          child: ProjectForm(
                            publisherName:
                                currentDeveloper.value!.publisher!.name,
                          ),
                        ),
                      ).then((value) {
                        if (value != null) {
                          ref.invalidate(
                            devProjectsProvider(
                              currentDeveloper.value!.publisher!.name,
                            ),
                          );
                        }
                      });
                    }
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: currentDeveloper.value != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: BottomAppBar(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'project',
                      style: Theme.of(context).textTheme.labelMedium,
                    ).tr(),
                    const Gap(8),
                    Expanded(
                      child: ProjectSelector(
                        currentDeveloper: currentDeveloper.value,
                        currentProject: currentProject.value,
                        onProjectChanged: (value) {
                          // Close all nested routes when switching projects
                          context.router.navigate(
                            const DeveloperHubListRoute(),
                          );
                          currentProject.value = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

@RoutePage()
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

    return AppBackground(
      isRoot: true,
      child: isWide
          ? SafeArea(
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: DeveloperHubContentWidget(
                        initialPublisherName: initialPublisherName,
                        initialProjectId: initialProjectId,
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
              ),
            )
          : const AutoRouter(),
    );
  }
}
