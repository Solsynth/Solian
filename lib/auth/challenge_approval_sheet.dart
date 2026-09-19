import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/api_error.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/wallets/pin_status.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pinput/pinput.dart';
import 'package:relative_time/relative_time.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Shared secure-storage key for a locally-cached PIN. The same key is used by
/// the payment overlay so a PIN entered once on this device also unlocks
/// cross-device login approvals via biometric.
const String _pinStorageKey = 'app_pin_code';
final _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

IconData _platformIcon(int? platform) {
  return switch (platform) {
    2 => Symbols.phone_iphone,
    3 => Symbols.phone_android,
    4 => Symbols.computer,
    5 => Symbols.computer,
    6 => Symbols.computer,
    1 => Symbols.language,
    _ => Symbols.devices,
  };
}

String _platformName(int? platform) {
  return switch (platform) {
    2 => 'platformIos'.tr(),
    3 => 'platformAndroid'.tr(),
    4 => 'platformMacos'.tr(),
    5 => 'platformWindows'.tr(),
    6 => 'platformLinux'.tr(),
    1 => 'platformWeb'.tr(),
    _ => 'platformUnknown'.tr(),
  };
}

class ChallengeApprovalSheet extends HookConsumerWidget {
  final SnAuthChallenge challenge;
  final VoidCallback? onResolved;

  const ChallengeApprovalSheet({
    super.key,
    required this.challenge,
    this.onResolved,
  });

