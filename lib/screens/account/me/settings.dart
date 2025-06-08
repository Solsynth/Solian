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
import 'package:island/models/user.dart';
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

@riverpod
Future<List<SnContactMethod>> contactMethods(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final resp = await client.get('/accounts/me/contacts');
  return resp.data
      .map<SnContactMethod>((e) => SnContactMethod.fromJson(e))
      .toList();
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
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/accounts/me');
        if (context.mounted) {
          showSnackBar(context, 'accountDeletionSent'.tr());
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
      final captchaTk = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => CaptchaScreen()));
      if (captchaTk == null) return;
      try {
        showLoadingModal(context);
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
                data:
                    (contacts) => Column(
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
                              style:
                                  contact.verifiedAt == null
                                      ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      )
                                      : null,
                            ),
                            subtitle: Text(
                              contact.type == 0
                                  ? 'contactMethodTypeEmail'.tr()
                                  : 'contactMethodTypePhone'.tr(),
                              style:
                                  contact.verifiedAt == null
                                      ? TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      )
                                      : null,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  contact.verifiedAt == null
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer
                                      : Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                              child: Icon(
                                contact.type == 0
                                    ? Symbols.mail
                                    : Symbols.phone,
                              ),
                            ).padding(top: 4),
                            trailing: const Icon(Symbols.chevron_right),
                            isThreeLine: false,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder:
                                    (context) =>
                                        _ContactMethodSheet(contact: contact),
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
                              builder:
                                  (context) => const _ContactMethodNewSheet(),
                            ).then((value) {
                              if (value == true) {
                                ref.invalidate(contactMethodsProvider);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                error:
                    (err, _) => ResponseErrorWidget(
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
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/accounts/me/factors/${factor.id}');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> disableFactor() async {
      final confirm = await showConfirmAlert(
        'authFactorDisableHint'.tr(),
        'authFactorDisable'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.post('/accounts/me/factors/${factor.id}/disable');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
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
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.post(
          '/accounts/me/factors/${factor.id}/enable',
          data: jsonEncode(password),
        );
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
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
                      label: Text('authFactorDisabled'.tr()),
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    )
                  else
                    Badge(
                      label: Text('authFactorEnabled'.tr()),
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
        showLoadingModal(context);
        final apiClient = ref.read(apiClientProvider);
        final resp = await apiClient.post(
          '/accounts/me/factors',
          data: {'type': factorType.value, 'secret': secretController.text},
        );
        final factor = SnAuthFactor.fromJson(resp.data);
        if (!context.mounted) return;
        hideLoadingModal(context);
        if (factor.type == 3) {
          showModalBottomSheet(
            context: context,
            builder: (context) => _AuthFactorNewAdditonalSheet(factor: factor),
          ).then((_) {
            if (context.mounted) {
              showSnackBar(context, 'contactMethodVerificationNeeded'.tr());
            }
            if (context.mounted) Navigator.pop(context, true);
          });
        } else {
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
        if (context.mounted) hideLoadingModal(context);
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

class _ContactMethodSheet extends HookConsumerWidget {
  final SnContactMethod contact;
  const _ContactMethodSheet({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> deleteContactMethod() async {
      final confirm = await showConfirmAlert(
        'contactMethodDeleteHint'.tr(),
        'contactMethodDelete'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/accounts/me/contacts/${contact.id}');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> verifyContactMethod() async {
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.post('/accounts/me/contacts/${contact.id}/verify');
        if (context.mounted) {
          showSnackBar(context, 'contactMethodVerificationSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> setContactMethodAsPrimary() async {
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.post('/accounts/me/contacts/${contact.id}/primary');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'contactMethod'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(switch (contact.type) {
                0 => Symbols.mail,
                1 => Symbols.phone,
                _ => Symbols.home,
              }, size: 32),
              const Gap(8),
              Text(switch (contact.type) {
                0 => 'contactMethodTypeEmail'.tr(),
                1 => 'contactMethodTypePhone'.tr(),
                _ => 'contactMethodTypeAddress'.tr(),
              }),
              const Gap(4),
              Text(
                contact.content,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(10),
              Row(
                children: [
                  if (contact.verifiedAt == null)
                    Badge(
                      label: Text('contactMethodUnverified'.tr()),
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    )
                  else
                    Badge(
                      label: Text('contactMethodVerified'.tr()),
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  if (contact.isPrimary)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Badge(
                        label: Text('contactMethodPrimary'.tr()),
                        textColor: Theme.of(context).colorScheme.onTertiary,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                ],
              ),
            ],
          ).padding(all: 20),
          const Divider(height: 1),
          if (contact.verifiedAt == null)
            ListTile(
              leading: const Icon(Symbols.verified),
              title: Text('contactMethodVerify').tr(),
              onTap: verifyContactMethod,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          if (contact.verifiedAt != null && !contact.isPrimary)
            ListTile(
              leading: const Icon(Symbols.star),
              title: Text('contactMethodSetPrimary').tr(),
              onTap: setContactMethodAsPrimary,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ListTile(
            leading: const Icon(Symbols.delete),
            title: Text('contactMethodDelete').tr(),
            onTap: deleteContactMethod,
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }
}

class _ContactMethodNewSheet extends HookConsumerWidget {
  const _ContactMethodNewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactType = useState<int>(0);
    final contentController = useTextEditingController();

    Future<void> addContactMethod() async {
      if (contentController.text.isEmpty) {
        showSnackBar(context, 'contactMethodContentEmpty'.tr());
        return;
      }

      try {
        showLoadingModal(context);
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          '/accounts/me/contacts',
          data: {'type': contactType.value, 'content': contentController.text},
        );
        if (context.mounted) {
          showSnackBar(context, 'contactMethodVerificationNeeded'.tr());
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'contactMethodNew'.tr(),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: contactType.value,
            decoration: InputDecoration(
              labelText: 'contactMethodType'.tr(),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Symbols.mail),
                    const Gap(8),
                    Text('contactMethodTypeEmail'.tr()),
                  ],
                ),
              ),
              DropdownMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Symbols.phone),
                    const Gap(8),
                    Text('contactMethodTypePhone'.tr()),
                  ],
                ),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Symbols.home),
                    const Gap(8),
                    Text('contactMethodTypeAddress'.tr()),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                contactType.value = value;
              }
            },
          ),
          TextField(
            controller: contentController,
            decoration: InputDecoration(
              prefixIcon: Icon(switch (contactType.value) {
                0 => Symbols.mail,
                1 => Symbols.phone,
                _ => Symbols.home,
              }),
              labelText: switch (contactType.value) {
                0 => 'contactMethodTypeEmail'.tr(),
                1 => 'contactMethodTypePhone'.tr(),
                _ => 'contactMethodTypeAddress'.tr(),
              },
              hintText: switch (contactType.value) {
                0 => 'contactMethodEmailHint'.tr(),
                1 => 'contactMethodPhoneHint'.tr(),
                _ => 'contactMethodAddressHint'.tr(),
              },
              border: const OutlineInputBorder(),
            ),
            keyboardType: switch (contactType.value) {
              0 => TextInputType.emailAddress,
              1 => TextInputType.phone,
              _ => TextInputType.multiline,
            },
            maxLines: switch (contactType.value) {
              2 => 3,
              _ => 1,
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                Text(switch (contactType.value) {
                  0 => 'contactMethodEmailDescription',
                  1 => 'contactMethodPhoneDescription',
                  _ => 'contactMethodAddressDescription',
                }).tr(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: addContactMethod,
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
