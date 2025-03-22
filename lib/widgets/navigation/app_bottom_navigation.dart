import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/navigation.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({super.key});

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
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
    final nav = context.watch<NavigationProvider>();

    return ListenableBuilder(
      listenable: nav,
      builder: (context, _) {
        if (!nav.isIndexInRange(0, nav.pinnedDestinationCount)) {
          return const SizedBox.shrink();
        }

        final destinations = [
          ...nav.destinations.where((ele) => ele.isPinned),
        ];

        return NavigationBar(
          selectedIndex: nav.getIndexInRange(0, nav.pinnedDestinationCount),
          destinations: destinations.map((ele) {
            return NavigationDestination(
              icon: ele.icon,
              label: ele.label.tr(),
            );
          }).toList(),
          onDestinationSelected: (idx) {
            nav.setIndex(idx);
            GoRouter.of(context).goNamed(destinations[idx].screen);
          },
        );
      },
    );
  }
}
