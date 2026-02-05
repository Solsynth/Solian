import 'dart:convert';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/auth/auth_models/auth.dart';
import 'package:island/core/network.dart';
import 'package:island/auth/login.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

class AuthFactorSheet extends HookConsumerWidget {
  final SnAuthFactor factor;
  const AuthFactorSheet({super.key, required this.factor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> deleteFactor() async {
      final confirm = await showConfirmAlert(
        'authFactorDeleteHint'.tr(),
        'authFactorDelete'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/pass/accounts/me/factors/${factor.id}');
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
        await client.post('/pass/accounts/me/factors/${factor.id}/disable');
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
          builder: (context) => AlertDialog(
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
          '/pass/accounts/me/factors/${factor.id}/enable',
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
                      label: Text('authFactorDisabled').tr(),
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    )
                  else
                    Badge(
                      label: Text('authFactorEnabled').tr(),
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

class AuthFactorNewSheet extends HookConsumerWidget {
  const AuthFactorNewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factorType = useState<int>(0);
    final secretController = useTextEditingController();

    Future<void> addFactor() async {
      try {
        showLoadingModal(context);
        final apiClient = ref.read(apiClientProvider);
        final resp = await apiClient.post(
          '/pass/accounts/me/factors',
          data: {'type': factorType.value, 'secret': secretController.text},
        );
        final factor = SnAuthFactor.fromJson(resp.data);
        if (!context.mounted) return;
        hideLoadingModal(context);
        if (factor.type == 3) {
          showModalBottomSheet(
            context: context,
            builder: (context) => AuthFactorNewAdditonalSheet(factor: factor),
          ).then((_) {
            if (context.mounted) {
              showSnackBar('contactMethodVerificationNeeded'.tr());
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

    final width = math.min(400, MediaQuery.of(context).size.width);

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
            items: kFactorTypes.entries.map((entry) {
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
          if ([0].contains(factorType.value))
            TextField(
              controller: secretController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Symbols.password_2),
                labelText: 'authFactorSecret'.tr(),
                hintText: 'authFactorSecretHint'.tr(),
                border: const OutlineInputBorder(),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            )
          else if ([4].contains(factorType.value))
            OtpTextField(
              showCursor: false,
              numberOfFields: 6,
              obscureText: false,
              showFieldAsBox: true,
              focusedBorderColor: Theme.of(context).colorScheme.primary,
              fieldWidth: (width / 6) - 10,
              keyboardType: TextInputType.number,
              onSubmit: (String verificationCode) {
                secretController.text = verificationCode;
              },
              textStyle: Theme.of(context).textTheme.titleLarge!,
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

class AuthFactorNewAdditonalSheet extends StatelessWidget {
  final SnAuthFactor factor;
  const AuthFactorNewAdditonalSheet({super.key, required this.factor});

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
