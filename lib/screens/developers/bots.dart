import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/bot.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bots.g.dart';

@riverpod
Future<List<Bot>> bots(Ref ref, String publisherName, {String? appId}) async {
  final client = ref.watch(apiClientProvider);
  final queryParams = {
    'publisher': publisherName,
    if (appId != null) 'app_id': appId,
  };
  final resp = await client.get('/develop/bots', queryParameters: queryParams);
  return resp.data.map((e) => Bot.fromJson(e)).cast<Bot>().toList();
}

class BotsScreen extends HookConsumerWidget {
  final String publisherName;
  final String? appId;
  const BotsScreen({super.key, required this.publisherName, this.appId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botsList = ref.watch(botsProvider(publisherName, appId: appId));

    return AppScaffold(
      appBar: AppBar(
        title: Text('bots').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              context.pushNamed(
                'developerBotNew',
                pathParameters: {
                  'name': publisherName,
                  if (appId != null) 'appId': appId!,
                },
              );
            },
          ),
        ],
      ),
      body: botsList.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text('noBots').tr());
          }
          return RefreshIndicator(
            onRefresh:
                () => ref.refresh(
                  botsProvider(publisherName, appId: appId).future,
                ),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final bot = data[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child:
                          bot.picture != null
                              ? CloudFileWidget(item: bot.picture!)
                              : const Icon(Symbols.smart_toy),
                    ),
                    title: Text(bot.name),
                    subtitle: Text(bot.description ?? ''),
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
                            'developerBotEdit',
                            pathParameters: {
                              'name': publisherName,
                              'id': bot.id,
                              if (appId != null) 'appId': appId!,
                            },
                          );
                        } else if (value == 'delete') {
                          showConfirmAlert(
                            'deleteBotHint'.tr(),
                            'deleteBot'.tr(),
                          ).then((confirm) {
                            if (confirm) {
                              final client = ref.read(apiClientProvider);
                              client.delete('/develop/bots/${bot.id}');
                              ref.invalidate(
                                botsProvider(publisherName, appId: appId),
                              );
                            }
                          });
                        }
                      },
                    ),
                    onTap: () {
                      context.pushNamed(
                        'developerBotDetail',
                        pathParameters: {
                          'name': publisherName,
                          'id': bot.id,
                          if (appId != null) 'appId': appId!,
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
              onRetry:
                  () =>
                      ref.invalidate(botsProvider(publisherName, appId: appId)),
            ),
      ),
    );
  }
}
