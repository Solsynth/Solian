import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/screens/account/factor_settings.dart';
import 'package:surface/types/auth.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/websocket.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  SnAuthTicket? _currentTicket;

  List<SnAuthFactor>? _factors;
  SnAuthFactor? _factorPicked;

  int _period = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenAuthLogin').tr(),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: SingleChildScrollView(
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
            child: switch (_period % 3) {
              1 => _LoginPickerScreen(
                  key: const ValueKey(1),
                  ticket: _currentTicket,
                  factors: _factors,
                  onTicket: (p0) => setState(() {
                    _currentTicket = p0;
                  }),
                  onPickFactor: (p0) => setState(() {
                    _factorPicked = p0;
                  }),
                  onNext: () => setState(() {
                    _period++;
                  }),
                ),
              2 => _LoginCheckScreen(
                  key: const ValueKey(2),
                  ticket: _currentTicket,
                  factor: _factorPicked,
                  onTicket: (p0) => setState(() {
                    _currentTicket = p0;
                  }),
                  onNext: () => setState(() {
                    _period = 1;
                  }),
                ),
              _ => _LoginLookupScreen(
                  key: const ValueKey(0),
                  ticket: _currentTicket,
                  onTicket: (p0) => setState(() {
                    _currentTicket = p0;
                  }),
                  onFactor: (p0) => setState(() {
                    _factors = p0;
                  }),
                  onNext: () => setState(() {
                    _period++;
                  }),
                ),
            },
          ).padding(all: 24),
        ).center(),
      ),
    );
  }
}

class _LoginCheckScreen extends StatefulWidget {
  final SnAuthTicket? ticket;
  final SnAuthFactor? factor;
  final Function(SnAuthTicket?) onTicket;
  final Function onNext;

  const _LoginCheckScreen({
    super.key,
    required this.ticket,
    required this.factor,
    required this.onTicket,
    required this.onNext,
  });

  @override
  State<_LoginCheckScreen> createState() => _LoginCheckScreenState();
}

class _LoginCheckScreenState extends State<_LoginCheckScreen> {
  bool _isBusy = false;

  final _passwordController = TextEditingController();

  void _performCheckTicket() async {
    final password = _passwordController.value.text;
    if (password.isEmpty) return;

    final sn = context.read<SnNetworkProvider>();

    setState(() => _isBusy = true);

    try {
      // Check ticket
      final resp = await sn.client.patch('/cgi/id/auth', data: {
        'ticket_id': widget.ticket!.id,
        'factor_id': widget.factor!.id,
        'code': password,
      });

      final result = SnAuthResult.fromJson(resp.data);
      widget.onTicket(result.ticket);

      if (!result.isFinished) {
        widget.onNext();
        return;
      }

      // Finish sign in if possible
      final tokenResp = await sn.client.post('/cgi/id/auth/token', data: {
        'grant_type': 'grant_token',
        'code': result.ticket!.grantToken,
      });
      final atk = tokenResp.data['access_token'];
      final rtk = tokenResp.data['refresh_token'];
      sn.setTokenPair(atk, rtk);
      if (!mounted) return;
      final user = context.read<UserProvider>();
      user.isAuthorized = true;
      await user.refreshUser();
      if (!mounted) return;
      final ws = context.read<WebSocketProvider>();
      await ws.connect();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      context.showErrorDialog(err);
      return;
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(
              Symbols.password,
              size: 28,
            ),
          ).padding(bottom: 8),
        ),
        Text(
          'loginEnterPassword'.tr(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ).padding(left: 4, bottom: 16),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          controller: _passwordController,
          obscureText: true,
          autofillHints: [
            widget.factor!.type == 0
                ? AutofillHints.password
                : AutofillHints.oneTimeCode
          ],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'fieldPassword'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: _isBusy ? null : (_) => _performCheckTicket(),
        ).padding(horizontal: 7),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isBusy ? null : () => _performCheckTicket(),
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

class _LoginPickerScreen extends StatefulWidget {
  final SnAuthTicket? ticket;
  final List<SnAuthFactor>? factors;
  final Function(SnAuthTicket?) onTicket;
  final Function(SnAuthFactor) onPickFactor;
  final Function onNext;

  const _LoginPickerScreen({
    super.key,
    required this.ticket,
    required this.factors,
    required this.onTicket,
    required this.onPickFactor,
    required this.onNext,
  });

  @override
  State<_LoginPickerScreen> createState() => _LoginPickerScreenState();
}

class _LoginPickerScreenState extends State<_LoginPickerScreen> {
  bool _isBusy = false;
  int? _factorPicked;