  static Future<void> show(
    BuildContext context,
    SnAuthChallenge challenge, {
    VoidCallback? onResolved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) =>
          ChallengeApprovalSheet(challenge: challenge, onResolved: onResolved),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final remaining = useState<int?>(null);
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    // PIN status drives whether a PIN / biometric gate is shown. Mirrors the
    // payment overlay: no gate when validation is not required.
    final requiresPin = useState(false);
    final hasStoredPin = useState(false);
    final hasBiometric = useState(false);
    final isInitializing = useState(true);
    final isPinMode = useState(true);

    final pinController = useTextEditingController();

    // Guards the sheet against double-resolution when a poll tick races the
    // local approve/decline path.
    final resolved = useRef(false);

    useEffect(() {
      Future(() async {
        try {
          final pinStatus = await fetchWalletPinStatus(ref);
          final requires = pinStatus.validationRequired;
          if (!requires) {
            isInitializing.value = false;
            return;
          }
          requiresPin.value = true;
          final la = LocalAuthentication();
          final supported =
              await la.isDeviceSupported() && await la.canCheckBiometrics;
          hasBiometric.value = supported;
          final stored = await _secureStorage.read(key: _pinStorageKey);
          hasStoredPin.value = stored != null && stored.isNotEmpty;
          isPinMode.value = !(hasStoredPin.value && hasBiometric.value);
        } catch (_) {
          isPinMode.value = true;
        } finally {
          isInitializing.value = false;
        }
      });
      return null;
    }, const []);

    useEffect(() {
      if (challenge.expiredAt == null) return null;
      final expiry = challenge.expiredAt!;
      void updateRemaining() {
        final diff = expiry.difference(DateTime.now());
        remaining.value = diff.inSeconds > 0 ? diff.inSeconds : 0;
      }

      updateRemaining();
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateRemaining();
      });
      return timer.cancel;
    }, [challenge.expiredAt]);

    // Poll the challenge so a resolution performed on another client (e.g. a
    // second trusted device or a web session) closes this sheet instead of
    // leaving it open until expiry. Mirrors the Device A polling in
    // LoginContent; failures are transient and retried on the next tick.
    useEffect(() {
      Future<void> pollChallenge() async {
        if (resolved.value) return;
        final seconds = remaining.value;
        if (seconds != null && seconds <= 0) return; // expired; countdown handles it
        try {
          final client = ref.read(solarNetworkClientProvider);
          final resp = await client.dio.get(
            '/stargate/auth/challenge/${challenge.id}',
          );
          if (resolved.value) return;
          final updated = SnAuthChallenge.fromJson(resp.data);
          if (updated.approvedAt != null) {
            resolved.value = true;
            if (!context.mounted) return;
            showSnackBar('challengeApproved'.tr());
            Navigator.pop(context);
            onResolved?.call();
            return;
          }
          if (updated.declinedAt != null) {
            resolved.value = true;
            if (!context.mounted) return;
            showSnackBar('challengeDeclinedError'.tr());
            Navigator.pop(context);
            onResolved?.call();
            return;
          }
          if (updated.deletedAt != null) {
            // Removed server-side; nothing left to decide.
            resolved.value = true;
            if (!context.mounted) return;
            Navigator.pop(context);
            onResolved?.call();
          }
        } on DioException catch (err) {
          if (err.response?.statusCode == 404 && !resolved.value) {
            // Challenge no longer exists; treat as resolved.
            resolved.value = true;
            if (!context.mounted) return;
            Navigator.pop(context);
            onResolved?.call();
          }
        } catch (_) {
          // Best-effort poll; the next tick retries.
        }
      }

      pollChallenge();
      final timer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => pollChallenge(),
      );
      return timer.cancel;
    }, [challenge.id]);

    final expired = remaining.value != null && remaining.value! <= 0;

    // A PIN is required before approving/declining when the account enforces it.
    void clearStoredPin() {
      _secureStorage.delete(key: _pinStorageKey);
      hasStoredPin.value = false;
      isPinMode.value = true;
    }

    // Core network approve + local PIN caching + success teardown. Callers
    // own the isBusy flag so the biometric path can reuse this without a
    // deadlock from a nested busy check.
    Future<void> approveWithCode(String? pin) async {
      final client = ref.read(solarNetworkClientProvider);
      await client.auth.approveChallenge(
        challengeId: challenge.id,
        pinCode: pin,
      );
      if (requiresPin.value &&
          hasBiometric.value &&
          !hasStoredPin.value &&
          pin != null) {
        await _secureStorage.write(key: _pinStorageKey, value: pin);
        hasStoredPin.value = true;
      }
      if (!context.mounted) return;
      resolved.value = true;
      showSnackBar(
        'challengeApprovedByYou'.tr(
          args: [challenge.deviceName ?? 'unknownDevice'.tr()],
        ),
      );
      Navigator.pop(context);
      onResolved?.call();
    }

    Future<void> submitPin(String pin) async {
      if (isBusy.value || pin.length != 6) return;
      isBusy.value = true;
      try {
        await approveWithCode(pin);
      } catch (err) {
        await _handleAuthError(err, clearStoredPin);
      } finally {
        isBusy.value = false;
      }
    }

    // No PIN is enforced: approve directly with no credential.
    Future<void> approveDirect() async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        await approveWithCode(null);
      } catch (err) {
        await _handleAuthError(err, clearStoredPin);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> approveWithBiometric() async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        final la = LocalAuthentication();
        final ok = await la.authenticate(
          localizedReason: 'challengeBiometricReason'.tr(),
          biometricOnly: true,
        );
        if (!ok) {
          isPinMode.value = true;
          showSnackBar('biometricAuthFailed'.tr());
          return;
        }
        final stored = await _secureStorage.read(key: _pinStorageKey);
        if (stored == null || stored.isEmpty) {
          isPinMode.value = true;
          showSnackBar('noStoredPin'.tr());
          return;
        }
        await approveWithCode(stored);
      } catch (err) {
        isPinMode.value = true;
        showSnackBar(_biometricError(err));
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> performDecline() async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.auth.declineChallenge(
          challengeId: challenge.id,
          pinCode: requiresPin.value && pinController.text.isNotEmpty
              ? pinController.text
              : null,
        );
        if (!context.mounted) return;
        resolved.value = true;
        showSnackBar(
          'challengeDeclinedByYou'.tr(
            args: [challenge.deviceName ?? 'unknownDevice'.tr()],
          ),
        );
        Navigator.pop(context);
        onResolved?.call();
      } catch (err) {
        await _handleAuthError(err, clearStoredPin);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> onApprovePressed() async {
      if (isBusy.value) return;
      if (!requiresPin.value) {
        await approveDirect();
        return;
      }
      if (isPinMode.value) {
        final pin = pinController.text;
        if (pin.length != 6) return;
        await submitPin(pin);
        return;
      }
      await approveWithBiometric();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Small shared defaults for the calm ledger treatment.
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );

    final location = [
      challenge.city,
      challenge.country,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return SheetScaffold(
      titleText: 'challengePendingTitle'.tr(),
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
                      // Identity card: the requesting device.
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _platformIcon(challenge.platform),
                                size: 24,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    challenge.deviceName ??
                                        'unknownDevice'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const Gap(2),
                                  Text(
                                    _platformName(challenge.platform),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Verification ledger: facts, label-left / value-right.
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            _FactRow(
                              label: 'challengeIpAddress'.tr(),
                              value: challenge.ipAddress,
                              labelStyle: labelStyle,
                              valueStyle: valueStyle,
                            ),
                            _FactRow(
                              label: 'challengeLocation'.tr(),
                              value: location.isNotEmpty
                                  ? location
                                  : 'unknown'.tr(),
                              labelStyle: labelStyle,
                              valueStyle: valueStyle,
                            ),
                            _FactRow(
                              label: 'challengeRequested'.tr(),
                              value: RelativeTime(
                                context,
                              ).format(challenge.createdAt),
                              labelStyle: labelStyle,
                              valueStyle: valueStyle,
                            ),
                            if (remaining.value != null)
                              _FactRow(
                                label: 'challengeExpiresIn'.tr(),
                                value: 'challengeSeconds'.tr(
                                  args: ['${remaining.value}'],
                                ),
                                labelStyle: labelStyle,
                                valueStyle: valueStyle,
                                valueColor: remaining.value! < 60 && !expired
                                    ? scheme.error
                                    : null,
                              ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: scheme.outlineVariant,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.verified,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'challengeTrustedHint'.tr(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // PIN / biometric gate, only when the account enforces it.
                      if (expired)
                        SizedBox.shrink()
                      else if (isInitializing.value)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (requiresPin.value) ...[
                        if (isPinMode.value)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'challengeEnterPin'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(20),
                                Pinput(
                                  length: 6,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  controller: pinController,
                                  defaultPinTheme: _pinTheme(theme, scheme),
                                  focusedPinTheme: _pinTheme(
                                    theme,
                                    scheme,
                                    focused: true,
                                  ),
                                  submittedPinTheme: _pinTheme(
                                    theme,
                                    scheme,
                                    submitted: true,
                                  ),
                                  onSubmitted: submitPin,
                                ),
                                if (hasStoredPin.value && hasBiometric.value)
                                  TextButton(
                                    onPressed: isBusy.value
                                        ? null
                                        : approveWithBiometric,
                                    child: Text('useBiometricInstead'.tr()),
                                  ),
                              ],
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.fingerprint,
                                  size: 48,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'challengeBiometricPrompt'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                FilledButton.tonalIcon(
                                  onPressed: approveWithBiometric,
                                  icon: const Icon(Symbols.fingerprint),
                                  label: Text('authenticateNow'.tr()),
                                ),
                                TextButton(
                                  onPressed: () => isPinMode.value = true,
                                  child: Text('usePinInstead'.tr()),
                                ),
                              ],
                            ),
                          ),
                      ] else
                        SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (expired)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Symbols.timer_off, color: scheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'challengeExpired'.tr(),
                          style: TextStyle(color: scheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy.value ? null : performDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: scheme.onSurface,
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        child: isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('challengeDecline'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: isBusy.value ? null : onApprovePressed,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('challengeApprove'.tr()),
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

Future<void> _handleAuthError(
  Object err,
  void Function() clearStoredPin,
) async {
  if (err is PlatformException) {
    // Biometric path error — handled by caller.
    return;
  }
  if (err is DioException) {
    final statusCode = err.response?.statusCode;
    // AUTH_SESSION_NOT_TRUSTED: only trusted sessions can approve/decline.
    if (statusCode == 403) {
      final apiError = ApiError.tryParse(err);
      if (apiError?.code == 'AUTH_SESSION_NOT_TRUSTED') {
        showSnackBar('challengeNotTrustedMessage'.tr());
        return;
      }
    }
    // Invalid PIN / missing credentials surface as 401/403.
    if (statusCode == 403 || statusCode == 401) {
      clearStoredPin();
      showSnackBar('invalidPin'.tr());
      return;
    }
  }
  showErrorAlert(err);
}

String _biometricError(Object err) {
  if (err is PlatformException) {
    return switch (err.code) {
      'NotAvailable' => 'biometricNotAvailable'.tr(),
      'NotEnrolled' => 'biometricNotEnrolled'.tr(),
      'LockedOut' || 'PermanentlyLockedOut' => 'biometricLockedOut'.tr(),
      _ => 'biometricAuthFailed'.tr(),
    };
  }
  return 'biometricAuthFailed'.tr();
}

PinTheme _pinTheme(
  ThemeData theme,
  ColorScheme scheme, {
  bool focused = false,
  bool submitted = false,
}) {
  return PinTheme(
    width: 48,
    height: 56,
    textStyle: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: focused
          ? Border.all(color: scheme.primary, width: 2)
          : submitted
          ? Border.all(color: scheme.outlineVariant)
          : Border.all(color: scheme.outline),
    ),
  );
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? valueColor;

  const _FactRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: valueStyle?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
