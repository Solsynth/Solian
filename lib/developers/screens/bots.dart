import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/screens/edit_bot.dart';
import 'package:island/developers/screens/new_bot.dart';
import 'package:island/developers/models/bot.dart';
import 'package:island/core/network.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';

part 'bots.g.dart';

@riverpod
Future<List<Bot>> bots(Ref ref, String publisherName, String projectId) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/bots',
  );
  return (resp.data as List).map((e) => Bot.fromJson(e)).cast<Bot>().toList();
}

@RoutePage()
class BotsScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;
  const BotsScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botsList = ref.watch(botsProvider(publisherName, projectId));

    return botsList.when(
      data: (data) {
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('noBots').tr(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SheetScaffold(
                        titleText: 'createBot'.tr(),
                        child: DeveloperBotNewScreen(
                          publisherName: publisherName,
                          projectId: projectId,
                          isModal: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Symbols.add),
                  label: Text('createBot').tr(),
                ),
              ],
            ),
          );
        }
        return ExtendedRefreshIndicator(
          onRefresh: () =>
              ref.refresh(botsProvider(publisherName, projectId).future),
          child: Column(
            children: [
              const Gap(8),
              Card(
                child: ListTile(
                  title: Text('bots').tr().padding(horizontal: 8),
                  trailing: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => SheetScaffold(
                          titleText: 'createBot'.tr(),
                          child: DeveloperBotNewScreen(
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
                    final bot = data[index];
                    return Card(
                      child: Column(
                        children: [
                          if (bot.account.profile.background != null)
                            AspectRatio(
                              aspectRatio: 16 / 7,
                              child: CloudFileWidget(
                                item: bot.account.profile.background!,
                                fit: BoxFit.cover,
                              ).clipRRect(topLeft: 8, topRight: 8),
                            ),
                          ListTile(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            leading: ProfilePictureWidget(
                              fallbackIcon: Symbols.smart_toy,
                              file: bot.account.profile.picture,
                            ),
                            title: Text(bot.account.nick),
                            subtitle: Text(bot.account.name),
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
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => SheetScaffold(
                                      titleText: 'editBot'.tr(),
                                      child: DeveloperBotEditScreen(
                                        pubName: publisherName,
                                        projectId: projectId,
                                        id: bot.id,
                                        isModal: true,
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  showConfirmAlert(
                                    'deleteBotHint'.tr(),
                                    'deleteBot'.tr(),
                                    isDanger: true,
                                  ).then((confirm) {
                                    if (confirm) {
                                      final client = ref.read(
                                        apiClientProvider,
                                      );
                                      client.delete(
                                        '/develop/developers/$publisherName/projects/$projectId/bots/${bot.id}',
                                      );
                                      ref.invalidate(
                                        botsProvider(publisherName, projectId),
                                      );
                                    }
                                  });
                                }
                              },
                            ),
                            onTap: () {
                              context.router.push(
                                DeveloperBotDetailRoute(
                                  pubName: publisherName,
                                  projectId: projectId,
                                  botId: bot.id,
                                ),
                              );
                            },
                          ),
                        ],
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
      error: (err, stack) => ResponseErrorWidget(
        error: err,
        onRetry: () => ref.invalidate(botsProvider(publisherName, projectId)),
      ),
    );
  }
}