  Color get _unFocusColor =>
      Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.75).round());

  void _performGetFactorCode() async {
    if (_factorPicked == null) return;

    final sn = context.read<SnNetworkProvider>();

    setState(() => _isBusy = true);

    try {
      // Request one-time-password code
      await sn.client.post('/cgi/id/auth/factors/$_factorPicked');
      widget.onPickFactor(
        widget.factors!.where((x) => x.id == _factorPicked).first,
      );
      widget.onNext();
    } catch (err) {
      // ignore: use_build_context_synchronously
      if (context.mounted) context.showErrorDialog(err);
      return;
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<int>(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(
              Symbols.security,
              size: 28,
            ),
          ).padding(bottom: 8),
        ),
        Text(
          'loginPickFactor',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ).tr().padding(left: 4),
        const Gap(8),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: widget.factors
                    ?.map(
                      (x) => CheckboxListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        secondary: Icon(
                          kFactorTypes[x.type]?.$3 ?? Symbols.question_mark,
                        ),
                        title: Text(
                          kFactorTypes[x.type]?.$1 ?? 'unknown',
                        ).tr(),
                        enabled: !widget.ticket!.factorTrail.contains(x.id),
                        value: _factorPicked == x.id,
                        onChanged: (value) {
                          if (value == true) {
                            setState(() => _factorPicked = x.id);
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
          'loginMultiFactor'.plural(
            widget.ticket!.stepRemain,
          ),
          style: TextStyle(color: _unFocusColor, fontSize: 13),
        ).padding(horizontal: 16),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isBusy ? null : () => _performGetFactorCode(),
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

class _LoginLookupScreen extends StatefulWidget {
  final SnAuthTicket? ticket;
  final Function(SnAuthTicket?) onTicket;
  final Function(List<SnAuthFactor>?) onFactor;
  final Function onNext;

  const _LoginLookupScreen({
    super.key,
    required this.ticket,
    required this.onTicket,
    required this.onFactor,
    required this.onNext,
  });

  @override
  State<_LoginLookupScreen> createState() => _LoginLookupScreenState();
}

class _LoginLookupScreenState extends State<_LoginLookupScreen> {
  final _usernameController = TextEditingController();

  bool _isBusy = false;

  void _requestResetPassword() async {
    final username = _usernameController.value.text;
    if (username.isEmpty) {
      context.showErrorDialog('signinResetPasswordHint'.tr());
      return;
    }

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final lookupResp =
          await sn.client.get('/cgi/id/users/lookup?probe=$username');
      await sn.client.post('/cgi/id/users/me/password-reset', data: {
        'user_id': lookupResp.data['id'],
      });
      if (mounted) {
        context.showModalDialog('done'.tr(), 'signinResetPasswordSent'.tr());
      }
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _performNewTicket() async {
    final username = _usernameController.value.text;
    if (username.isEmpty) return;

    final sn = context.read<SnNetworkProvider>();

    setState(() => _isBusy = true);

    try {
      // Create ticket
      final resp = await sn.client.post('/cgi/id/auth', data: {
        'username': username,
      });
      final result = SnAuthResult.fromJson(resp.data);
      widget.onTicket(result.ticket);

      // Pull factors
      final factorResp =
          await sn.client.get('/cgi/id/auth/factors', queryParameters: {
        'ticketId': result.ticket!.id.toString(),
      });
      widget.onFactor(
        List<SnAuthFactor>.from(
          factorResp.data.map((ele) => SnAuthFactor.fromJson(ele)),
        ),
      );

      widget.onNext();
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
      return;
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CircleAvatar(
            radius: 26,
            child: const Icon(
              Symbols.login,
              size: 28,
            ),
          ).padding(bottom: 8),
        ),
        Text(
          'screenAuthLoginGreeting',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ).tr().padding(left: 4, bottom: 16),
        TextField(
          autocorrect: false,
          enableSuggestions: false,
          controller: _usernameController,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            isDense: true,
            border: const UnderlineInputBorder(),
            labelText: 'fieldUsername'.tr(),
            helperText: 'fieldUsernameLookupHint'.tr(),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: _isBusy ? null : (_) => _performNewTicket(),
        ).padding(horizontal: 7),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _isBusy ? null : () => _requestResetPassword(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text('forgotPassword'.tr()),
            ),
            TextButton(
              onPressed: _isBusy ? null : () => _performNewTicket(),
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
      ],
    );
  }
}
