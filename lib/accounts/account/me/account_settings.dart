import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_widgets/account/account_devices.dart';
import 'package:island/auth/auth_models/auth.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/accounts/account/me/settings_auth_factors.dart';
import 'package:island/accounts/account/me/settings_connections.dart';
import 'package:island/accounts/account/me/settings_contacts.dart';
import 'package:island/auth/captcha.dart';
import 'package:island/auth/login.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'account_settings.g.dart';

@riverpod
Future<List<SnAuthFactor>> authFactors(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get('/pass/accounts/me/factors');
  return res.data.map<SnAuthFactor>((e) => SnAuthFactor.fromJson(e)).toList();
}

@riverpod
Future<List<SnContactMethod>> contactMethods(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final resp = await client.get('/pass/accounts/me/contacts');
  return resp.data
      .map<SnContactMethod>((e) => SnContactMethod.fromJson(e))
      .toList();
}

@riverpod
Future<List<SnAccountConnection>> accountConnections(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final resp = await client.get('/pass/accounts/me/connections');
  return resp.data
      .map<SnAccountConnection>((e) => SnAccountConnection.fromJson(e))
      .toList();
}

class AccountSettingsScreen extends HookConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    Future<void> requestAccountDeletion() async {
      final confirm = await showConfirmAlert(
        'accountDeletionHint'.tr(),
        'accountDeletion'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/pass/accounts/me');
        if (context.mounted) {
          showSnackBar('accountDeletionSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> requestResetPassword() async {
      final confirm = await showConfirmAlert(
        'accountPasswordChangeDescription'.tr(),
        'accountPasswordChange'.tr(),
      );
      if (!confirm || !context.mounted) return;
      final captchaTk = await CaptchaScreen.show(context);
      if (captchaTk == null) return;
      try {
        if (context.mounted) showLoadingModal(context);
        final userInfo = ref.read(userInfoProvider);
        final client = ref.read(apiClientProvider);
        await client.post(
          '/pass/accounts/recovery/password',
          data: {'account': userInfo.value!.name, 'captcha_token': captchaTk},
        );
        if (context.mounted) {
          showSnackBar('accountPasswordChangeSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final authFactors = ref.watch(authFactorsProvider);

    // Group settings into categories for better organization
    final securitySettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.devices),
        title: Text('authSessions').tr(),
        subtitle: Text('authSessionsDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AccountSessionSheet(),
          );
        },
      ),
      ExpansionTile(
        leading: const Icon(
          Symbols.link,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountConnections').tr(),
        subtitle: Text('accountConnectionsDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          ref
              .watch(accountConnectionsProvider)
              .when(
                data: (connections) => Column(
                  children: [
                    for (final connection in connections)
                      ListTile(
                        minLeadingWidth: 48,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 17,
                          top: 2,
                          bottom: 4,
                        ),
                        title: Text(
                          getLocalizedProviderName(connection.provider),
                        ).tr(),
                        subtitle: connection.meta['email'] != null
                            ? Text(connection.meta['email'])
                            : Text(connection.providedIdentifier),
                        leading: CircleAvatar(
                          child: getProviderIcon(
                            connection.provider,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ).padding(top: 4),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                AccountConnectionSheet(connection: connection),
                          ).then((value) {
                            if (value == true) {
                              ref.invalidate(accountConnectionsProvider);
                            }
                          });
                        },
                      ),
                    if (connections.isNotEmpty) const Divider(height: 1),
                    ListTile(
                      minLeadingWidth: 48,
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        right: 17,
                      ),
                      title: Text('accountConnectionAdd').tr(),
                      leading: const Icon(Symbols.add),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              const AccountConnectionNewSheet(),
                        ).then((value) {
                          if (value == true) {
                            ref.invalidate(accountConnectionsProvider);
                          }
                        });
                      },
                    ),
                  ],
                ),
                error: (err, _) => ResponseErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(accountConnectionsProvider),
                ),
                loading: () => const ResponseLoadingWidget(),
              ),
        ],
      ),
      ExpansionTile(
        leading: const Icon(
          Symbols.security,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountAuthFactor').tr(),
        subtitle: Text('accountAuthFactorDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          authFactors.when(
            data: (factors) => Column(
              children: [
                for (final factor in factors)
                  ListTile(
                    minLeadingWidth: 48,
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 17,
                      top: 2,
                      bottom: 4,
                    ),
                    title: Text(
                      kFactorTypes[factor.type]!.$1,
                      style: factor.enabledAt == null
                          ? TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ).tr(),
                    subtitle: Text(
                      kFactorTypes[factor.type]!.$2,
                      style: factor.enabledAt == null
                          ? TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ).tr(),
                    leading: CircleAvatar(
                      backgroundColor: factor.enabledAt == null
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(kFactorTypes[factor.type]!.$3),
                    ).padding(top: 4),
                    trailing: const Icon(Symbols.chevron_right),
                    isThreeLine: true,
                    onTap: () {
                      if (factor.type == 0) {
                        requestResetPassword();
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AuthFactorSheet(factor: factor),
                      ).then((value) {
                        if (value == true) {
                          ref.invalidate(authFactorsProvider);
                        }
                      });
                    },
                  ),
                if (factors.isNotEmpty) Divider(height: 1),
                ListTile(
                  minLeadingWidth: 48,
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  title: Text('authFactorNew').tr(),
                  leading: const Icon(Symbols.add),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => const AuthFactorNewSheet(),
                    ).then((value) {
                      if (value == true) {
                        ref.invalidate(authFactorsProvider);
                      }
                    });
                  },
                ),
              ],
            ),
            error: (err, _) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(authFactorsProvider),
            ),
            loading: () => ResponseLoadingWidget(),
          ),
        ],
      ),
      ExpansionTile(
        leading: const Icon(
          Symbols.contact_mail,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountContactMethod').tr(),
        subtitle: Text('accountContactMethodDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          ref
              .watch(contactMethodsProvider)
              .when(
                data: (contacts) => Column(
                  children: [
                    for (final contact in contacts)
                      ListTile(
                        minLeadingWidth: 48,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 17,
                          top: 2,
                          bottom: 4,
                        ),
                        title: Text(
                          contact.content,
                          style: contact.verifiedAt == null
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        subtitle: Text(
                          contact.type == 0
                              ? 'contactMethodTypeEmail'.tr()
                              : 'contactMethodTypePhone'.tr(),
                          style: contact.verifiedAt == null
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: contact.verifiedAt == null
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            contact.type == 0 ? Symbols.mail : Symbols.phone,
                          ),
                        ).padding(top: 4),
                        trailing: const Icon(Symbols.chevron_right),
                        isThreeLine: false,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                ContactMethodSheet(contact: contact),
                          ).then((value) {
                            if (value == true) {
                              ref.invalidate(contactMethodsProvider);
                            }
                          });
                        },
                      ),
                    if (contacts.isNotEmpty) const Divider(height: 1),
                    ListTile(
                      minLeadingWidth: 48,
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        right: 17,
                      ),
                      title: Text('contactMethodNew').tr(),
                      leading: const Icon(Symbols.add),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const ContactMethodNewSheet(),
                        ).then((value) {
                          if (value == true) {
                            ref.invalidate(contactMethodsProvider);
                          }
                        });
                      },
                    ),
                  ],
                ),
                error: (err, _) => ResponseErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(contactMethodsProvider),
                ),
                loading: () => const ResponseLoadingWidget(),
              ),
        ],
      ),
    ];

    final dangerZoneSettings = [
      ListTile(
        minLeadingWidth: 48,
        title: Text('accountDeletion').tr(),
        subtitle: Text('accountDeletionDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.delete_forever, color: Colors.red),
        trailing: const Icon(Symbols.chevron_right),
        onTap: requestAccountDeletion,
      ),
    ];

    // Create a responsive layout based on screen width
    Widget buildSettingsList() {
      return Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSection(
            title: 'accountSecurityTitle',
            children: securitySettings,
          ),
          _SettingsSection(
            title: 'accountDangerZoneTitle',
            children: dangerZoneSettings,
          ),
        ],
      ).padding(horizontal: 16);
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('accountSettings').tr(),
        actions: isDesktop
            ? [
                IconButton(
                  icon: const Icon(Symbols.help_outline),
                  onPressed: () {
                    // Show help dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('accountSettingsHelp').tr(),
                        content: Text('accountSettingsHelpContent').tr(),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close').tr(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(8),
              ]
            : null,
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // Add keyboard shortcuts for desktop
          if (isDesktop &&
              event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: buildSettingsList(),
        ),
      ),
    );
  }
}

// Helper widget for displaying settings sections with titles
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              title.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
