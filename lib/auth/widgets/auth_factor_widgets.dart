import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/auth/auth_form_widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Every factor type Stargate can offer, as `(titleKey, descriptionKey, icon)`.
///
/// Shared by the login flow, the step-up (sudo) prompt and the security
/// settings so every surface names and draws a factor the same way.
final Map<int, (String, String, IconData)> kFactorTypes = {
  0: (
    'authFactorPassword',
    'authFactorPasswordDescription',
    Symbols.password,
  ),
  1: ('authFactorEmail', 'authFactorEmailDescription', Symbols.email),
  2: (
    'authFactorInAppNotify',
    'authFactorInAppNotifyDescription',
    Symbols.notifications_active,
  ),
  3: ('authFactorTOTP', 'authFactorTOTPDescription', Symbols.timer),
  4: ('authFactorPin', 'authFactorPinDescription', Symbols.nest_secure_alarm),
  5: (
    'authFactorRecoveryCode',
    'authFactorRecoveryCodeDescription',
    Symbols.key,
  ),
  6: (
    'authFactorPhysicalPassport',
    'authFactorPhysicalPassportDescription',
    Symbols.badge,
  ),
  7: ('authFactorPasskey', 'authFactorPasskeyDescription', Symbols.fingerprint),
  8: ('authFactorQrLogin', 'authFactorQrLoginDescription', Symbols.qr_code_2),
};

/// Compact chip showing how many trust points a factor contributes.
class AuthFactorTrustChip extends StatelessWidget {
  final int trustworthy;

  const AuthFactorTrustChip({super.key, required this.trustworthy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Chip(
      avatar: Icon(
        Symbols.shield_person,
        size: 16,
        color: scheme.onSecondaryContainer,
      ),
      label: Text('authFactorTrustworthy'.tr(args: ['$trustworthy'])),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.only(right: 8),
      backgroundColor: scheme.secondaryContainer,
      side: BorderSide.none,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// The pickable factor list of a challenge, rendered as radio tiles.
///
/// Factors listed in [blacklistedIds] have already been consumed by the
/// challenge and stay visible but unselectable, matching Stargate's
/// `blacklist_factors`.
class AuthFactorRadioList extends StatelessWidget {
  final List<SnAuthFactor> factors;
  final SnAuthFactor? selected;
  final List<String> blacklistedIds;
  final ValueChanged<SnAuthFactor> onSelected;
  final bool enabled;

  const AuthFactorRadioList({
    super.key,
    required this.factors,
    required this.selected,
    required this.onSelected,
    this.blacklistedIds = const [],
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AuthSectionCard(
      children: factors
          .map(
            (x) => RadioListTile<SnAuthFactor>(
              value: x,
              groupValue: selected,
              onChanged: !enabled || blacklistedIds.contains(x.id)
                  ? null
                  : (value) {
                      if (value != null) onSelected(value);
                    },
              secondary: Icon(
                kFactorTypes[x.type]?.$3 ?? Symbols.question_mark,
                color: scheme.primary,
              ),
              title: Text(kFactorTypes[x.type]?.$1 ?? 'unknown').tr(),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kFactorTypes[x.type]?.$2 ?? 'unknown').tr(),
                  const Gap(6),
                  AuthFactorTrustChip(trustworthy: x.trustworthy),
                ],
              ),
              isThreeLine: true,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          )
          .toList(),
    );
  }
}

/// Six-digit code entry for the code factors (email, TOTP, PIN).
///
/// [onSubmitted] fires for both an explicit submit and the last digit, which is
/// how every caller wants a fixed-length code to behave. Pass null to keep the
/// field visible but unable to submit while a request is in flight.
class AuthFactorCodeInput extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const AuthFactorCodeInput({super.key, this.onSubmitted, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary, width: 2),
      ),
    );

    return Pinput(
      showCursor: true,
      length: 6,
      obscureText: false,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: focusedPinTheme,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      onCompleted: onSubmitted,
    );
  }
}

/// Free-text credential entry for the factor types that are not a fixed-length
/// code: the password ([obscureText]) and recovery codes.
///
/// Pass a null [onSubmitted] to keep the field visible but unable to submit
/// while a request is in flight.
class AuthFactorTextInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final String label;
  final bool obscureText;

  const AuthFactorTextInput({
    super.key,
    required this.controller,
    required this.label,
    this.onSubmitted,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      enableSuggestions: false,
      controller: controller,
      obscureText: obscureText,
      autofillHints: obscureText
          ? const [AutofillHints.password]
          : null,
      decoration: InputDecoration(labelText: label),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onSubmitted: onSubmitted,
    );
  }
}
