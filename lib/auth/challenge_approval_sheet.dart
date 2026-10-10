import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/auth/sudo_prompt.dart';
import 'package:island/auth/widgets/auth_consent.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/api_error.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:relative_time/relative_time.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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

    // Guards the sheet against double-resolution when a poll tick races the
    // local approve/decline path.
    final resolved = useState(false);

    // Surfaced inline rather than only as a transient snackbar, so the user can
    // see why an attempt failed.
    final authError = useState<String?>(null);

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
      if (resolved.value) return null;

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
    }, [challenge.id, resolved.value]);

    final expired = remaining.value != null && remaining.value! <= 0;

    // Approving someone else's login is a gated action, so it elevates this
    // session first (via the shared sudo prompt) and then retries once. No
    // credential is sent with the approval itself.
    Future<void> approve() async {
      if (isBusy.value) return;
      isBusy.value = true;
      authError.value = null;
      try {
        await withSudoRetry(
          context,
          ref,
          () => ref
              .read(solarNetworkClientProvider)
              .auth
              .approveChallenge(challengeId: challenge.id),
        );
        if (!context.mounted) return;
        resolved.value = true;
        showSnackBar(
          'challengeApprovedByYou'.tr(
            args: [challenge.deviceName ?? 'unknownDevice'.tr()],
          ),
        );
        Navigator.pop(context);
        onResolved?.call();
      } catch (err) {
        authError.value = _authErrorMessage(err);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> decline() async {
      if (isBusy.value) return;
      isBusy.value = true;
      authError.value = null;
      try {
        await withSudoRetry(
          context,
          ref,
          () => ref
              .read(solarNetworkClientProvider)
              .auth
              .declineChallenge(challengeId: challenge.id),
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
        authError.value = _authErrorMessage(err);
      } finally {
        isBusy.value = false;
      }
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final account = ref.watch(userInfoProvider).value;
    final deviceName = challenge.deviceName ?? 'unknownDevice'.tr();

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
                                authPlatformIcon(challenge.platform),
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
                                    deviceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const Gap(2),
                                  Text(
                                    authPlatformName(challenge.platform),
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
                            AuthFactRow(
                              label: 'challengeIpAddress'.tr(),
                              value: challenge.ipAddress,
                            ),
                            AuthFactRow(
                              label: 'challengeLocation'.tr(),
                              value: location.isNotEmpty
                                  ? location
                                  : 'unknown'.tr(),
                            ),
                            AuthFactRow(
                              label: 'challengeRequested'.tr(),
                              value: RelativeTime(
                                context,
                              ).format(challenge.createdAt),
                            ),
                            if (remaining.value != null)
                              AuthFactRow(
                                label: 'challengeExpiresIn'.tr(),
                                value: 'challengeSeconds'.tr(
                                  args: ['${remaining.value}'],
                                ),
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

                      // Who the approval is attributed to.
                      if (account != null) ...[
                        const SizedBox(height: 12),
                        AuthAuthorityCard(
                          label: 'authConsentApprovingAs'.tr(),
                          accountName: account.nick.isNotEmpty
                              ? account.nick
                              : account.name,
                          accountHandle: account.name,
                          picture: account.profile.picture,
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (authError.value != null) ...[
                AuthInlineError(message: authError.value),
                const SizedBox(height: 12),
              ],
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
                        onPressed: isBusy.value ? null : decline,
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
                        onPressed: isBusy.value ? null : approve,
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

/// Resolves an approve/decline failure into inline copy.
///
/// Returns null when the failure was handed to [showErrorAlert].
String? _authErrorMessage(Object err) {
  if (err is DioException) {
    final apiError = ApiError.tryParse(err);
    // AUTH_SESSION_NOT_TRUSTED: only trusted sessions can approve/decline.
    if (apiError?.code == 'AUTH_SESSION_NOT_TRUSTED') {
      return 'challengeNotTrustedMessage'.tr();
    }
    // The elevation prompt was dismissed, so nothing was approved/declined.
    if (isSudoRequired(err)) {
      return 'sudoNotCompleted'.tr();
    }
  }

  showErrorAlert(err);
  return null;
}
