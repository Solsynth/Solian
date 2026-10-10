import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/auth/auth_form_widgets.dart';
import 'package:island/auth/widgets/auth_factor_widgets.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/api_error.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Server error code Stargate answers a gated endpoint with when the session
/// has not re-authenticated recently enough.
const String kSudoRequiredCode = 'AUTH_SUDO_REQUIRED';

/// Server error code Stargate answers `POST /auth/sudo` with when the account
/// has no factor that could satisfy the elevation demand. Elevation can never
/// succeed, so the client must not retry the gated action.
const String kSudoNoFactorsCode = 'AUTH_NO_AUTH_FACTORS';

/// Whether [err] is Stargate refusing a gated action until the session is
/// elevated. Everything else — a 401, an unrelated 403 — must be left alone.
bool isSudoRequired(Object err) => _sudoErrorCode(err) == kSudoRequiredCode;

bool _isSudoUnavailable(Object err) => _sudoErrorCode(err) == kSudoNoFactorsCode;

String? _sudoErrorCode(Object err) {
  if (err is! DioException) return null;
  if (err.response?.statusCode != 403) return null;
  final code = ApiError.tryParse(err)?.code;
  return code == null || code == 'UNKNOWN_ERROR' ? null : code;
}

/// Runs [action] and, when Stargate answers 403 `AUTH_SUDO_REQUIRED`, walks the
/// user through [showSudoPrompt] and retries the same request exactly once.
///
/// The retry is deliberate and single: a second refusal (the elevation lapsed,
/// the account lost its last factor) is handed back to the caller rather than
/// prompting again, so a server that keeps refusing cannot loop the UI.
///
/// [onBeforePrompt] runs after the refusal and before the elevation sheet is
/// shown; callers use it to dismiss their own busy/loading surface so the
/// prompt is not stacked on top of a spinner.
Future<T> withSudoRetry<T>(
  BuildContext context,
  WidgetRef ref,
  Future<T> Function() action, {
  FutureOr<void> Function()? onBeforePrompt,
}) async {
  try {
    return await action();
  } on DioException catch (err) {
    if (!isSudoRequired(err) || !context.mounted) rethrow;

    if (onBeforePrompt != null) await onBeforePrompt();
    if (!context.mounted) rethrow;

    final elevated = await showSudoPrompt(context, ref);
    if (!elevated) rethrow;

    return await action();
  }
}

/// Starts a step-up elevation challenge and walks the user through it in a
/// sheet, returning whether the session was elevated.
///
/// The challenge itself is opened before the sheet exists, so an account that
/// cannot elevate at all (no factor, maintenance, rate limit) fails with an
/// alert instead of an empty picker.
Future<bool> showSudoPrompt(BuildContext context, WidgetRef ref) async {
  final SnAuthChallenge challenge;
  try {
    challenge = await ref.read(solarNetworkClientProvider).auth.startSudo();
  } catch (err) {
    if (_isSudoUnavailable(err)) {
      showErrorAlert('sudoUnavailable'.tr());
    } else {
      showErrorAlert(err);
    }
    return false;
  }

  if (!context.mounted) return false;
  return SudoPromptSheet.show(context, challenge);
}

/// Completes one elevation challenge: pick a factor, deliver its code, submit
/// the step, repeat until the server reports no trust points remain.
class SudoPromptSheet extends HookConsumerWidget {
  final SnAuthChallenge challenge;

  const SudoPromptSheet({super.key, required this.challenge});

  /// Shows the sheet and resolves to whether the session was elevated.
  static Future<bool> show(
    BuildContext context,
    SnAuthChallenge challenge,
  ) async {
    final elevated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => SudoPromptSheet(challenge: challenge),
    );
    return elevated ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticket = useState<SnAuthChallenge>(challenge);
    final factors = useState<List<SnAuthFactor>?>(null);
    final picked = useState<SnAuthFactor?>(null);
    // 0 = pick a factor, 1 = enter its credential.
    final step = useState(0);
    final isBusy = useState(false);
    final codeController = useTextEditingController();

    useEffect(() {
      Future(() async {
        isBusy.value = true;
        try {
          final client = ref.read(solarNetworkClientProvider);
          final fetched = await client.auth.getChallengeFactors(
            ticket.value.id,
          );
          factors.value = fetched.where(_canCompleteInPlace).toList();
          isBusy.value = false;
        } catch (err) {
          if (!context.mounted) return;
          showErrorAlert(err);
          Navigator.pop(context, false);
        }
      });
      return null;
    }, const []);

