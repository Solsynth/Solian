import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/widgets/account/account_image.dart';

class AppRailNavigation extends StatefulWidget {
  const AppRailNavigation({super.key});

  @override
  State<AppRailNavigation> createState() => _AppRailNavigationState();
}

class _AppRailNavigationState extends State<AppRailNavigation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NavigationProvider>()
          .autoDetectIndex(GoRouter.maybeOf(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();
    final nav = context.watch<NavigationProvider>();

    return ListenableBuilder(
      listenable: nav,
      builder: (context, _) {
        final destinations = nav.destinations.toList();

        return SizedBox(
          width: 80,
          child: NavigationRail(
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerLow
                .withOpacity(0.5),
            selectedIndex: nav.currentIndex != null &&
                    nav.currentIndex! < nav.destinations.length
                ? nav.currentIndex
                : null,
            destinations: [
              ...destinations.map((ele) {
                return NavigationRailDestination(
                  icon: ele.icon,
                  label: Text(ele.label).tr(),
                );
              }),
            ],
            leading: const Gap(4),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    child: AccountImage(
                      content: ua.user?.avatar,
                      fallbackWidget:
                          ua.isAuthorized ? null : const Icon(Symbols.login),
                    ),
                    onTap: () {
                      GoRouter.of(context).goNamed('account');
                    },
                  ),
                ),
              ),
            ),
            onDestinationSelected: (idx) {
              nav.setIndex(idx);
              GoRouter.of(context).goNamed(destinations[idx].screen);
            },
          ),
        );
      },
    );
  }
}
