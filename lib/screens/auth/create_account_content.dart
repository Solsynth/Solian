import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/screens/account/me/profile_update.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/udid.dart';
import 'package:island/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'captcha.dart';

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
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
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

class CreateAccountContent extends HookConsumerWidget {
  const CreateAccountContent({super.key});

  Map<String, dynamic> decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw FormatException('Invalid JWT');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final emailController = useTextEditingController();
    final usernameController = useTextEditingController();
    final nicknameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final waitingForOidc = useState(false);
    final onboardingToken = useState<String?>(null);

    void showPostCreateModal() {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => _PostCreateModal(),
      );
    }

    void performAction() async {
      if (!formKey.currentState!.validate()) return;

      String endpoint = '/pass/accounts';
      Map<String, dynamic> data = {};

      if (onboardingToken.value != null) {
        // OIDC onboarding
        endpoint = '/pass/account/onboard';
        data['onboarding_token'] = onboardingToken.value;
        data['name'] = usernameController.text;
        data['nick'] = nicknameController.text;
        // Password is required in form, but might be optional
      } else {
        // Manual account creation
        final captchaTk = await CaptchaScreen.show(context);
        if (captchaTk == null) return;
        if (!context.mounted) return;
        data['captcha_token'] = captchaTk;
        data['name'] = usernameController.text;
        data['nick'] = nicknameController.text;
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
          onboardingToken.value = null; // reset
          showPostCreateModal();
        }
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
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
            // Pre-fill form
            usernameController.text = '';
            nicknameController.text = name ?? '';
            emailController.text = email ?? '';
            passwordController.clear(); // User needs to set password
            onboardingToken.value = token;
            // Optionally show a message
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
        mode:
            kIsWeb
                ? LaunchMode.platformDefault
                : LaunchMode.externalApplication,
      );
      if (!isLaunched) {
        waitingForOidc.value = false;
        showErrorAlert('failedToLaunchBrowser'.tr());
      }
    }

    return StyledWidget(
      Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 26,
                  child: const Icon(Symbols.person_add, size: 28),
                ).padding(bottom: 8),
              ),
              Text(
                'createAccount',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ).tr().padding(left: 4, bottom: 16),
              if (!kIsWeb)
                Row(
                  spacing: 6,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("orCreateWith").tr().fontSize(11).opacity(0.85),
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
                      onPressed: () => withOidc('apple'),
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
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'fieldCannotBeEmpty'.tr();
                        }
                        return null;
                      },
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'username'.tr(),
                        helperText: 'usernameCannotChangeHint'.tr(),
                      ),
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const Gap(12),
                    TextFormField(
                      controller: nicknameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'fieldCannotBeEmpty'.tr();
                        }
                        return null;
                      },
                      autocorrect: false,
                      autofillHints: const [AutofillHints.nickname],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'nickname'.tr(),
                      ),
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const Gap(12),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'fieldCannotBeEmpty'.tr();
                        }
                        if (!EmailValidator.validate(value)) {
                          return 'fieldEmailAddressMustBeValid'.tr();
                        }
                        return null;
                      },
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'email'.tr(),
                      ),
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const Gap(12),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'fieldCannotBeEmpty'.tr();
                        }
                        return null;
                      },
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'password'.tr(),
                      ),
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ],
                ).padding(horizontal: 7),
              ),
              const Gap(16),
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((255 * 0.75).round()),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('termAcceptLink').tr(),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    performAction();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("next").tr(),
                      const Icon(Symbols.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).padding(all: 24).center();
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
                context.pushReplacementNamed('login');
              },
              child: Text('login'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
