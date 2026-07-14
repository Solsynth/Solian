import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/auth/login.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:pinput/pinput.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AuthFactorSheet extends HookConsumerWidget {
  final SnAuthFactor factor;
  const AuthFactorSheet({super.key, required this.factor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passkeys = useState<List<SnPasskey>>([]);
    final passkeysLoading = useState(false);

    Future<void> loadPasskeys() async {
      if (factor.type != 7) return;
      passkeysLoading.value = true;
      try {
        passkeys.value = await ref
            .read(solarNetworkClientProvider)
            .auth
            .getPasskeys();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        passkeysLoading.value = false;
      }
    }

    useEffect(() {
      if (factor.type == 7) Future.microtask(loadPasskeys);
      return null;
    }, [factor.id]);

    Future<void> addPasskey() async {
      final created = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const AuthFactorNewSheet(initialType: 7),
      );
      if (created == true) await loadPasskeys();
    }

    Future<void> renamePasskey(SnPasskey passkey) async {
      final controller = TextEditingController(text: passkey.label);
      final label = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('rename'.tr()),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: 'name'.tr()),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
      controller.dispose();
      if (label == null || label.trim().isEmpty) return;
      if (!context.mounted) return;

      try {
        showLoadingModal(context);
        await ref
            .read(solarNetworkClientProvider)
            .auth
            .updatePasskey(passkeyId: passkey.id, label: label.trim());
        await loadPasskeys();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> deletePasskey(SnPasskey passkey) async {
      final confirmed = await showConfirmAlert(
        'authFactorDeleteHint'.tr(),
        'authFactorDelete'.tr(),
        isDanger: true,
      );
      if (!confirmed || !context.mounted) return;

      try {
        showLoadingModal(context);
        await ref
            .read(solarNetworkClientProvider)
            .auth
            .deletePasskey(passkey.id);
        await loadPasskeys();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> deleteFactor() async {
      final confirm = await showConfirmAlert(
        'authFactorDeleteHint'.tr(),
        'authFactorDelete'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(solarNetworkClientProvider);
        await client.auth.deleteFactor(factor.id);
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
        final client = ref.read(solarNetworkClientProvider);
        await client.auth.disableFactor(factor.id);
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> enableFactor() async {
      final needsVerification =
          factor.type != 5 && factor.type != 7 && factor.type != 8;
      String? verificationCode;

      if (needsVerification) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            final controller = TextEditingController();
            return AlertDialog(
              title: Text('authFactorEnable').tr(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('authFactorEnableHint'.tr()),
                  const SizedBox(height: 16),
                  if (factor.type == 4)
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'authFactorPin'.tr(),
                      ),
                    )
                  else
                    Pinput(
                      controller: controller,
                      showCursor: false,
                      length: 6,
                      obscureText: false,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('cancel'.tr()),
                ),
                FilledButton(
                  onPressed: () {
                    verificationCode = controller.text;
                    Navigator.of(context).pop(true);
                  },
                  child: Text('confirm'.tr()),
                ),
              ],
            );
          },
        );

        if (confirmed != true ||
            verificationCode == null ||
            verificationCode!.isEmpty) {
          return;
        }
      }

      try {
        if (context.mounted) showLoadingModal(context);
        final client = ref.read(solarNetworkClientProvider);
        final response = await client.dio.post(
          '/padlock/factors/${factor.id}/enable',
          data: verificationCode != null ? jsonEncode(verificationCode) : null,
        );
        if (!context.mounted) return;
        hideLoadingModal(context);

        if (factor.type == 5) {
          final newCode =
              response.data['createdResponse']?['recovery_code'] as String?;
          if (newCode != null && context.mounted) {
            final updatedFactor = SnAuthFactor.fromJson(response.data);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => RecoveryCodeCreatedSheet(factor: updatedFactor),
            ).then((_) {
              if (context.mounted) Navigator.pop(context, true);
            });
            return;
          }
        }
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'authFactor'.tr(),
      child: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          kFactorTypes[factor.type]!.$3,
                          size: 28,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kFactorTypes[factor.type]!.$1,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ).tr(),
                            const SizedBox(height: 2),
                            Text(
                              kFactorTypes[factor.type]!.$2,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ).tr(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: factor.enabledAt != null
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          factor.enabledAt != null
                              ? Symbols.check_circle
                              : Symbols.disabled_by_default,
                          size: 16,
                          color: factor.enabledAt != null
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          factor.enabledAt != null
                              ? 'authFactorEnabled'
                              : 'authFactorDisabled',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: factor.enabledAt != null
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ).tr(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (factor.type == 7) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Symbols.add),
              title: Text('authFactorNew').tr(),
              onTap: factor.enabledAt == null ? null : addPasskey,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            if (passkeysLoading.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              for (final passkey in passkeys.value)
                ListTile(
                  leading: const Icon(Symbols.fingerprint),
                  title: Text(passkey.label),
                  subtitle: Text(passkey.createdAt.toLocal().toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.edit),
                        tooltip: 'rename'.tr(),
                        onPressed: () => renamePasskey(passkey),
                      ),
                      IconButton(
                        icon: Icon(
                          Symbols.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        tooltip: 'authFactorDelete'.tr(),
                        onPressed: () => deletePasskey(passkey),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
          ],
          const Divider(height: 1),
          if (factor.enabledAt != null)
            ListTile(
              leading: const Icon(Symbols.disabled_by_default),
              title: Text('authFactorDisable').tr(),
              onTap: disableFactor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            )
          else
            ListTile(
              leading: const Icon(Symbols.check_circle),
              title: Text('authFactorEnable').tr(),
              onTap: enableFactor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ListTile(
            leading: Icon(
              Symbols.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'authFactorDelete'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: deleteFactor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }
}

class AuthFactorNewSheet extends ConsumerStatefulWidget {
  final int? initialType;

  const AuthFactorNewSheet({super.key, this.initialType});

  @override
  ConsumerState<AuthFactorNewSheet> createState() => _AuthFactorNewSheetState();
}

class _AuthFactorNewSheetState extends ConsumerState<AuthFactorNewSheet> {
  int _selectedType = 0;
  final _secretController = TextEditingController();
  final _pinController = TextEditingController();
  final _passkeyLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? 0;
  }

  @override
  void dispose() {
    _secretController.dispose();
    _pinController.dispose();
    _passkeyLabelController.dispose();
    super.dispose();
  }

  Future<void> _addFactor() async {
    try {
      showLoadingModal(context);
      final client = ref.read(solarNetworkClientProvider);
      SnAuthFactor? factor;

      if (_selectedType == 7) {
        final passkeyAuthenticator = PasskeyAuthenticator(
          debugMode: kDebugMode,
        );
        final availability = await _getPasskeyAvailability(
          passkeyAuthenticator,
        );
        if (!availability.hasPasskeySupport) {
          if (mounted) {
            hideLoadingModal(context);
            showErrorAlert('passkeyNotSupported'.tr());
          }
          return;
        }

        final hasPasskeyFactor =
            ref
                .read(authFactorsProvider)
                .value
                ?.any((factor) => factor.type == 7) ??
            false;
        if (!hasPasskeyFactor) {
          await client.auth.createFactor(type: _selectedType, secret: null);
        }

        final deviceId = await getUdid();
        final deviceName = await getDeviceName();
        final webAuthnConfig = await client.auth.getWebAuthnConfiguration();

        final challengeResponse = await client.auth.startPasskeyRegistration(
          deviceId: deviceId,
          deviceName: deviceName,
        );

        final serverOptions = challengeResponse;
        if (serverOptions['rp_id'] != webAuthnConfig['rp_id']) {
          throw StateError('WebAuthn relying party configuration changed.');
        }
        final authSelection =
            serverOptions['authenticator_selection'] as Map<String, dynamic>?;

        final userInfo = ref.watch(userInfoProvider);

        final request = RegisterRequestType(
          challenge: serverOptions['challenge'] as String,
          relyingParty: RelyingPartyType(
            id: serverOptions['rp_id'] as String,
            name: serverOptions['rp_name'] as String,
          ),
          user: UserType(
            id: serverOptions['user_id'] as String,
            name: userInfo.value?.name ?? serverOptions['user_id'] as String,
            displayName:
                userInfo.value?.nick ??
                serverOptions['user_name'] as String? ??
                serverOptions['user_id'] as String,
          ),
          excludeCredentials: [],
          pubKeyCredParams: (serverOptions['pub_key_cred_params'] as List)
              .map(
                (e) => PubKeyCredParamType(
                  type: e['type'] as String,
                  alg: e['alg'] as int,
                ),
              )
              .toList(),
          authSelectionType: authSelection != null
              ? AuthenticatorSelectionType(
                  authenticatorAttachment:
                      authSelection['authenticator_attachment'] as String?,
                  residentKey:
                      authSelection['resident_key'] as String? ?? 'preferred',
                  userVerification:
                      authSelection['user_verification'] as String? ??
                      'preferred',
                  requireResidentKey: false,
                )
              : null,
          timeout: serverOptions['timeout'] as int?,
          attestation: 'none',
        );

        final credential = await passkeyAuthenticator.register(request);

        await client.auth.completePasskeyRegistration(
          deviceId: deviceId,
          label: _passkeyLabelController.text.trim().isEmpty
              ? deviceName
              : _passkeyLabelController.text.trim(),
          attestationObject: credential.attestationObject,
          clientDataJson: credential.clientDataJSON,
        );
        if (!mounted) return;
        hideLoadingModal(context);
        Navigator.pop(context, true);
        return;
      } else {
        factor = await client.auth.createFactor(
          type: _selectedType,
          secret: _selectedType == 4
              ? _pinController.text
              : _selectedType == 0
              ? _secretController.text
              : null,
        );
      }

      if (!mounted) return;
      hideLoadingModal(context);
      final createdFactor = factor;
      if (createdFactor.type == 3) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              AuthFactorNewAdditonalSheet(factor: createdFactor),
        ).then((_) {
          if (mounted) {
            showSnackBar('contactMethodVerificationNeeded'.tr());
          }
          if (mounted) Navigator.pop(context, true);
        });
      } else if (createdFactor.type == 5) {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => RecoveryCodeCreatedSheet(factor: createdFactor),
          ).then((_) {
            if (mounted) Navigator.pop(context, true);
          });
        }
        return;
      } else {
        Navigator.pop(context, true);
      }
    } catch (err) {
      showErrorAlert(err);
      if (mounted) hideLoadingModal(context);
    }
  }

  Future<AvailabilityType> _getPasskeyAvailability(
    PasskeyAuthenticator authenticator,
  ) async {
    if (kIsWeb) {
      return await authenticator.getAvailability().web();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return await authenticator.getAvailability().android();
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return await authenticator.getAvailability().iOS();
    }
    return AvailabilityTypeAndroid(
      hasPasskeySupport: false,
      isNative: true,
      isUserVerifyingPlatformAuthenticatorAvailable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authFactorsAsync = ref.watch(authFactorsProvider);
    final hasRecoveryCode = authFactorsAsync.maybeWhen(
      data: (factors) => factors.any((f) => f.type == 5),
      orElse: () => false,
    );

    final hasntDuplicate =
        _selectedType == 7 ||
        authFactorsAsync.value?.any((e) => e.type == _selectedType) != true;
    final canAddFactor =
        (hasRecoveryCode || _selectedType == 5) && hasntDuplicate;

    return SheetScaffold(
      heightFactor: 0.75,
      titleText: 'authFactorNew'.tr(),
      child: authFactorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('error'.tr())),
        data: (factors) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasRecoveryCode) ...[
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.warning,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'authFactorRecoveryCodeRequired'.tr(),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!hasntDuplicate)
                ...([
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.warning,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'authFactorExisted'.tr(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              DropdownButtonFormField<int>(
                value: _selectedType,
                decoration: InputDecoration(labelText: 'authFactor'.tr()),
                items: kFactorTypes.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value.$3),
                        const SizedBox(width: 12),
                        Text(entry.value.$1).tr(),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              if (_selectedType == 0)
                TextField(
                  controller: _secretController,
                  decoration: InputDecoration(
                    labelText: 'authFactorSecret'.tr(),
                    hintText: 'authFactorSecretHint'.tr(),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(top: 16)
              else if (_selectedType == 4)
                TextField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'authFactorPin'.tr(),
                    hintText: 'authFactorPinHint'.tr(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(top: 16)
              else if (_selectedType == 7)
                TextField(
                  controller: _passkeyLabelController,
                  decoration: InputDecoration(
                    labelText: 'name'.tr(),
                    hintText: 'authFactorPasskey'.tr(),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(top: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  kFactorTypes[_selectedType]?.$2 ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ).tr(),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: canAddFactor ? _addFactor : null,
                icon: const Icon(Symbols.add),
                label: Text('create').tr(),
              ).padding(bottom: 8),
            ],
          ).padding(horizontal: 20, vertical: 16);
        },
      ),
    );
  }
}

class AuthFactorNewAdditonalSheet extends StatelessWidget {
  final SnAuthFactor factor;
  const AuthFactorNewAdditonalSheet({super.key, required this.factor});

  @override
  Widget build(BuildContext context) {
    final uri = factor.createdResponse?['uri'];
    final theme = Theme.of(context);

    return SheetScaffold(
      heightFactor: 0.7,
      titleText: 'authFactorAdditional'.tr(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (uri != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: QrImageView(
                data: uri,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'authFactorQrCodeScan'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.qr_code,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'authFactorNoQrCode'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
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

class RecoveryCodeCreatedSheet extends StatelessWidget {
  final SnAuthFactor factor;
  const RecoveryCodeCreatedSheet({super.key, required this.factor});

  @override
  Widget build(BuildContext context) {
    final secret = factor.createdResponse?['recovery_code'] as String?;
    final theme = Theme.of(context);

    return SheetScaffold(
      heightFactor: 0.7,
      titleText: 'recoveryCodeCreated'.tr(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.key,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'recoveryCodeSaveWarning'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (secret != null) ...[
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SelectableText(
                secret,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Symbols.check),
              label: Text('iHaveSavedIt'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
