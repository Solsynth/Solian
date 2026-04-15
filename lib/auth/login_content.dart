import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/auth/login.dart';
import 'package:island/accounts/screens/punishment_user_sheet.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/accounts/screens/me/settings_connections.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/nfc_scan_service.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ndef/records/well_known/uri.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:pinput/pinput.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'captcha.dart';

/// Performs post-login tasks including fetching user info, subscribing to push
/// notifications, connecting websocket, and closing the login dialog.
Future<void> performPostLogin(BuildContext context, WidgetRef ref) async {
  final userNotifier = ref.read(userInfoProvider.notifier);
  await userNotifier.fetchUser();
  if (!context.mounted) return;
  final client = ref.read(solarNetworkClientProvider);
  final wsNotifier = ref.read(websocketStateProvider.notifier);
  await subscribePushNotification(client.dio, context: context);
  wsNotifier.connect();
  if (context.mounted && Navigator.canPop(context)) {
    Navigator.pop(context, true);
  }
}

Future<void> handleLockedError(
  BuildContext context,
  WidgetRef ref,
  dynamic error,
  String username,
) async {
  if (error is DioException && error.response?.statusCode == 423) {
    final client = ref.watch(solarNetworkClientProvider);
    try {
      final response = await client.dio.get(
        '/padlock/accounts/$username/punishments/overview',
      );
      final overview = response.data != null
          ? SnAccountPunishment.fromJson(response.data)
          : null;
      if (!context.mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) =>
            UserPunishmentsSheet(username: username, initialOverview: overview),
      );
    } catch (e) {
      // ignore
    }
  }
}

class _LoginCheckScreen extends HookConsumerWidget {
  final SnAuthChallenge? challenge;
  final SnAuthFactor? factor;
  final Function(SnAuthChallenge?) onChallenge;
  final VoidCallback onNext;
  final Function(bool) onBusy;

