import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/developers_models/bot_key.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bot_keys.g.dart';

@riverpod
Future<List<SnAccountApiKey>> botKeys(
  Ref ref,
  String publisherName,
  String projectId,
  String botId,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/bots/$botId/keys',
  );
  return (resp.data as List).map((e) => SnAccountApiKey.fromJson(e)).toList();
}

class BotKeysScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;
  final String botId;

  const BotKeysScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    required this.botId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = ref.watch(botKeysProvider(publisherName, projectId, botId));
    final keyNameController = useTextEditingController();

    void showNewKeySheet(SnAccountApiKey newApiKey) {
      final token = newApiKey.key;
      if (token == null) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SheetScaffold(
          titleText: 'newKeyGenerated'.tr(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('copyKeyHint'.tr()),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(token),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                  },
                  icon: const Icon(Symbols.copy_all),
                  label: Text('copy'.tr()),
                ),
              ],
            ),
          ),
        ),
      ).whenComplete(() {
        ref.invalidate(botKeysProvider(publisherName, projectId, botId));
      });
    }

    void createKey() {
      keyNameController.clear();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SheetScaffold(
          heightFactor: 0.7,
          titleText: 'newBotKey'.tr(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: keyNameController,
                  decoration: InputDecoration(
                    labelText: 'keyName'.tr(),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () async {
                    if (keyNameController.text.isEmpty) return;
                    final keyName = keyNameController.text;
                    Navigator.pop(context); // Close the sheet
                    try {
                      final client = ref.read(apiClientProvider);
                      final resp = await client.post(
                        '/develop/developers/$publisherName/projects/$projectId/bots/$botId/keys',
                        data: {'label': keyName},
                      );
                      final newApiKey = SnAccountApiKey.fromJson(resp.data);
                      showNewKeySheet(newApiKey);
                    } catch (e) {
                      showErrorAlert(e.toString());
                    }
                  },
                  icon: const Icon(Symbols.add),
                  label: Text('create'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void rotateKey(String keyId) {
      showConfirmAlert('rotateBotKeyHint'.tr(), 'rotateBotKey'.tr()).then((
        confirm,
      ) async {
        if (confirm) {
          try {
            if (context.mounted) showLoadingModal(context);
            final client = ref.read(apiClientProvider);
            final resp = await client.post(
              '/develop/developers/$publisherName/projects/$projectId/bots/$botId/keys/$keyId/rotate',
            );
            final rotatedApiKey = SnAccountApiKey.fromJson(resp.data);
            showNewKeySheet(rotatedApiKey);
          } catch (err) {
            showErrorAlert(err.toString());
          } finally {
            if (context.mounted) hideLoadingModal(context);
          }
        }
      });
    }

    void revokeKey(String keyId) {
      showConfirmAlert(
        'revokeBotKeyHint'.tr(),
        'revokeBotKey'.tr(),
        isDanger: true,
      ).then((confirm) {
        if (confirm) {
          final client = ref.read(apiClientProvider);
          client
              .delete(
                '/develop/developers/$publisherName/projects/$projectId/bots/$botId/keys/$keyId',
              )
              .then((_) {
                ref.invalidate(
                  botKeysProvider(publisherName, projectId, botId),
                );
              })
              .catchError((err) {
                showErrorAlert(err.toString());
              });
        }
      });
    }

    return keys.when(
      data: (data) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Symbols.add),
              title: Text('newBotKey'.tr()),
              onTap: createKey,
            ),
            const Divider(height: 1),
            Expanded(
              child: data.isEmpty
                  ? Center(child: Text('noBotKeys'.tr()))
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        botKeysProvider(publisherName, projectId, botId).future,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final apiKey = data[index];
                          return ListTile(
                            title: Text(apiKey.label),
                            subtitle: Text(apiKey.createdAt.formatSystem()),
                            contentPadding: EdgeInsets.only(
                              left: 16,
                              right: 12,
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'rotate',
                                  child: Row(
                                    children: [
                                      const Icon(Symbols.refresh),
                                      const Gap(12),
                                      Text('rotateKey'.tr()),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'revoke',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Symbols.delete,
                                        color: Colors.red,
                                      ),
                                      const Gap(12),
                                      Text(
                                        'revoke'.tr(),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'rotate') {
                                  rotateKey(apiKey.id);
                                } else if (value == 'revoke') {
                                  revokeKey(apiKey.id);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ResponseErrorWidget(
        error: err,
        onRetry: () =>
            ref.invalidate(botKeysProvider(publisherName, projectId, botId)),
      ),
    );
  }
}
