import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:island/auth/auth_form_widgets.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
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
        'assets/images/oidc/spotify.webp',
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
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(
              Symbols.circle,
              size: 8,
              fill: 1,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
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
          '/padlock/accounts/validate',
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

    final methodIconColor = Theme.of(context).colorScheme.onSecondaryContainer;

    return AuthFormColumn(
      columnKey: const ValueKey<int>(0),
      children: [
        AuthFormHeader(
          icon: Symbols.mail,
          title: 'createAccount'.tr(),
        ),
        TextField(
          controller: emailController,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: 'email'.tr(),
            prefixIcon: const Icon(Symbols.mail),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ),
        TextField(
          controller: affiliationSpellController,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'affiliationSpell'.tr(),
            helperText: 'affiliationSpellHint'.tr(),
            prefixIcon: const Icon(Symbols.auto_awesome),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ),
        if (!kIsWeb)
          AuthAltMethodsRow(
            label: 'orCreateWith'.tr(),
            children: [
              AuthMethodIconButton(
                onPressed: () => onOidc('github'),
                icon: getProviderIcon(
                  'github',
                  size: 18,
                  color: methodIconColor,
                ),
                tooltip: 'GitHub',
              ),
              AuthMethodIconButton(
                onPressed: () => onOidc('google'),
                icon: getProviderIcon(
                  'google',
                  size: 18,
                  color: methodIconColor,
                ),
                tooltip: 'Google',
              ),
              AuthMethodIconButton(
                onPressed: () => onOidc('apple'),
                icon: getProviderIcon(
                  'apple',
                  size: 18,
                  color: methodIconColor,
                ),
                tooltip: 'Apple Account',
              ),
            ],
          ),
        AuthFormActions(
          isBusy: isBusy.value,
          onNext: performNext,
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

    return AuthFormColumn(
      columnKey: const ValueKey<int>(1),
      children: [
        AuthFormHeader(
          icon: Symbols.password,
          title: 'password'.tr(),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: 'password'.tr(),
            prefixIcon: const Icon(Symbols.password),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ),
        AuthFormActions(
          showBack: true,
          isBusy: isBusy.value,
          onBack: onBack,
          onNext: performNext,
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
        await client.post(
          '/padlock/accounts/validate',
          data: {'name': username},
        );
        onNext();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return AuthFormColumn(
      columnKey: const ValueKey<int>(2),
      children: [
        AuthFormHeader(
          icon: Symbols.person,
          title: 'createAccountProfile'.tr(),
        ),
        TextField(
          controller: usernameController,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          autofillHints: const [
            AutofillHints.username,
            AutofillHints.newUsername,
          ],
          decoration: InputDecoration(
            labelText: 'username'.tr(),
            helperText: 'usernameCannotChangeHint'.tr(),
            prefixIcon: const Icon(Symbols.alternate_email),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ),
        TextField(
          controller: nicknameController,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.nickname, AutofillHints.name],
          decoration: InputDecoration(
            labelText: 'nickname'.tr(),
            prefixIcon: const Icon(Symbols.badge),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performNext(),
        ),
        AuthFormActions(
          showBack: true,
          isBusy: isBusy.value,
          onBack: onBack,
          onNext: performNext,
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

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AuthFormColumn(
      columnKey: const ValueKey<int>(3),
      children: [
        AuthFormHeader(
          icon: Symbols.description,
          title: 'createAccountToS'.tr(),
        ),
        AuthSectionCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          children: [
            Text(
              'createAccountNotice'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(kAuthGapSm),
            _BulletPoint(
              children: [
                Text('termAcceptNextWithAgree'.tr()),
                TextButton.icon(
                  onPressed: () {
                    launchUrlString('https://solsynth.dev/terms');
                  },
                  icon: const Icon(Symbols.launch, size: 16),
                  label: Text('termAcceptLink'.tr()),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            _BulletPoint(children: [Text('createAccountConfirmEmail'.tr())]),
            _BulletPoint(children: [Text('createAccountNoAltAccounts'.tr())]),
          ],
        ),
        AuthSectionCard(
          children: [
            CheckboxListTile(
              value: termsAccepted.value,
              onChanged: (value) {
                termsAccepted.value = value ?? false;
              },
              title: Text('createAccountAgreeTerms'.tr()),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
        AuthFormActions(
          showBack: true,
          isBusy: isBusy.value || !termsAccepted.value,
          onBack: onBack,
          onNext: performNext,
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
      String endpoint = '/padlock/accounts';
      Map<String, dynamic> data = {};

      if (onboardingToken != null) {
        // OIDC onboarding
        endpoint = '/padlock/account/onboard';
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
        if (endpoint == '/padlock/account/onboard') {
          // Onboard response has tokens, set them
          final token = resp.data['token'];
          setToken(ref.watch(sharedPreferencesProvider), token);
          ref.invalidate(tokenProvider);
          final userNotifier = ref.read(userInfoProvider.notifier);
          await userNotifier.fetchUser();
          if (!context.mounted) return;
          final apiClient = ref.read(apiClientProvider);
          await subscribePushNotification(apiClient, context: context);
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

    return AuthFormColumn(
      columnKey: const ValueKey<int>(4),
      children: [
        AuthFormHeader(
          icon: Symbols.check_circle,
          title: 'createAccountAlmostThere'.tr(),
          subtitle: 'createAccountAlmostThereHint'.tr(),
        ),
        AuthFormActions(
          showBack: true,
          isBusy: isBusy.value,
          onBack: onBack,
          onNext: performAction,
          nextLabel: 'createAccount'.tr(),
          nextIcon: Symbols.person_add,
          nextIconAlignment: IconAlignment.start,
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
            '/padlock/auth/token',
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
            if (context.mounted) context.router.push(LoginRoute());
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
          Uri.parse('$serverUrl/padlock/auth/login/${provider.toLowerCase()}')
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

    return Column(
      children: [
        if (isBusy.value)
          const LinearProgressIndicator(minHeight: 4)
        else
          LinearProgressIndicator(
            minHeight: 4,
            value: period.value / 5,
          ),
        Expanded(
          child: AuthFormShell(
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
                      fillColor: Colors.transparent,
                      child: child,
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
            ),
          ),
        ),
      ],
    );
  }
}

class _PostCreateModal extends HookConsumerWidget {
  const _PostCreateModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Symbols.celebration,
                  size: 48,
                  color: scheme.primary,
                ),
                const Gap(16),
                Text(
                  'postCreateAccountTitle'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(20),
                Text(
                  'postCreateAccountNext'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                _BulletPoint(
                  children: [Text('postCreateAccountNext1'.tr())],
                ),
                _BulletPoint(
                  children: [Text('postCreateAccountNext2'.tr())],
                ),
                const Gap(24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.router.replace(LoginRoute());
                  },
                  icon: const Icon(Symbols.login),
                  label: Text('login'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
