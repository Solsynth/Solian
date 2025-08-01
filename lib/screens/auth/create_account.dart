import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/account/me/update.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'captcha.dart';

class CreateAccountScreen extends HookConsumerWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final emailController = useTextEditingController();
    final usernameController = useTextEditingController();
    final nicknameController = useTextEditingController();
    final passwordController = useTextEditingController();

    void showPostCreateModal() {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => _PostCreateModal(),
      );
    }

    void performAction() async {
      if (!formKey.currentState!.validate()) return;

      final captchaTk = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => CaptchaScreen()));
      if (captchaTk == null) return;

      if (!context.mounted) return;

      try {
        showLoadingModal(context);
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/id/accounts',
          data: {
            'name': usernameController.text,
            'nick': nicknameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'language':
                kServerSupportedLanguages[EasyLocalization.of(
                  context,
                )!.currentLocale.toString()] ??
                'en-us',
            'captcha_token': captchaTk,
          },
        );
        if (!context.mounted) return;
        hideLoadingModal(context);
        showPostCreateModal();
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
    }

    return AppScaffold(
      isNoBackground: false,
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
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
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
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
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
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
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
                                      const Icon(Symbols.launch, size: 14),
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
          ).padding(all: 24).center(),
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
