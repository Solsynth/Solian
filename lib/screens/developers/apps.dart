import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/custom_app.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'apps.g.dart';

@riverpod
Future<List<CustomApp>> customApps(Ref ref, String publisherName) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/developers/$publisherName/apps');
  return resp.data.map((e) => CustomApp.fromJson(e)).cast<CustomApp>().toList();
}

class CustomAppsScreen extends HookConsumerWidget {
  final String publisherName;
  const CustomAppsScreen({super.key, required this.publisherName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(customAppsProvider(publisherName));

    return AppScaffold(
      appBar: AppBar(
        title: Text('customApps').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              context.pushNamed('developerAppNew', pathParameters: {'name': publisherName});
            },
          ),
        ],
      ),
      body: apps.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text('noCustomApps').tr());
          }
          return RefreshIndicator(
            onRefresh:
                () => ref.refresh(customAppsProvider(publisherName).future),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final app = data[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (app.background != null)
                              CloudFileWidget(
                                item: app.background!,
                                fit: BoxFit.cover,
                              ).clipRRect(topLeft: 8, topRight: 8),
                            if (app.picture != null)
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: ProfilePictureWidget(
                                  fileId: app.picture!.id,
                                  radius: 40,
                                  fallbackIcon: Symbols.apps,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(app.name),
                        subtitle: Text(
                          app.slug,
                          style: GoogleFonts.robotoMono(fontSize: 12),
                        ),
                        contentPadding: EdgeInsets.only(left: 20, right: 12),
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
                                      const Icon(
                                        Symbols.delete,
                                        color: Colors.red,
                                      ),
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
                              context.pushNamed('developerAppEdit', pathParameters: {'name': publisherName, 'id': app.id});
                            } else if (value == 'delete') {
                              showConfirmAlert(
                                'deleteCustomAppHint'.tr(),
                                'deleteCustomApp'.tr(),
                              ).then((confirm) {
                                if (confirm) {
                                  final client = ref.read(apiClientProvider);
                                  client.delete(
                                    '/developers/$publisherName/apps/${app.id}',
                                  );
                                  ref.invalidate(
                                    customAppsProvider(publisherName),
                                  );
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
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
              onRetry: () => ref.invalidate(customAppsProvider(publisherName)),
            ),
      ),
    );
  }
}
