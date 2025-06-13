import 'package:flutter/material.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountNameplate extends HookConsumerWidget {
  final String name;
  final bool isOutlined;
  final EdgeInsetsGeometry padding;

  const AccountNameplate({
    super.key,
    required this.name,
    this.isOutlined = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountProvider(name));

    return Container(
      decoration:
          isOutlined
              ? BoxDecoration(
                border: Border.all(
                  width: 1 / MediaQuery.of(context).devicePixelRatio,
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              )
              : null,
      margin: padding,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: user.when(
          data:
              (account) =>
                  account.profile.background != null
                      ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CloudFileWidget(
                                  item: account.profile.background!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Gradient overlay for text readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content positioned at the bottom
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    // Profile picture (equivalent to leading)
                                    ProfilePictureWidget(
                                      fileId: account.profile.picture?.id,
                                    ),
                                    const SizedBox(width: 16),
                                    // Text content (equivalent to title and subtitle)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AccountName(
                                            account: account,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '@${account.name}',
                                          ).textColor(Colors.white70),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration:
                            isOutlined
                                ? BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                )
                                : null,
                        child: Row(
                          children: [
                            // Profile picture (equivalent to leading)
                            ProfilePictureWidget(
                              fileId: account.profile.picture?.id,
                            ),
                            const SizedBox(width: 16),
                            // Text content (equivalent to title and subtitle)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AccountName(
                                    account: account,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('@${account.name}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          loading:
              () => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    // Loading indicator (equivalent to leading)
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    // Loading text content (equivalent to title and subtitle)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('loading').bold().tr(),
                          const SizedBox(height: 4),
                          const Text('...'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          error:
              (error, stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    // Error icon (equivalent to leading)
                    const Icon(Symbols.error),
                    const SizedBox(width: 16),
                    // Error text content (equivalent to title and subtitle)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('somethingWentWrong').tr().bold(),
                          const SizedBox(height: 4),
                          Text(error.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
