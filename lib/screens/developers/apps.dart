import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/custom_app.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/developers/edit_app.dart';
import 'package:island/screens/developers/new_app.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'apps.g.dart';

@riverpod
Future<CustomApp> customApp(
  Ref ref,
  String publisherName,
  String projectId,
  String appId,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/apps/$appId',
  );
  return CustomApp.fromJson(resp.data);
}

@riverpod
Future<List<CustomApp>> customApps(
  Ref ref,
  String publisherName,
  String projectId,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/apps',
  );
  return (resp.data as List)
      .map((e) => CustomApp.fromJson(e))
      .cast<CustomApp>()
      .toList();
}

class CustomAppsScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;
  const CustomAppsScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(customAppsProvider(publisherName, projectId));

    return apps.when(
      data: (data) {
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('noCustomApps').tr(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (context) => SheetScaffold(
                            titleText: 'createCustomApp'.tr(),
                            child: NewCustomAppScreen(
                              publisherName: publisherName,
                              projectId: projectId,
                              isModal: true,
                            ),
                          ),
                    );
                  },
                  icon: const Icon(Symbols.add),
                  label: Text('createCustomApp').tr(),
                ),
              ],
            ),
          );
        }
        return ExtendedRefreshIndicator(
          onRefresh:
              () => ref.refresh(
                customAppsProvider(publisherName, projectId).future,
              ),
          child: Column(
            children: [
              const Gap(8),
              Card(
                child: ListTile(
                  title: Text('customApps').tr().padding(horizontal: 8),
                  trailing: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (context) => SheetScaffold(
                              titleText: 'createCustomApp'.tr(),
                              child: NewCustomAppScreen(
                                publisherName: publisherName,
                                projectId: projectId,
                                isModal: true,
                              ),
                            ),
                      );
                    },
                    icon: const Icon(Symbols.add),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final app = data[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(
                            'developerAppDetail',
                            pathParameters: {
                              'name': publisherName,
                              'projectId': projectId,
                              'appId': app.id,
                            },
                          );
                        },
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
                              contentPadding: EdgeInsets.only(
                                left: 20,
                                right: 12,
                              ),
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
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ).tr(),
                                          ],
                                        ),
                                      ),
                                    ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder:
                                          (context) => SheetScaffold(
                                            titleText: 'editCustomApp'.tr(),
                                            child: EditAppScreen(
                                              publisherName: publisherName,
                                              projectId: projectId,
                                              id: app.id,
                                              isModal: true,
                                            ),
                                          ),
                                    );
                                  } else if (value == 'delete') {
                                    showConfirmAlert(
                                      'deleteCustomAppHint'.tr(),
                                      'deleteCustomApp'.tr(),
                                    ).then((confirm) {
                                      if (confirm) {
                                        final client = ref.read(
                                          apiClientProvider,
                                        );
                                        client.delete(
                                          '/develop/developers/$publisherName/projects/$projectId/apps/${app.id}',
                                        );
                                        ref.invalidate(
                                          customAppsProvider(
                                            publisherName,
                                            projectId,
                                          ),
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => ResponseErrorWidget(
            error: err,
            onRetry:
                () => ref.invalidate(
                  customAppsProvider(publisherName, projectId),
                ),
          ),
    );
  }
}
