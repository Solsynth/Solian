import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/developers_models/custom_app_secret.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_secrets.g.dart';

@riverpod
Future<List<CustomAppSecret>> customAppSecrets(
  Ref ref,
  String publisherName,
  String projectId,
  String appId,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get(
    '/develop/developers/$publisherName/projects/$projectId/apps/$appId/secrets',
  );
  return (resp.data as List)
      .map((e) => CustomAppSecret.fromJson(e))
      .cast<CustomAppSecret>()
      .toList();
}

class AppSecretsScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;
  final String appId;

  const AppSecretsScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    required this.appId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secrets = ref.watch(
      customAppSecretsProvider(publisherName, projectId, appId),
    );

    void showNewSecretSheet(String newSecret) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SheetScaffold(
          titleText: 'newSecretGenerated'.tr(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('copySecretHint'.tr()),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(newSecret),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: newSecret));
                  },
                  icon: const Icon(Symbols.copy_all),
                  label: Text('copy'.tr()),
                ),
              ],
            ),
          ),
        ),
      ).whenComplete(() {
        ref.invalidate(
          customAppSecretsProvider(publisherName, projectId, appId),
        );
      });
    }

    void createSecret() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return HookBuilder(
            builder: (context) {
              final descriptionController = useTextEditingController();
              final expiresInController = useTextEditingController();
              final isOidc = useState(false);

              return SheetScaffold(
                titleText: 'generateSecret'.tr(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'description'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                        autofocus: true,
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: expiresInController,
                        decoration: InputDecoration(
                          labelText: 'expiresIn'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const Gap(16),
                      Card(
                        margin: EdgeInsets.zero,
                        child: SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text('isOidc'.tr()),
                          value: isOidc.value,
                          onChanged: (value) => isOidc.value = value,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () async {
                          final description = descriptionController.text;
                          final expiresIn = int.tryParse(
                            expiresInController.text,
                          );
                          Navigator.pop(context); // Close the sheet
                          try {
                            final client = ref.read(apiClientProvider);
                            final resp = await client.post(
                              '/develop/developers/$publisherName/projects/$projectId/apps/$appId/secrets',
                              data: {
                                'description': description,
                                'expires_in': expiresIn,
                                'is_oidc': isOidc.value,
                              },
                            );
                            final newSecret = CustomAppSecret.fromJson(
                              resp.data,
                            );
                            if (newSecret.secret != null) {
                              showNewSecretSheet(newSecret.secret!);
                            }
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
              );
            },
          );
        },
      );
    }

    return secrets.when(
      data: (data) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(
            customAppSecretsProvider(publisherName, projectId, appId).future,
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Symbols.add),
                title: Text('generateSecret'.tr()),
                onTap: createSecret,
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final secret = data[index];
                    return ListTile(
                      title: Text(secret.description ?? secret.id),
                      subtitle: Text(
                        'createdAt'.tr(args: [secret.createdAt.formatSystem()]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Symbols.delete, color: Colors.red),
                            onPressed: () {
                              showConfirmAlert(
                                'deleteSecretHint'.tr(),
                                'deleteSecret'.tr(),
                                isDanger: true,
                              ).then((confirm) {
                                if (confirm) {
                                  final client = ref.read(apiClientProvider);
                                  client.delete(
                                    '/develop/developers/$publisherName/projects/$projectId/apps/$appId/secrets/${secret.id}',
                                  );
                                  ref.invalidate(
                                    customAppSecretsProvider(
                                      publisherName,
                                      projectId,
                                      appId,
                                    ),
                                  );
                                }
                              });
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
        onRetry: () => ref.invalidate(
          customAppSecretsProvider(publisherName, projectId, appId),
        ),
      ),
    );
  }
}
