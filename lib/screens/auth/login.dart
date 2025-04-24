import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/models/auth.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = useState(0);
    final currentTicket = useState<SnAuthChallenge?>(null);
    final factors = useState<List<SnAuthFactor>>([]);
    final factorPicked = useState<SnAuthFactor?>(null);
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('login').tr(),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
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
                    onPickFactor: (SnAuthFactor p0) => factorPicked.value = p0,
                    onNext: () => period.value++,
                  ),
                  2 => _LoginCheckScreen(
                    key: const ValueKey(2),
                    challenge: currentTicket.value,
                    factor: factorPicked.value,
                    onChallenge:
                        (SnAuthChallenge? p0) => currentTicket.value = p0,
                    onNext: () => period.value++,
                  ),
                  _ => _LoginLookupScreen(
                    key: const ValueKey(0),
                    ticket: currentTicket.value,
                    onChallenge:
                        (SnAuthChallenge? p0) => currentTicket.value = p0,
                    onFactor:
                        (List<SnAuthFactor>? p0) => factors.value = p0 ?? [],
                    onNext: () => period.value++,
                  ),
                },
              ).padding(all: 24),
            ).center(),
      ),
    );
  }
}

class _LoginCheckScreen extends HookConsumerWidget {
  final SnAuthChallenge? challenge;
  final SnAuthFactor? factor;
  final Function(SnAuthChallenge?) onChallenge;
  final Function onNext;

  const _LoginCheckScreen({
    super.key,
    required this.challenge,
    required this.factor,
    required this.onChallenge,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final passwordController = useTextEditingController();

    Future<void> performCheckTicket() async {
      final pwd = passwordController.value.text;
      if (pwd.isEmpty) return;
      isBusy.value = true;
      try {
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
        final tokenResp = await client.post(
          '/auth/token',
          data: {'grant_type': 'authorization_code', 'code': result.id},
        );
        final atk = tokenResp.data['access_token'];
        final rtk = tokenResp.data['refresh_token'];
        setTokenPair(ref.watch(sharedPreferencesProvider), atk, rtk);
        ref.invalidate(tokenPairProvider);
        if (!context.mounted) return;
        final userNotifier = ref.read(userInfoProvider.notifier);
        userNotifier.fetchUser();
        Navigator.pop(context, true);
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
            child: const Icon(LucideIcons.squareAsterisk, size: 28),
          ).padding(bottom: 8),
        ),
        Text(
          'loginEnterPassword'.tr(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ).padding(left: 4, bottom: 16),
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
            border: const UnderlineInputBorder(),
            labelText: 'password'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: isBusy.value ? null : (_) => performCheckTicket(),
        ).padding(horizontal: 7),
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
                  const Icon(LucideIcons.chevronRight),
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
  final Function onNext;

  const _LoginPickerScreen({
    super.key,
    required this.ticket,
    required this.factors,
    required this.onChallenge,
    required this.onPickFactor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final factorPicked = useState<int?>(null);

    final unfocusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha((255 * 0.75).round());

    void performGetFactorCode() async {
      if (factorPicked.value == null) return;

      isBusy.value = true;
      final client = ref.watch(apiClientProvider);

      try {
        // Request one-time-password code
        await client.post(
          '/auth/challenge/${ticket!.id}/factors/${factorPicked.value}',
        );
        onPickFactor(factors!.where((x) => x.id == factorPicked.value).first);
        onNext();
      } catch (err) {
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
            child: const Icon(LucideIcons.lock, size: 28),
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
                        secondary: const Icon(LucideIcons.shieldQuestion),
                        title: Text('unknown').tr(),
                        enabled: !ticket!.blacklistFactors.contains(x.id),
                        value: factorPicked.value == x.id,
                        onChanged: (value) {
                          if (value == true) {
                            factorPicked.value = x.id;
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
                  const Icon(LucideIcons.chevronRight),
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
  final Function onNext;

  const _LoginLookupScreen({
    super.key,
    required this.ticket,
    required this.onChallenge,
    required this.onFactor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final usernameController = useTextEditingController();

    Future<void> requestResetPassword() async {
      final uname = usernameController.value.text;
      if (uname.isEmpty) {
        showErrorAlert('loginResetPasswordHint'.tr());
        return;
      }
      isBusy.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        final lookupResp = await client.get('/users/lookup?probe=$uname');
        await client.post(
          '/users/me/password-reset',
          data: {'user_id': lookupResp.data['id']},
        );
        showInfoAlert('done'.tr(), 'signinResetPasswordSent'.tr());
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
          data: {'account': uname},
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(LucideIcons.logIn, size: 28),
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
        const Gap(12),
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
                  const Icon(LucideIcons.chevronRight),
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
                          const Icon(LucideIcons.externalLink, size: 14),
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
