import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/settings/tabs_screen.dart';
import 'package:island/core/services/responsive.dart';

class ConditionalBottomNav extends HookConsumerWidget {
  final Widget child;
  const ConditionalBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    // Force rebuild when route changes
    useEffect(() {
      // This effect will run whenever currentLocation changes
      return null;
    }, [currentLocation]);

    final routes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );
    final shouldShowBottomNav = routes.contains(currentLocation);

    return shouldShowBottomNav ? child : const SizedBox.shrink();
  }
}
