import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/dev_project.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'projects.g.dart';

@riverpod
Future<List<DevProject>> devProjects(Ref ref, String pubName) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/develop/developers/$pubName/projects');
  return (resp.data as List)
      .map((e) => DevProject.fromJson(e))
      .cast<DevProject>()
      .toList();
}

class DevProjectsScreen extends HookConsumerWidget {
  final String publisherName;
  const DevProjectsScreen({super.key, required this.publisherName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(devProjectsProvider(publisherName));

    return AppScaffold(
      appBar: AppBar(
        title: Text('projects').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              context.pushNamed(
                'developerProjectNew',
                pathParameters: {'name': publisherName},
              );
            },
          ),
        ],
      ),
      body: projects.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text('noProjects').tr());
          }
          return RefreshIndicator(
            onRefresh:
                () => ref.refresh(devProjectsProvider(publisherName).future),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final project = data[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: EdgeInsets.only(left: 20, right: 12),
                    title: Text(project.name),
                    subtitle: Text(project.description ?? ''),
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
                                    style: TextStyle(color: Colors.red),
                                  ).tr(),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.pushNamed(
                            'developerProjectEdit',
                            pathParameters: {
                              'name': publisherName,
                              'id': project.id,
                            },
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
                              ref.invalidate(
                                devProjectsProvider(publisherName),
                              );
                            }
                          });
                        }
                      },
                    ),
                    onTap: () {
                      context.pushNamed(
                        'developerProjectDetail',
                        pathParameters: {
                          'name': publisherName,
                          'projectId': project.id,
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(devProjectsProvider(publisherName)),
            ),
      ),
    );
  }
}
