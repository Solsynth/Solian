import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:surface/widgets/dialog.dart';

import '../providers/userinfo.dart';

class UnauthorizedHint extends StatelessWidget {
  const UnauthorizedHint({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Symbols.login, size: 36),
              const Gap(8),
              Text(
                'unauthorized',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ).tr(),
              const Gap(8),
              Text(
                'unauthorizedDescription',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).tr(),
            ],
          ),
        ),
        onTap: () {
          GoRouter.of(context).pushNamed('authLogin').then((value) {
            if (value == true && context.mounted) {
              final ua = context.read<UserProvider>();
              ua.refreshUser();
              context.showSnackbar('loginSuccess'.tr(args: [
                '@${ua.user?.name} (${ua.user?.nick})',
              ]));
            }
          });
        });
  }
}
