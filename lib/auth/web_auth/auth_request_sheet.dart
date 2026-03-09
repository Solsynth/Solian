import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/auth/web_auth/web_auth_app_info.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:styled_widget/styled_widget.dart';

class AuthRequestSheet extends ConsumerWidget {
  final WebAuthAppInfo app;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const AuthRequestSheet({
    super.key,
    required this.app,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return SheetScaffold(
      titleText: 'Authentication Request',
      heightFactor: isMobile ? 0.95 : 0.82,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: app.picture != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CloudFileWidget(
                                      item: app.picture!,
                                      noBlurhash: true,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.apps, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: [
                                    Text(
                                      app.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (app.verification != null)
                                      VerificationMark(mark: app.verification!),
                                  ],
                                ),
                                Text(
                                  app.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Gap(8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Text('from'),
                                    ProfilePictureWidget(
                                      file: app
                                          .project
                                          .developer
                                          .publisher
                                          ?.picture,
                                      radius: 8,
                                    ),
                                    Text(app.project.developer.publisher!.nick),
                                    if (app
                                            .project
                                            .developer
                                            .publisher!
                                            .verification !=
                                        null)
                                      VerificationMark(
                                        mark: app
                                            .project
                                            .developer
                                            .publisher!
                                            .verification!,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ProfilePictureWidget(
                                file: userInfo.value?.profile.picture,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You will approve this request as',
                                  ).fontSize(13).opacity(0.75),
                                  AccountName(account: userInfo.value!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This app will have access to your Solar Network account with your current session.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDeny,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Deny'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAllow,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Allow'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
