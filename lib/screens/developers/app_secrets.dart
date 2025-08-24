import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/custom_app_secret.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/response.dart';
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

    Future<void> generateSecret() async {
      final client = ref.read(apiClientProvider);
      try {
        showLoadingModal(context);
        await client
            .post(
              '/develop/developers/$publisherName/projects/$projectId/apps/$appId/secrets',
            )
            .then((_) {
              ref.invalidate(
                customAppSecretsProvider(publisherName, projectId, appId),
              );
            });
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return secrets.when(
      data: (data) {
        return RefreshIndicator(
          onRefresh:
              () => ref.refresh(
                customAppSecretsProvider(
                  publisherName,
                  projectId,
                  appId,
                ).future,
              ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Symbols.add),
                trailing: const Icon(Symbols.chevron_right),
                title: Text('appSecretsGenerate').tr(),
                onTap: generateSecret,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final secret = data[index];
                    return ListTile(
                      title: Text(secret.id),
                      subtitle: Text(
                        'created_at'.tr(
                          args: [secret.createdAt.toIso8601String()],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Symbols.copy_all),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: secret.secret),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('secretCopied'.tr())),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Symbols.delete, color: Colors.red),
                            onPressed: () {
                              showConfirmAlert(
                                'deleteSecretHint'.tr(),
                                'deleteSecret'.tr(),
                              ).then((confirm) {
                                if (confirm) {
                                  final client = ref.read(apiClientProvider);
                                  client
                                      .delete(
                                        '/develop/developers/$publisherName/projects/$projectId/apps/$appId/secrets/${secret.id}',
                                      )
                                      .then((_) {
                                        ref.invalidate(
                                          customAppSecretsProvider(
                                            publisherName,
                                            projectId,
                                            appId,
                                          ),
                                        );
                                      });
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
      error:
          (err, stack) => ResponseErrorWidget(
            error: err,
            onRetry:
                () => ref.invalidate(
                  customAppSecretsProvider(publisherName, projectId, appId),
                ),
          ),
    );
  }
}
