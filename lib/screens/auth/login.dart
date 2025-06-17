import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/models/auth.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/screens/account/me/settings_connections.dart';
import 'package:island/screens/auth/oidc.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/udid.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'captcha.dart';

final Map<int, (String, String, IconData)> kFactorTypes = {
  0: ('authFactorPassword', 'authFactorPasswordDescription', Symbols.password),
  1: ('authFactorEmail', 'authFactorEmailDescription', Symbols.email),
  2: (
    'authFactorInAppNotify',
    'authFactorInAppNotifyDescription',
    Symbols.notifications_active,
  ),
  3: ('authFactorTOTP', 'authFactorTOTPDescription', Symbols.timer),
};

@RoutePage()
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);

    final period = useState(0);
    final currentTicket = useState<SnAuthChallenge?>(null);
    final factors = useState<List<SnAuthFactor>>([]);
    final factorPicked = useState<SnAuthFactor?>(null);

    return AppScaffold(
      noBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('login').tr(),
      ),
      body: Theme(
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
              child:
                  SingleChildScrollView(
                    child: PageTransitionSwitcher(
                      transitionBuilder: (
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
                          ticket: currentTicket.value,
                          factors: factors.value,
                          onChallenge:
                              (SnAuthChallenge? p0) => currentTicket.value = p0,
                          onPickFactor:
                              (SnAuthFactor p0) => factorPicked.value = p0,
                          onNext: () => period.value++,
                          onBusy: (value) => isBusy.value = value,
                        ),
                        2 => _LoginCheckScreen(
                          key: const ValueKey(2),
                          challenge: currentTicket.value,
                          factor: factorPicked.value,
                          onChallenge:
                              (SnAuthChallenge? p0) => currentTicket.value = p0,
                          onNext: () => period.value = 1,
                          onBusy: (value) => isBusy.value = value,
                        ),
                        _ => _LoginLookupScreen(
                          key: const ValueKey(0),
                          ticket: currentTicket.value,
                          onChallenge:
                              (SnAuthChallenge? p0) => currentTicket.value = p0,
                          onFactor:
                              (List<SnAuthFactor>? p0) =>
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
      ),
    );
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

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    Future<void> getToken({String? code}) async {
      // Get token if challenge is completed
      final client = ref.watch(apiClientProvider);
      final tokenResp = await client.post(
        '/auth/token',
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
      final userNotifier = ref.read(userInfoProvider.notifier);
      userNotifier.fetchUser().then((_) {
        final apiClient = ref.read(apiClientProvider);
        subscribePushNotification(apiClient);
        final wsNotifier = ref.read(websocketStateProvider.notifier);
        wsNotifier.connect();
        if (context.mounted) Navigator.pop(context, true);
      });

      // Update the sessions' device name is available
      if (!kIsWeb) {
        String? name;
        if (Platform.isIOS) {
          final deviceInfo = await DeviceInfoPlugin().iosInfo;
          name = deviceInfo.name;
        } else if (Platform.isAndroid) {
          final deviceInfo = await DeviceInfoPlugin().androidInfo;
          name = deviceInfo.name;
        } else if (Platform.isWindows) {
          final deviceInfo = await DeviceInfoPlugin().windowsInfo;
          name = deviceInfo.computerName;
        }
        if (name != null) {
          final client = ref.watch(apiClientProvider);
          await client.patch(
            '/accounts/me/sessions/current/label',
            data: jsonEncode(name),
          );
        }
      }
    }

    useEffect(() {
      if (challenge != null && challenge?.stepRemain == 0) {
        Future(() {
          isBusy.value = true;
          getToken().catchError((err) {
            showErrorAlert(err);
            isBusy.value = false;
          });
        });
      }
      return null;
    }, [challenge]);

    Future<void> performCheckTicket() async {
      final pwd = passwordController.value.text;
      if (pwd.isEmpty) return;
      isBusy.value = true;
      try {
        // Pass challenge
        final client = ref.watch(apiClientProvider);
        final resp = await client.patch(
          '/auth/challenge/${challenge!.id}',
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

    final width = math.min(380, MediaQuery.of(context).size.width);

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
        if ([0].contains(factor!.type))
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
            decoration: InputDecoration(
              isDense: true,
              labelText: 'password'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onSubmitted: isBusy.value ? null : (_) => performCheckTicket(),
          ).padding(horizontal: 7)
        else
          OtpTextField(
            showCursor: false,
            numberOfFields: 6,
            obscureText: false,
            showFieldAsBox: true,
            focusedBorderColor: Theme.of(context).colorScheme.primary,
            fieldWidth: (width / 6) - 10,
            onSubmit: (value) {
              passwordController.text = value;
              performCheckTicket();
            },
            textStyle: Theme.of(context).textTheme.titleLarge!,
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

class _LoginPickerScreen extends HookConsumerWidget {
  final SnAuthChallenge? ticket;
  final List<SnAuthFactor>? factors;
  final Function(SnAuthChallenge?) onChallenge;
  final Function(SnAuthFactor) onPickFactor;
  final VoidCallback onNext;
  final Function(bool) onBusy;

  const _LoginPickerScreen({
    super.key,
    required this.ticket,
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
      if (ticket != null && ticket?.stepRemain == 0) {
        onPickFactor(factors!.first);
        onNext();
      }
      return null;
    }, [ticket]);

    final unfocusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha((255 * 0.75).round());

    final hintController = useTextEditingController();

    void performGetFactorCode() async {
      if (factorPicked.value == null) return;

      isBusy.value = true;
      final client = ref.watch(apiClientProvider);

      try {
        await client.post(
          '/auth/challenge/${ticket!.id}/factors/${factorPicked.value!.id}',
          data:
              hintController.text.isNotEmpty
                  ? jsonEncode(hintController.text)
                  : null,
        );
        onPickFactor(factors!.where((x) => x == factorPicked.value).first);
        onNext();
      } catch (err) {
        if (err is DioException && err.response?.statusCode == 400) {
          onPickFactor(factors!.where((x) => x == factorPicked.value).first);
          onNext();
          if (context.mounted) {
            showSnackBar(context, err.response!.data.toString());
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
          'loginPickFactor',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).tr().padding(left: 4),
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
                        enabled: !ticket!.blacklistFactors.contains(x.id),
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
        if ([1].contains(factorPicked.value?.type))
          TextField(
            controller: hintController,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              labelText: 'authFactorHint'.tr(),
              helperText: 'authFactorHintHelper'.tr(),
            ),
          ).padding(top: 12, bottom: 4, horizontal: 4),
        const Gap(8),
        Text(
          'loginMultiFactor'.plural(ticket!.stepRemain),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final usernameController = useTextEditingController();

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    Future<void> requestResetPassword() async {
      final uname = usernameController.value.text;
      if (uname.isEmpty) {
        showErrorAlert('loginResetPasswordHint'.tr());
        return;
      }
      final captchaTk = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => CaptchaScreen()));
      if (captchaTk == null) return;
      isBusy.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/accounts/recovery/password',
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
        final client = ref.watch(apiClientProvider);
        final resp = await client.post(
          '/auth/challenge',
          data: {
            'account': uname,
            'device_id': await getUdid(),
            'platform':
                kIsWeb
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
        final factorResp = await client.get(
          '/auth/challenge/${result.id}/factors',
        );
        onFactor(
          List<SnAuthFactor>.from(
            factorResp.data.map((ele) => SnAuthFactor.fromJson(ele)),
          ),
        );
        onNext();
      } catch (err) {
        showErrorAlert(err);
        return;
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> withApple() async {
      final client = ref.watch(apiClientProvider);
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'dev.solsynth.solarpass',
            redirectUri: Uri.parse('https://nt.solian.app/auth/callback/apple'),
          ),
        );

        if (context.mounted) showLoadingModal(context);
        final resp = await client.post(
          '/auth/login/apple/mobile',
          data: {
            'identity_token': credential.identityToken!,
            'authorization_code': credential.authorizationCode,
            'device_id': await getUdid(),
          },
        );

        final challenge = SnAuthChallenge.fromJson(resp.data);
        onChallenge(challenge);
        final factorResp = await client.get(
          '/auth/challenge/${challenge.id}/factors',
        );
        onFactor(
          List<SnAuthFactor>.from(
            factorResp.data.map((ele) => SnAuthFactor.fromJson(ele)),
          ),
        );
        onNext();
      } catch (err) {
        if (err is SignInWithAppleAuthorizationException) return;
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> withOidc(String provider) async {
      final challengeId = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OidcScreen(provider: provider.toLowerCase()),
        ),
      );

      final client = ref.watch(apiClientProvider);
      try {
        final resp = await client.get('/auth/challenge/$challengeId');
        final challenge = SnAuthChallenge.fromJson(resp.data);
        onChallenge(challenge);
        final factorResp = await client.get(
          '/auth/challenge/${challenge.id}/factors',
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
          'loginGreeting',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).tr().padding(left: 4, bottom: 16),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          controller: usernameController,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'username'.tr(),
            helperText: 'usernameLookupHint'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNewTicket(),
        ).padding(horizontal: 7),
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
        ).padding(horizontal: 8, vertical: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => requestResetPassword(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text('forgotPassword'.tr()),
            ),
            TextButton(
              onPressed: isBusy.value ? null : () => performNewTicket(),
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
