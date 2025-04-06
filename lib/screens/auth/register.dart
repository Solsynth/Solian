import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/screens/captcha/captcha.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _performAction(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.value.text;
    final username = _usernameController.value.text;
    final nickname = _nicknameController.value.text;
    final password = _passwordController.value.text;
    if (email.isEmpty ||
        username.isEmpty ||
        nickname.isEmpty ||
        password.isEmpty) {
      return;
    }

    final captchaTk = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CaptchaScreen(),
      ),
    );
    if (captchaTk == null) return;

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/id/users', data: {
        'name': username,
        'nick': nickname,
        'email': email,
        'password': password,
        'language': EasyLocalization.of(context)!.currentLocale.toString(),
        'captcha_token': captchaTk,
      });

      if (!context.mounted) return;
      GoRouter.of(context).replaceNamed("authLogin");
    } catch (err) {
      context.showErrorDialog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenAuthRegister').tr(),
      ),
      body: StyledWidget(Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 26,
                  child: const Icon(
                    Symbols.person_add,
                    size: 28,
                  ),
                ).padding(bottom: 8),
              ),
              Text(
                'screenAuthRegister',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ).tr().padding(left: 4, bottom: 16),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.length < 4 ||
                            value.length > 32) {
                          return 'fieldUsernameLengthLimit'
                              .tr(args: [4.toString(), 32.toString()]);
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                          return 'fieldUsernameAlphanumOnly'.tr();
                        }
                        return null;
                      },
                      autocorrect: false,
                      enableSuggestions: false,
                      controller: _usernameController,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'fieldUsername'.tr(),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const Gap(12),
                    TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.length < 4 ||
                            value.length > 32) {
                          return 'fieldNicknameLengthLimit'
                              .tr(args: [4.toString(), 32.toString()]);
                        }
                        return null;
                      },
                      autocorrect: false,
                      enableSuggestions: false,
                      controller: _nicknameController,
                      autofillHints: const [AutofillHints.nickname],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'fieldNickname'.tr(),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const Gap(12),
                    TextFormField(
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
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'fieldEmail'.tr(),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const Gap(12),
                    TextFormField(
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
                      controller: _passwordController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: const UnderlineInputBorder(),
                        labelText: 'fieldPassword'.tr(),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
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
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha((255 * 0.75).round()),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _performAction(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('next').tr(),
                      const Icon(Symbols.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )).padding(all: 24).center(),
    );
  }
}