  const _LoginCheckScreen({
    super.key,
    required this.challenge,
    required this.factor,
    required this.onChallenge,
    required this.onNext,
    required this.onBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final passwordController = useTextEditingController();
    final isScanning = useState(false);
    final scanError = useState<String?>(null);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    Future<void> getToken({String? code}) async {
      // Get token if challenge is completed
      final client = ref.watch(apiClientProvider);
      final tokenResp = await client.post(
        '/padlock/auth/token',
        data: {
          'grant_type': 'authorization_code',
          'code': code ?? challenge!.id,
        },
      );
      final token = tokenResp.data['token'];
      setToken(ref.watch(sharedPreferencesProvider), token);
      ref.invalidate(tokenProvider);
      if (!context.mounted) return;

      // Do post login tasks
      await performPostLogin(context, ref);
    }

    useEffect(() {
      if (challenge != null && challenge?.stepRemain == 0) {
        Future(() {
          if (isBusy.value) return;
          isBusy.value = true;
          getToken().catchError((err) {
            showErrorAlert(err);
            isBusy.value = false;
          });
        });
      }
      return null;
    }, [challenge]);

    if (factor == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 26,
              child: const Icon(Symbols.asterisk, size: 28),
            ).padding(bottom: 8),
          ),
          Text(
            'loginInProgress'.tr(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ).padding(left: 4, bottom: 16),
          const Gap(16),
          CircularProgressIndicator().alignment(Alignment.centerLeft),
        ],
      );
    }

    Future<void> performCheckTicket() async {
      final pwd = passwordController.value.text;
      if (pwd.isEmpty) return;
      isBusy.value = true;
      try {
        final client = ref.watch(solarNetworkClientProvider);
        final resp = await client.dio.patch(
          '/padlock/auth/challenge/${challenge!.id}',
          data: {'factor_id': factor!.id, 'password': pwd},
        );
        final result = SnAuthChallenge.fromJson(resp.data);
        onChallenge(result);
        if (result.stepRemain > 0) {
          onNext();
          return;
        }

        await getToken(code: result.id);
      } catch (err) {
        showErrorAlert(err);
        return;
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> scanNfcTag() async {
      if (factor?.type != 6) return;

      isScanning.value = true;
      scanError.value = null;

      try {
        final availability = await NfcScanService().checkAvailability();
        if (availability != NFCAvailability.available) {
          scanError.value = 'nfcNotAvailable'.tr();
          isScanning.value = false;
          return;
        }

        final tag = await NfcScanService().scanTag();
        final records = await NfcScanService().readNdefRecords(tag);
        String? uidHex;
        if (records.isNotEmpty) {
          final firstRecord = records.first;
          if (firstRecord is UriRecord && firstRecord.uri != null) {
            final uri = firstRecord.uri!;
            uidHex = uri.queryParameters['uid'];
          }
        }

        if (uidHex == null) {
          showErrorAlert("No acceptable data found.");
          return;
        }

        passwordController.text = '${tag.id}:$uidHex';
        isScanning.value = false;
        await NfcScanService().finish();
        performCheckTicket();
      } catch (e) {
        scanError.value = e.toString();
        isScanning.value = false;
      }
    }

    Future<void> performPasskeyAuth() async {
      if (factor?.type != 7) return;

      isBusy.value = true;
      try {
        final passkeyAuthenticator = PasskeyAuthenticator(
          debugMode: kDebugMode,
        );
        final challenge = this.challenge;
        if (challenge == null) return;

        final serverUrl = ref.read(serverUrlProvider);
        final rpId = Uri.parse(serverUrl).host;

        final request = AuthenticateRequestType(
          challenge: base64Url.encode(challenge.id.codeUnits),
          relyingPartyId: rpId,
          userVerification: 'preferred',
          mediation: MediationType.Optional,
          preferImmediatelyAvailableCredentials: false,
        );

        final credential = await passkeyAuthenticator.authenticate(request);

        final client = ref.watch(solarNetworkClientProvider);
        final resp = await client.dio.patch(
          '/padlock/auth/challenge/${challenge.id}',
          data: {
            'factor_id': factor!.id,
            'credential_id': credential.id,
            'client_data_json': credential.clientDataJSON,
            'authenticator_data': credential.authenticatorData,
            'signature': credential.signature,
            'user_handle': credential.userHandle,
          },
        );
        final result = SnAuthChallenge.fromJson(resp.data);
        onChallenge(result);
        if (result.stepRemain > 0) {
          onNext();
          return;
        }

        await getToken(code: result.id);
      } catch (err) {
        showErrorAlert(err);
        return;
      } finally {
        isBusy.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.asterisk, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'loginEnterPassword'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4, bottom: 16),
        if (factor!.type == 6) ...[
          FilledButton.tonalIcon(
            onPressed: isBusy.value || isScanning.value ? null : scanNfcTag,
            icon: isScanning.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Symbols.nfc),
            label: Text(
              isScanning.value
                  ? 'scanning'.tr()
                  : 'physicalPassportScanToAuthenticate'.tr(),
            ),
          ),
          if (scanError.value != null) ...[
            const Gap(12),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Symbols.error,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        scanError.value!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ] else if (factor!.type == 7) ...[
          FilledButton.tonalIcon(
            onPressed: isBusy.value ? null : () => performPasskeyAuth(),
            icon: isBusy.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Symbols.fingerprint),
            label: Text('passkeyAuthenticate'.tr()),
          ),
        ] else if ([0].contains(factor!.type))
          TextField(
            autocorrect: false,
            enableSuggestions: false,
            controller: passwordController,
            obscureText: true,
            autofillHints: [
              factor!.type == 0
                  ? AutofillHints.password
                  : AutofillHints.oneTimeCode,
            ],
            decoration: InputDecoration(labelText: 'password'.tr()),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onSubmitted: isBusy.value ? null : (_) => performCheckTicket(),
          ).padding(horizontal: 7)
        else
          Pinput(
            showCursor: false,
            length: 6,
            obscureText: false,
            onSubmitted: (value) {
              passwordController.text = value;
              performCheckTicket();
            },
            onChanged: (value) => passwordController.text = value,
          ),
        const Gap(12),
        ListTile(
          leading: Icon(
            kFactorTypes[factor!.type]?.$3 ?? Symbols.question_mark,
          ),
          title: Text(kFactorTypes[factor!.type]?.$1 ?? 'unknown').tr(),
          subtitle: Text(kFactorTypes[factor!.type]?.$2 ?? 'unknown').tr(),
        ),
        const Gap(12),
        if (factor!.type != 6 && factor!.type != 7)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isBusy.value ? null : () => performCheckTicket(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('next').tr(),
                    const Icon(Symbols.chevron_right),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class LoginContent extends HookConsumerWidget {
  const LoginContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);

    final period = useState(0);
    final currentTicket = useState<SnAuthChallenge?>(null);
    final factors = useState<List<SnAuthFactor>>([]);
    final factorPicked = useState<SnAuthFactor?>(null);

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: Column(
        children: [
          if (isBusy.value)
            LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.zero,
              trackGap: 0,
              stopIndicatorRadius: 0,
            )
          else if (currentTicket.value != null)
            LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.zero,
              trackGap: 0,
              stopIndicatorRadius: 0,
              value:
                  1 -
                  (currentTicket.value!.stepRemain /
                      currentTicket.value!.stepTotal),
            )
          else
            const Gap(4),
          Expanded(
            child: SingleChildScrollView(
              child: PageTransitionSwitcher(
                transitionBuilder:
                    (
                      Widget child,
                      Animation<double> primaryAnimation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 380),
                          child: child,
                        ),
                      );
                    },
                child: switch (period.value % 3) {
                  1 => _LoginPickerScreen(
                    key: const ValueKey(1),
                    challenge: currentTicket.value,
                    factors: factors.value,
                    onChallenge: (SnAuthChallenge? p0) =>
                        currentTicket.value = p0,
                    onPickFactor: (SnAuthFactor p0) => factorPicked.value = p0,
                    onNext: () => period.value++,
                    onBusy: (value) => isBusy.value = value,
                  ),
                  2 => _LoginCheckScreen(
                    key: const ValueKey(2),
                    challenge: currentTicket.value,
                    factor: factorPicked.value,
                    onChallenge: (SnAuthChallenge? p0) =>
                        currentTicket.value = p0,
                    onNext: () => period.value = 1,
                    onBusy: (value) => isBusy.value = value,
                  ),
                  _ => _LoginLookupScreen(
                    key: const ValueKey(0),
                    ticket: currentTicket.value,
                    onChallenge: (SnAuthChallenge? p0) =>
                        currentTicket.value = p0,
                    onFactor: (List<SnAuthFactor>? p0) =>
                        factors.value = p0 ?? [],
                    onNext: () => period.value++,
                    onBusy: (value) => isBusy.value = value,
                  ),
                },
              ).padding(all: 24),
            ).center(),
          ),

          const Gap(4),
        ],
      ),
    );
  }
}

