import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'captcha.dart';

const kServerSupportedLanguages = {'en-US': 'en-us', 'zh-CN': 'zh-hans'};

Widget getProviderIcon(String provider, {double size = 24, Color? color}) {
  final providerLower = provider.toLowerCase();

  // Check if we have an SVG for this provider
  switch (providerLower) {
    case 'apple':
    case 'microsoft':
    case 'google':
    case 'github':
    case 'discord':
    case 'afdian':
    case 'steam':
      return SvgPicture.asset(
        'assets/images/oidc/$providerLower.svg',
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
    case 'spotify':
      return Image.asset(
        'assets/images/oidc/spotify.png',
        width: size,
        height: size,
        color: color,
      );
    default:
      return Icon(Symbols.link, size: size);
  }
}

// Helper widget for bullet list items
class _BulletPoint extends StatelessWidget {
  final List<Widget> children;

  const _BulletPoint({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// Stage 1: Email Entry
class _CreateAccountEmailScreen extends HookConsumerWidget {
  final TextEditingController emailController;
  final TextEditingController affiliationSpellController;
  final VoidCallback onNext;
  final Function(bool) onBusy;
  final Function(String) onOidc;

  const _CreateAccountEmailScreen({
    super.key,
    required this.emailController,
    required this.affiliationSpellController,
    required this.onNext,
    required this.onBusy,
    required this.onOidc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    Future<void> performNext() async {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        showErrorAlert('fieldCannotBeEmpty'.tr());
        return;
      }
      if (!EmailValidator.validate(email)) {
        showErrorAlert('fieldEmailAddressMustBeValid'.tr());
        return;
      }

      // Validate email availability with API
      isBusy.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/pass/accounts/validate',
          data: {
            'email': email,
            if (affiliationSpellController.text.isNotEmpty)
              'affiliation_spell': affiliationSpellController.text.trim(),
          },
        );
        onNext();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.mail, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'createAccount',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).tr().padding(left: 4, bottom: 16),
        TextField(
          controller: emailController,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'email'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ).padding(horizontal: 7),
        const Gap(12),
        TextField(
          controller: affiliationSpellController,
          autocorrect: false,
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'affiliationSpell'.tr(),
            helperText: 'affiliationSpellHint'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ).padding(horizontal: 7),
        if (!kIsWeb)
          Row(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("orCreateWith").tr().fontSize(11).opacity(0.85),
              const Gap(8),
              Spacer(),
              IconButton.filledTonal(
                onPressed: () => onOidc('github'),
                padding: EdgeInsets.zero,
                icon: getProviderIcon(
                  "github",
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: 'GitHub',
              ),
              IconButton.filledTonal(
                onPressed: () => onOidc('google'),
                padding: EdgeInsets.zero,
                icon: getProviderIcon(
                  "google",
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: 'Google',
              ),
              IconButton.filledTonal(
                onPressed: () => onOidc('apple'),
                padding: EdgeInsets.zero,
                icon: getProviderIcon(
                  "apple",
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: 'Apple Account',
              ),
            ],
          ).padding(horizontal: 8, top: 12)
        else
          const Gap(12),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => performNext(),
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

// Stage 2: Password Entry
class _CreateAccountPasswordScreen extends HookConsumerWidget {
  final TextEditingController passwordController;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(bool) onBusy;

  const _CreateAccountPasswordScreen({
    super.key,
    required this.passwordController,
    required this.onNext,
    required this.onBack,
    required this.onBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    void performNext() {
      final password = passwordController.text;
      if (password.isEmpty) {
        showErrorAlert('fieldCannotBeEmpty'.tr());
        return;
      }
      onNext();
    }

    return Column(
      key: const ValueKey<int>(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.password, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'password',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).tr().padding(left: 4, bottom: 16),
        TextField(
          controller: passwordController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'password'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ).padding(horizontal: 7),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => onBack(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Symbols.chevron_left), Text('back').tr()],
              ),
            ),
            TextButton(
              onPressed: isBusy.value ? null : () => performNext(),
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

// Stage 3: Username and Nickname Entry
class _CreateAccountProfileScreen extends HookConsumerWidget {
  final TextEditingController usernameController;
  final TextEditingController nicknameController;
  final bool isOidcFlow;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(bool) onBusy;

  const _CreateAccountProfileScreen({
    super.key,
    required this.usernameController,
    required this.nicknameController,
    required this.isOidcFlow,
    required this.onNext,
    required this.onBack,
    required this.onBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    Future<void> performNext() async {
      final username = usernameController.text.trim();
      final nickname = nicknameController.text.trim();
      if (username.isEmpty || nickname.isEmpty) {
        showErrorAlert('fieldCannotBeEmpty'.tr());
        return;
      }

      // Validate username availability with API
      isBusy.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.post('/pass/accounts/validate', data: {'name': username});
        onNext();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return Column(
      key: const ValueKey<int>(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.person, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'createAccountProfile'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4, bottom: 16),
        TextField(
          controller: usernameController,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'username'.tr(),
            helperText: 'usernameCannotChangeHint'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ).padding(horizontal: 7),
        const Gap(12),
        TextField(
          controller: nicknameController,
          autocorrect: false,
          autofillHints: const [AutofillHints.nickname],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'nickname'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ).padding(horizontal: 7),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => onBack(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Symbols.chevron_left), Text('back').tr()],
              ),
            ),
            TextButton(
              onPressed: isBusy.value ? null : () => performNext(),
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

// Stage 4: Terms Review
class _CreateAccountTermsScreen extends HookConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(bool) onBusy;

  const _CreateAccountTermsScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onBusy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final termsAccepted = useState(false);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    void performNext() {
      if (!termsAccepted.value) {
        showErrorAlert('Please accept the terms of service to continue');
        return;
      }
      onNext();
    }

    final unfocusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha((255 * 0.75).round());

    return Column(
      key: const ValueKey<int>(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.description, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'createAccountToS'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4, bottom: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'createAccountNotice',
                style: TextStyle(
                  color: unfocusColor,
                  fontWeight: FontWeight.bold,
                ),
              ).tr(),
              _BulletPoint(
                children: [
                  Text(
                    'termAcceptNextWithAgree'.tr(),
                    style: TextStyle(color: unfocusColor),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        launchUrlString('https://solsynth.dev/terms');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('termAcceptLink').tr(),
                          const Gap(4),
                          const Icon(Symbols.launch, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _BulletPoint(children: [Text('createAccountConfirmEmail'.tr())]),
              _BulletPoint(children: [Text('createAccountNoAltAccounts'.tr())]),
            ],
          ).width(double.infinity).padding(horizontal: 16, vertical: 12),
        ),
        const Gap(12),
        CheckboxListTile(
          value: termsAccepted.value,
          onChanged: (value) {
            termsAccepted.value = value ?? false;
          },
          title: Text('createAccountAgreeTerms').tr(),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => onBack(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Symbols.chevron_left), Text('back').tr()],
              ),
            ),
            TextButton(
              onPressed: isBusy.value ? null : () => performNext(),
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

// Stage 5: Captcha and Complete
class _CreateAccountCompleteScreen extends HookConsumerWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final TextEditingController nicknameController;
  final TextEditingController affiliationSpellController;
  final String? onboardingToken;
  final VoidCallback onBack;
  final Function(bool) onBusy;

  const _CreateAccountCompleteScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.usernameController,
    required this.nicknameController,
    required this.affiliationSpellController,
    required this.onboardingToken,
    required this.onBack,
    required this.onBusy,
  });

  Map<String, dynamic> decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw FormatException('Invalid JWT');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }

  void showPostCreateModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => _PostCreateModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);

    useEffect(() {
      onBusy.call(isBusy.value);
      return null;
    }, [isBusy]);

    Future<void> performAction() async {
      String endpoint = '/pass/accounts';
      Map<String, dynamic> data = {};

      if (onboardingToken != null) {
        // OIDC onboarding
        endpoint = '/pass/account/onboard';
        data['onboarding_token'] = onboardingToken;
        data['name'] = usernameController.text;
        data['nick'] = nicknameController.text;
      } else {
        // Manual account creation
        final captchaTk = await CaptchaScreen.show(context);
        if (captchaTk == null) return;
        if (!context.mounted) return;
        data['captcha_token'] = captchaTk;
        data['name'] = usernameController.text;
        data['nick'] = nicknameController.text;
        if (affiliationSpellController.text.isNotEmpty) {
          data['affiliation_spell'] = affiliationSpellController.text;
        }
        data['email'] = emailController.text;
        data['password'] = passwordController.text;
        data['language'] =
            kServerSupportedLanguages[EasyLocalization.of(
              context,
            )!.currentLocale.toString()] ??
            'en-us';
      }

      if (!context.mounted) return;

      try {
        isBusy.value = true;
        showLoadingModal(context);
        final client = ref.watch(apiClientProvider);
        final resp = await client.post(endpoint, data: data);
        if (endpoint == '/pass/account/onboard') {
          // Onboard response has tokens, set them
          final token = resp.data['token'];
          setToken(ref.watch(sharedPreferencesProvider), token);
          ref.invalidate(tokenProvider);
          final userNotifier = ref.read(userInfoProvider.notifier);
          await userNotifier.fetchUser();
          final apiClient = ref.read(apiClientProvider);
          subscribePushNotification(apiClient);
          final wsNotifier = ref.read(websocketStateProvider.notifier);
          wsNotifier.connect();
          if (context.mounted) Navigator.pop(context, true);
        } else {
          if (!context.mounted) return;
          hideLoadingModal(context);
          showPostCreateModal(context);
        }
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return Column(
      key: const ValueKey<int>(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(Symbols.check_circle, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'createAccountAlmostThere'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4, bottom: 16),
        Text(
          'createAccountAlmostThereHint'.tr(),
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((255 * 0.75).round()),
          ),
        ).padding(horizontal: 4),
        const Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isBusy.value ? null : () => onBack(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Symbols.chevron_left), Text('back').tr()],
              ),
            ),
            TextButton(
              onPressed: isBusy.value ? null : () => performAction(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('createAccount').tr(),
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

class CreateAccountContent extends HookConsumerWidget {
  const CreateAccountContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final period = useState(0);
    final onboardingToken = useState<String?>(null);
    final waitingForOidc = useState(false);

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final nicknameController = useTextEditingController();
    final affiliationSpellController = useTextEditingController();

    Map<String, dynamic> decodeJwt(String token) {
      final parts = token.split('.');
      if (parts.length != 3) throw FormatException('Invalid JWT');
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded);
    }

    useEffect(() {
      final subscription = eventBus.on<OidcAuthCallbackEvent>().listen((
        event,
      ) async {
        if (!waitingForOidc.value || !context.mounted) return;
        waitingForOidc.value = false;
        final client = ref.watch(apiClientProvider);
        try {
          // Exchange code for tokens
          final resp = await client.post(
            '/pass/auth/token',
            data: {
              'grant_type': 'authorization_code',
              'code': event.challengeId,
            },
          );
          final data = resp.data;
          if (data.containsKey('onboarding_token')) {
            // New user onboarding
            final token = data['onboarding_token'] as String;
            final decoded = decodeJwt(token);
            final name = decoded['name'] as String?;
            final email = decoded['email'] as String?;
            final provider = decoded['provider'] as String?;
            // Pre-fill form and jump to stage 2 (username/nickname)
            usernameController.text = '';
            nicknameController.text = name ?? '';
            emailController.text = email ?? '';
            passwordController.clear();
            onboardingToken.value = token;
            period.value = 2; // Jump to profile screen
            showSnackBar('Pre-filled from ${provider ?? 'provider'}');
          } else {
            // Existing user, switch to login
            showSnackBar('Account already exists. Redirecting to login.');
            if (context.mounted) context.goNamed('login');
          }
        } catch (err) {
          showErrorAlert(err);
        }
      });
      return subscription.cancel;
    }, [waitingForOidc.value, context.mounted]);

    Future<void> withOidc(String provider) async {
      waitingForOidc.value = true;
      final serverUrl = ref.watch(serverUrlProvider);
      final deviceId = await getUdid();
      final url =
          Uri.parse('$serverUrl/pass/auth/login/${provider.toLowerCase()}')
              .replace(
                queryParameters: {
                  'returnUrl': 'solian://auth/callback',
                  'deviceId': deviceId,
                  'flow': 'login',
                },
              )
              .toString();
      final isLaunched = await launchUrlString(
        url,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      if (!isLaunched) {
        waitingForOidc.value = false;
        showErrorAlert('failedToLaunchBrowser'.tr());
      }
    }

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
          else
            LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.zero,
              trackGap: 0,
              stopIndicatorRadius: 0,
              value: period.value / 5,
            ),
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
                child: switch (period.value % 5) {
                  1 => _CreateAccountPasswordScreen(
                    key: const ValueKey(1),
                    passwordController: passwordController,
                    onNext: () => period.value++,
                    onBack: () => period.value--,
                    onBusy: (value) => isBusy.value = value,
                  ),
                  2 => _CreateAccountProfileScreen(
                    key: const ValueKey(2),
                    usernameController: usernameController,
                    nicknameController: nicknameController,
                    isOidcFlow: onboardingToken.value != null,
                    onNext: () => period.value++,
                    onBack: () => period.value--,
                    onBusy: (value) => isBusy.value = value,
                  ),
                  3 => _CreateAccountTermsScreen(
                    key: const ValueKey(3),
                    onNext: () => period.value++,
                    onBack: () => period.value--,
                    onBusy: (value) => isBusy.value = value,
                  ),
                  4 => _CreateAccountCompleteScreen(
                    key: const ValueKey(4),
                    emailController: emailController,
                    passwordController: passwordController,
                    usernameController: usernameController,
                    nicknameController: nicknameController,
                    affiliationSpellController: affiliationSpellController,
                    onboardingToken: onboardingToken.value,
                    onBack: () => period.value--,
                    onBusy: (value) => isBusy.value = value,
                  ),
                  _ => _CreateAccountEmailScreen(
                    key: const ValueKey(0),
                    emailController: emailController,
                    affiliationSpellController: affiliationSpellController,
                    onNext: () => period.value++,
                    onBusy: (value) => isBusy.value = value,
                    onOidc: withOidc,
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

class _PostCreateModal extends HookConsumerWidget {
  const _PostCreateModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉').fontSize(32),
            Text(
              'postCreateAccountTitle'.tr(),
              textAlign: TextAlign.center,
            ).fontSize(17),
            const Gap(18),
            Text('postCreateAccountNext').tr().fontSize(19).bold(),
            const Gap(4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text('\u2022'),
                Expanded(child: Text('postCreateAccountNext1').tr()),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text('\u2022'),
                Expanded(child: Text('postCreateAccountNext2').tr()),
              ],
            ),
            const Gap(6),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.router.replace(const LoginRoute());
              },
              child: Text('login'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
