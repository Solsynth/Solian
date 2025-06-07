import 'dart:convert';
import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/auth.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/auth/captcha.dart';
import 'package:island/screens/auth/login.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_session_sheet.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'settings.g.dart';

@riverpod
Future<List<SnAuthFactor>> authFactors(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get('/accounts/me/factors');
  return res.data.map<SnAuthFactor>((e) => SnAuthFactor.fromJson(e)).toList();
}

@RoutePage()
class AccountSettingsScreen extends HookConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final isWide = isWideScreen(context);

    Future<void> requestAccountDeletion() async {
      final confirm = await showConfirmAlert(
        'accountDeletionHint'.tr(),
        'accountDeletion'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        final client = ref.read(apiClientProvider);
        await client.delete('/accounts/me');
        if (context.mounted) {
          showSnackBar(context, 'accountDeletionSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> requestResetPassword() async {
      final confirm = await showConfirmAlert(
        'accountPasswordChangeDescription'.tr(),
        'accountPasswordChange'.tr(),
      );
      if (!confirm || !context.mounted) return;
      final captchaTk = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => CaptchaScreen()));
      if (captchaTk == null) return;
      try {
        final userInfo = ref.read(userInfoProvider);
        final client = ref.read(apiClientProvider);
        await client.post(
          '/accounts/recovery/password',
          data: {'account': userInfo.value!.name, 'captcha_token': captchaTk},
        );
        if (context.mounted) {
          showSnackBar(context, 'accountPasswordChangeSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
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
          Symbols.security,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountAuthFactor').tr(),
        subtitle: Text('accountAuthFactorDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          authFactors.when(
            data:
                (factors) => Column(
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
                        title:
                            Text(
                              kFactorTypes[factor.type]!.$1,
                              style:
                                  factor.enabledAt == null
                                      ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      )
                                      : null,
                            ).tr(),
                        subtitle:
                            Text(
                              kFactorTypes[factor.type]!.$2,
                              style:
                                  factor.enabledAt == null
                                      ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      )
                                      : null,
                            ).tr(),
                        leading: CircleAvatar(
                          backgroundColor:
                              factor.enabledAt == null
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer
                                  : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
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
                            builder:
                                (context) => _AuthFactorSheet(factor: factor),
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
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        right: 17,
                      ),
                      title: Text('authFactorNew').tr(),
                      leading: const Icon(Symbols.add),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const _AuthFactorNewSheet(),
                        ).then((value) {
                          if (value == true) {
                            ref.invalidate(authFactorsProvider);
                          }
                        });
                      },
                    ),
                  ],
                ),
            error:
                (err, _) => ResponseErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(authFactorsProvider),
                ),
            loading: () => ResponseLoadingWidget(),
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
      if (isWide) {
        // Two-column layout for wide screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSection(
                    title: 'accountSecurityTitle',
                    children: securitySettings,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSection(
                    title: 'accountDangerZoneTitle',
                    children: dangerZoneSettings,
                  ),
                ],
              ),
            ),
          ],
        ).padding(horizontal: 16);
      } else {
        // Single column layout for narrow screens
        return Column(
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
        );
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('accountSettings').tr(),
        actions:
            isDesktop
                ? [
                  IconButton(
                    icon: const Icon(Symbols.help_outline),
                    onPressed: () {
                      // Show help dialog
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
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
    return Column(
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
    );
  }
}

class _AuthFactorSheet extends HookConsumerWidget {
  final SnAuthFactor factor;
  const _AuthFactorSheet({required this.factor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> deleteFactor() async {
      final confirm = await showConfirmAlert(
        'authFactorDeleteHint'.tr(),
        'authFactorDelete'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        final client = ref.read(apiClientProvider);
        await client.delete('/accounts/me/factors/${factor.id}');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> disableFactor() async {
      final confirm = await showConfirmAlert(
        'authFactorDisableHint'.tr(),
        'authFactorDisable'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        final client = ref.read(apiClientProvider);
        await client.post('/accounts/me/factors/${factor.id}/disable');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> enableFactor() async {
      String? password;
      if ([3].contains(factor.type)) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('authFactorEnable').tr(),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('authFactorEnableHint').tr(),
                    const SizedBox(height: 16),
                    OtpTextField(
                      showCursor: false,
                      numberOfFields: 6,
                      obscureText: false,
                      showFieldAsBox: true,
                      focusedBorderColor: Theme.of(context).colorScheme.primary,
                      onSubmit: (String verificationCode) {
                        password = verificationCode;
                      },
                      textStyle: Theme.of(context).textTheme.titleLarge!,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel').tr(),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('confirm').tr(),
                  ),
                ],
              ),
        );
        if (confirmed == false ||
            (password?.isEmpty ?? true) ||
            !context.mounted) {
          return;
        }
      }
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/accounts/me/factors/${factor.id}/enable',
          data: jsonEncode(password),
        );
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'authFactor'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(kFactorTypes[factor.type]!.$3, size: 32),
              const Gap(8),
              Text(kFactorTypes[factor.type]!.$1).tr(),
              const Gap(4),
              Text(
                kFactorTypes[factor.type]!.$2,
                style: Theme.of(context).textTheme.bodySmall,
              ).tr(),
              const Gap(10),
              Row(
                children: [
                  if (factor.enabledAt == null)
                    Badge(
                      label: Text('Disabled'),
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    )
                  else
                    Badge(
                      label: Text('Enabled'),
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ],
          ).padding(all: 20),
          const Divider(height: 1),
          if (factor.enabledAt != null)
            ListTile(
              leading: const Icon(Symbols.disabled_by_default),
              title: Text('authFactorDisable').tr(),
              onTap: disableFactor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            )
          else
            ListTile(
              leading: const Icon(Symbols.check_circle),
              title: Text('authFactorEnable').tr(),
              onTap: enableFactor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ListTile(
            leading: const Icon(Symbols.delete),
            title: Text('authFactorDelete').tr(),
            onTap: deleteFactor,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }
}

class _AuthFactorNewSheet extends HookConsumerWidget {
  const _AuthFactorNewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factorType = useState<int>(0);
    final secretController = useTextEditingController();

    Future<void> addFactor() async {
      try {
        final apiClient = ref.read(apiClientProvider);
        final resp = await apiClient.post(
          '/accounts/me/factors',
          data: {'type': factorType.value, 'secret': secretController.text},
        );
        final factor = SnAuthFactor.fromJson(resp.data);
        if (!context.mounted) return;
        if (factor.type == 3) {
          showModalBottomSheet(
            context: context,
            builder: (context) => _AuthFactorNewAdditonalSheet(factor: factor),
          ).then((_) {
            if (context.mounted) Navigator.pop(context, true);
          });
        } else {
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'authFactorNew'.tr(),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: factorType.value,
            decoration: InputDecoration(
              labelText: 'authFactor'.tr(),
              border: const OutlineInputBorder(),
            ),
            items:
                kFactorTypes.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value.$3),
                        const Gap(8),
                        Text(entry.value.$1).tr(),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                factorType.value = value;
              }
            },
          ),
          if (factorType.value == 0)
            TextField(
              controller: secretController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Symbols.password_2),
                labelText: 'authFactorSecret'.tr(),
                hintText: 'authFactorSecretHint'.tr(),
                border: const OutlineInputBorder(),
              ),
              onTapOutside:
                  (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(kFactorTypes[factorType.value]!.$2).tr(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: addFactor,
                icon: Icon(Symbols.add),
                label: Text('create').tr(),
              ),
            ],
          ),
        ],
      ).padding(horizontal: 20, vertical: 24),
    );
  }
}

class _AuthFactorNewAdditonalSheet extends StatelessWidget {
  final SnAuthFactor factor;
  const _AuthFactorNewAdditonalSheet({required this.factor});

  @override
  Widget build(BuildContext context) {
    final uri = factor.createdResponse?['uri'];

    return SheetScaffold(
      titleText: 'authFactorAdditional'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (uri != null) ...[
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QrImageView(
                  data: uri,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'authFactorQrCodeScan'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'authFactorNoQrCode'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Symbols.check),
              label: Text('next'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
