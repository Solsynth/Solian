import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'captcha.dart';

@RoutePage()
class CreateAccountScreen extends HookConsumerWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final email = useState('');
    final username = useState('');
    final nickname = useState('');
    final password = useState('');

    void performAction() async {
      if (!formKey.currentState!.validate()) return;

      if (email.value.isEmpty ||
          username.value.isEmpty ||
          nickname.value.isEmpty ||
          password.value.isEmpty) {
        return;
      }

      final captchaTk = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => CaptchaScreen()));
      if (captchaTk == null) return;

      if (!context.mounted) return;

      try {
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/users',
          data: {
            'name': username.value,
            'nick': nickname.value,
            'email': email.value,
            'password': password.value,
            'language': EasyLocalization.of(context)!.currentLocale.toString(),
            'captcha_token': captchaTk,
          },
        );

        if (!context.mounted) return;
        context.router.replace(CreateAccountRoute());
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('createAccount').tr(),
      ),
      body:
          StyledWidget(
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
                        child: Icon(MdiIcons.accountPlus, size: 28),
                      ).padding(bottom: 8),
                    ),
                    Text(
                      'createAccount',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ).tr().padding(left: 4, bottom: 16),
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: username.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'fieldCannotBeEmpty'.tr();
                              }
                              return null;
                            },
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (val) => username.value = val ?? '',
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(
                              isDense: true,
                              border: const UnderlineInputBorder(),
                              labelText: 'username'.tr(),
                            ),
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                          const Gap(12),
                          TextFormField(
                            initialValue: nickname.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'fieldCannotBeEmpty'.tr();
                              }
                              return null;
                            },
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (val) => nickname.value = val ?? '',
                            autofillHints: const [AutofillHints.nickname],
                            decoration: InputDecoration(
                              isDense: true,
                              border: const UnderlineInputBorder(),
                              labelText: 'nickname'.tr(),
                            ),
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                          const Gap(12),
                          TextFormField(
                            initialValue: email.value,
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
                            onSaved: (val) => email.value = val ?? '',
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              isDense: true,
                              border: const UnderlineInputBorder(),
                              labelText: 'email'.tr(),
                            ),
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ),
                          const Gap(12),
                          TextFormField(
                            initialValue: password.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'fieldCannotBeEmpty'.tr();
                              }
                              return null;
                            },
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            onSaved: (val) => password.value = val ?? '',
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              isDense: true,
                              border: const UnderlineInputBorder(),
                              labelText: 'password'.tr(),
                            ),
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
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
                                      Icon(MdiIcons.launch, size: 14),
                                    ],
                                  ),
                                  onTap: () {
                                    launchUrlString(
                                      'https://solsynth.dev/terms',
                                    );
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
                          if (formKey.currentState?.validate() ?? false) {
                            performAction();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("next").tr(),
                            Icon(MdiIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).padding(all: 24).center(),
    );
  }
}
