import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    // Use the same route logic as TabsScreen for consistency
    const mainTabRoutes = ['/', '/chat', '/realms', '/account'];

    final shouldShowBottomNav = mainTabRoutes.contains(currentLocation);

    return shouldShowBottomNav ? child : const SizedBox.shrink();
  }
}