    /// Delivers the picked factor's code, then moves to the credential step.
    /// A 400 means Stargate refused to send another code because one is
    /// already live — the step is still completable, so it proceeds like the
    /// login picker does.
    Future<void> sendFactorCode() async {
      final factor = picked.value;
      if (factor == null || isBusy.value) return;
      isBusy.value = true;
      try {
        await ref
            .read(solarNetworkClientProvider)
            .auth
            .sendChallengeFactor(
              challengeId: ticket.value.id,
              factorId: factor.id,
            );
        step.value = 1;
        codeController.clear();
      } on DioException catch (err) {
        if (err.response?.statusCode == 400) {
          if (context.mounted) showSnackBar(err.response!.data.toString());
          step.value = 1;
          codeController.clear();
        } else {
          showErrorAlert(err);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> submitStep() async {
      final factor = picked.value;
      final response = codeController.text;
      if (factor == null || response.isEmpty || isBusy.value) return;
      isBusy.value = true;
      try {
        final result = await ref
            .read(solarNetworkClientProvider)
            .auth
            .submitChallengeFactor(
              challengeId: ticket.value.id,
              factorId: factor.id,
              response: response,
            );
        ticket.value = result;

        if (result.stepRemain > 0) {
          // Short of the demand: the challenge now blacklists the factor that
          // just counted, so send the user back to the picker.
          step.value = 0;
          picked.value = null;
          codeController.clear();
          return;
        }

        if (!context.mounted) return;
        showSnackBar('sudoGranted'.tr());
        Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final factor = picked.value;
    final Widget body;

    if (step.value == 1 && factor != null) {
      final Widget credential;
      if (factor.type == 0 || factor.type == 5) {
        credential = AuthFactorTextInput(
          controller: codeController,
          label: factor.type == 0
              ? 'password'.tr()
              : 'authFactorRecoveryCode'.tr(),
          obscureText: factor.type == 0,
          onSubmitted: isBusy.value ? null : (_) => submitStep(),
        );
      } else {
        credential = AuthFactorCodeInput(
          onSubmitted: (value) {
            codeController.text = value;
            submitStep();
          },
          onChanged: (value) => codeController.text = value,
        );
      }

      body = AuthFormColumn(
        children: [
          AuthFormHeader(
            icon: Symbols.lock,
            title: 'loginEnterPassword'.tr(),
            subtitle: 'sudoPromptDescription'.tr(),
          ),
          credential,
          AuthSectionCard(
            children: [
              ListTile(
                leading: Icon(
                  kFactorTypes[factor.type]?.$3 ?? Symbols.question_mark,
                  color: scheme.primary,
                ),
                title: Text(kFactorTypes[factor.type]?.$1 ?? 'unknown').tr(),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kFactorTypes[factor.type]?.$2 ?? 'unknown').tr(),
                    const Gap(6),
                    AuthFactorTrustChip(trustworthy: factor.trustworthy),
                  ],
                ),
                isThreeLine: true,
              ),
            ],
          ),
          AuthFormActions(
            showBack: true,
            onBack: () {
              step.value = 0;
              codeController.clear();
            },
            isBusy: isBusy.value,
            onNext: submitStep,
          ),
        ],
      );
    } else {
      final loaded = factors.value;
      body = AuthFormColumn(
        children: [
          AuthFormHeader(
            icon: Symbols.lock,
            title: 'loginPickFactor'.tr(),
            subtitle: 'loginMultiFactor'.plural(ticket.value.stepRemain),
          ),
          if (loaded == null)
            const Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(),
            )
          else if (loaded.isEmpty)
            AuthErrorBanner(message: 'sudoNoFactors'.tr())
          else
            AuthFactorRadioList(
              factors: loaded,
              selected: picked.value,
              blacklistedIds: ticket.value.blacklistFactors,
              enabled: !isBusy.value,
              onSelected: (value) => picked.value = value,
            ),
          AuthFormActions(
            isBusy: isBusy.value || picked.value == null,
            onNext: sendFactorCode,
          ),
        ],
      );
    }

    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return SheetScaffold(
      titleText: 'sudoPromptTitle'.tr(),
      heightFactor: isMobile ? 0.9 : 0.8,
      child: SafeArea(
        child: Column(
          children: [
            if (isBusy.value)
              const LinearProgressIndicator(minHeight: 4)
            else
              const SizedBox(height: 4),
            Expanded(child: AuthFormShell(child: body)),
          ],
        ),
      ),
    );
  }
}

/// Whether the elevation sheet can complete [factor] without leaving it — the
/// notification, physical passport, passkey and QR factors need surfaces this
/// prompt does not own.
bool _canCompleteInPlace(SnAuthFactor factor) => switch (factor.type) {
  0 || 1 || 3 || 4 || 5 => true,
  _ => false,
};