class _LoginPickerScreen extends HookConsumerWidget {
  final SnAuthChallenge? challenge;
  final List<SnAuthFactor>? factors;
  final Function(SnAuthChallenge?) onChallenge;
  final Function(SnAuthFactor) onPickFactor;
  final VoidCallback onNext;
  final Function(bool) onBusy;

  const _LoginPickerScreen({
    super.key,
    required this.challenge,
    required this.factors,
    required this.onChallenge,
    required this.onPickFactor,
    required this.onNext,
    required this.onBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final factorPicked = useState<SnAuthFactor?>(null);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    useEffect(() {
      if (challenge != null && challenge?.stepRemain == 0) {
        Future(() {
          onNext();
        });
      }
      return null;
    }, [challenge]);

    final unfocusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha((255 * 0.75).round());

    void performGetFactorCode() async {
      if (factorPicked.value == null) return;

      isBusy.value = true;
      final client = ref.watch(solarNetworkClientProvider);

      try {
        await client.dio.post(
          '/padlock/auth/challenge/${challenge!.id}/factors/${factorPicked.value!.id}',
        );
        onPickFactor(factors!.where((x) => x == factorPicked.value).first);
        onNext();
      } catch (err) {
        if (err is DioException && err.response?.statusCode == 400) {
          onPickFactor(factors!.where((x) => x == factorPicked.value).first);
          onNext();
          if (context.mounted) {
            showSnackBar(err.response!.data.toString());
          }
          return;
        }
        showErrorAlert(err);
        return;
      } finally {
        isBusy.value = false;
      }
    }

    return Column(
      key: const ValueKey<int>(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.lock, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'loginPickFactor'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4),
        const Gap(8),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children:
                factors
                    ?.map(
                      (x) => CheckboxListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        secondary: Icon(
                          kFactorTypes[x.type]?.$3 ?? Symbols.question_mark,
                        ),
                        title: Text(kFactorTypes[x.type]?.$1 ?? 'unknown').tr(),
                        enabled: !challenge!.blacklistFactors.contains(x.id),
                        value: factorPicked.value == x,
                        onChanged: (value) {
                          if (value == true) {
                            factorPicked.value = x;
                          }
                        },
                      ),
                    )
                    .toList() ??
                List.empty(),
          ),
        ),
        const Gap(8),
        Text(
          'loginMultiFactor'.plural(challenge!.stepRemain),
          style: TextStyle(color: unfocusColor, fontSize: 13),
        ).padding(horizontal: 16),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => performGetFactorCode(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('next'.tr()),
                  const Icon(Symbols.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginLookupScreen extends HookConsumerWidget {
  final SnAuthChallenge? ticket;
  final Function(SnAuthChallenge?) onChallenge;
  final Function(List<SnAuthFactor>?) onFactor;
  final VoidCallback onNext;
  final Function(bool) onBusy;

  const _LoginLookupScreen({
    super.key,
    required this.ticket,
    required this.onChallenge,
    required this.onFactor,
    required this.onNext,
    required this.onBusy,
  });

  Future<void> _showRecoveryCodeDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => HookBuilder(
        builder: (context) {
          final accountController = useTextEditingController();
          final codeController = useTextEditingController();
          final isRecovering = useState(false);

          return AlertDialog(
            title: Text('useRecoveryCode'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'recoveryCodeHint'.tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: accountController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'username'.tr(),
                    prefixIcon: const Icon(Symbols.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'recoveryCode'.tr(),
                    prefixIcon: const Icon(Symbols.key),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: isRecovering.value
                    ? null
                    : () async {
                        if (accountController.text.isEmpty ||
                            codeController.text.isEmpty) {
                          return;
                        }
                        isRecovering.value = true;
                        try {
                          final captchaTk = await CaptchaScreen.show(context);
                          if (captchaTk == null) {
                            isRecovering.value = false;
                            return;
                          }
                          final client = ref.read(solarNetworkClientProvider);
                          final resp = await client.dio.post(
                            '/padlock/auth/recover',
                            data: {
                              'account': accountController.text,
                              'recovery_code': codeController.text,
                              'captcha_token': captchaTk,
                              'device_id': await getUdid(),
                              'device_name': await getDeviceName(),
                              'platform': kIsWeb
                                  ? 1
                                  : switch (defaultTargetPlatform) {
                                      TargetPlatform.iOS => 2,
                                      TargetPlatform.android => 3,
                                      TargetPlatform.macOS => 4,
                                      TargetPlatform.windows => 5,
                                      TargetPlatform.linux => 6,
                                      _ => 0,
                                    },
                            },
                          );
                          if (!context.mounted) return;
                          final token = resp.data['token'];
                          setToken(
                            ref.watch(sharedPreferencesProvider),
                            token,
                            refreshToken: resp.data['refresh_token'] as String?,
                            expiresIn: (resp.data['expires_in'] as num?)
                                ?.toInt(),
                            refreshExpiresIn:
                                (resp.data['refresh_expires_in'] as num?)
                                    ?.toInt(),
                          );
                          ref.invalidate(tokenProvider);
                          if (!context.mounted) return;
                          await performPostLogin(context, ref);
                          if (!context.mounted) return;
                          Navigator.of(dialogContext).pop(true);
                        } catch (err) {
                          showErrorAlert(err);
                        } finally {
                          isRecovering.value = false;
                        }
                      },
                child: Text('recover'.tr()),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final usernameController = useTextEditingController();
    final waitingForOidc = useState(false);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    useEffect(() {
      final subscription = eventBus.on<OidcAuthCallbackEvent>().listen((
        event,
      ) async {
        if (!waitingForOidc.value || !context.mounted) return;
        waitingForOidc.value = false;
        final client = ref.watch(solarNetworkClientProvider);
        try {
          final resp = await client.dio.get(
            '/padlock/auth/challenge/${event.challengeId}',
          );
          final challenge = SnAuthChallenge.fromJson(resp.data);
          onChallenge(challenge);
          final factorResp = await client.dio.get(
            '/padlock/auth/challenge/${challenge.id}/factors',
          );
          onFactor(
            List<SnAuthFactor>.from(
              factorResp.data.map((ele) => SnAuthFactor.fromJson(ele)),
            ),
          );
          onNext();
        } catch (err) {
          showErrorAlert(err);
        }
      });
      return subscription.cancel;
    }, [waitingForOidc.value, context.mounted]);

    Future<void> requestResetPassword() async {
      final uname = usernameController.value.text;
      if (uname.isEmpty) {
        showErrorAlert('loginResetPasswordHint'.tr());
        return;
      }
      final captchaTk = await CaptchaScreen.show(context);
      if (captchaTk == null) return;
      isBusy.value = true;
      try {
        final client = ref.watch(solarNetworkClientProvider);
        await client.dio.post(
          '/passport/accounts/recovery/password',
          data: {'account': uname, 'captcha_token': captchaTk},
        );
        showInfoAlert('loginResetPasswordSent'.tr(), 'done'.tr());
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> performNewTicket() async {
      final uname = usernameController.value.text;
      if (uname.isEmpty) return;
      isBusy.value = true;
      try {
        final client = ref.watch(solarNetworkClientProvider);
        final resp = await client.dio.post(
          '/padlock/auth/challenge',
          data: {
            'account': uname,
            'device_id': await getUdid(),
            'device_name': await getDeviceName(),
            'platform': kIsWeb
                ? 1
                : switch (defaultTargetPlatform) {
                    TargetPlatform.iOS => 2,
                    TargetPlatform.android => 3,
                    TargetPlatform.macOS => 4,
                    TargetPlatform.windows => 5,
                    TargetPlatform.linux => 6,
                    _ => 0,
                  },
          },
        );
        final result = SnAuthChallenge.fromJson(resp.data);
        onChallenge(result);
        final factorResp = await client.dio.get(
          '/padlock/auth/challenge/${result.id}/factors',
        );
        onFactor(
          List<SnAuthFactor>.from(
            factorResp.data.map((ele) => SnAuthFactor.fromJson(ele)),
          ),
        );
        onNext();
      } catch (err) {
        await handleLockedError(context, ref, err, uname);
        if (!context.mounted) return;
        showErrorAlert(err);
        return;
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> withApple() async {
      final client = ref.watch(solarNetworkClientProvider);
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'dev.solsynth.solarpass',
            redirectUri: Uri.parse('https://nt.solian.app/auth/callback/apple'),
          ),
        );

        if (context.mounted) showLoadingModal(context);
        final resp = await client.dio.post(
          '/padlock/auth/login/apple/mobile',
          data: {
            'identity_token': credential.identityToken!,
            'authorization_code': credential.authorizationCode,
            'device_id': await getUdid(),
            'device_name': await getDeviceName(),
          },
        );

        final token = resp.data['token'];
        setToken(
          ref.watch(sharedPreferencesProvider),
          token,
          refreshToken: resp.data['refresh_token'] as String?,
          expiresIn: (resp.data['expires_in'] as num?)?.toInt(),
          refreshExpiresIn: (resp.data['refresh_expires_in'] as num?)?.toInt(),
        );
        ref.invalidate(tokenProvider);
        if (!context.mounted) return;

        // Do post login tasks
        await performPostLogin(context, ref);
      } catch (err) {
        if (err is SignInWithAppleAuthorizationException) return;
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> withOidc(String provider) async {
      waitingForOidc.value = true;
      final serverUrl = ref.watch(serverUrlProvider);
      final token = ref.watch(tokenProvider);
      final deviceId = await getUdid();
      final queryParams = <String, String>{
        'returnUrl': 'solian://auth/callback',
        'deviceId': deviceId,
        'flow': 'login',
      };
      if (token?.token != null) {
        queryParams['token'] = token!.token;
      }
      final url = Uri.parse(
        '$serverUrl/padlock/auth/login/${provider.toLowerCase()}',
      ).replace(queryParameters: queryParams).toString();
      final isLaunched = await launchUrlString(
        url,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
        webOnlyWindowName: token?.token != null
            ? 'auth-${token!.token}'
            : 'auth',
      );
      if (!isLaunched) {
        waitingForOidc.value = false;
        showErrorAlert('failedToLaunchBrowser'.tr());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.login, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'loginGreeting'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4, bottom: 16),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          controller: usernameController,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            labelText: 'username'.tr(),
            helperText: 'usernameLookupHint'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNewTicket(),
        ).padding(horizontal: 7),
        if (!kIsWeb)
          Row(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("loginOr").tr().fontSize(11).opacity(0.85),
              const Gap(8),
              Spacer(),
              IconButton.filledTonal(
                onPressed: () => withOidc('github'),
                padding: EdgeInsets.zero,
                icon: getProviderIcon(
                  "github",
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: 'GitHub',
              ),
              IconButton.filledTonal(
                onPressed: () => withOidc('google'),
                padding: EdgeInsets.zero,
                icon: getProviderIcon(
                  "google",
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: 'Google',
              ),
              IconButton.filledTonal(
                onPressed: withApple,
                padding: EdgeInsets.zero,
                icon: getProviderIcon(
                  "apple",
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: 'Apple Account',
              ),
            ],
          ).padding(horizontal: 8, vertical: 8)
        else
          const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isBusy.value ? null : () => performNewTicket(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('next').tr(), const Icon(Symbols.chevron_right)],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isBusy.value ? null : () => requestResetPassword(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text('forgotPassword'.tr()),
                const Icon(Symbols.key_off),
              ],
            ),
          ).padding(left: 12),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isBusy.value
                ? null
                : () => _showRecoveryCodeDialog(context, ref),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [Text('useRecoveryCode'.tr()), const Icon(Symbols.key)],
            ),
          ).padding(left: 12),
        ),
        const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: StyledWidget(
            Container(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'termAcceptNextWithAgree'.tr(),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.75).round()),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('termAcceptLink'.tr()),
                          const Gap(4),
                          const Icon(Symbols.launch, size: 14),
                        ],
                      ),
                      onTap: () {
                        launchUrlString('https://solsynth.dev/terms');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ).padding(horizontal: 16),
        ),
      ],
    );
  }
}
