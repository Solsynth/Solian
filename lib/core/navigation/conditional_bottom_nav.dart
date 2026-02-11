import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/settings/tabs_screen.dart';

// Tab routes that should show the bottom navigation
const kTabRoutes = [
  '/',
  '/explore',
  '/chat',
  '/realms',
  '/account',
  '/files',
  '/thought',
  '/creators',
  '/developers',
];

const kWideScreenRouteStart = 5;

class ConditionalBottomNav extends ConsumerWidget {
  final Widget child;
  const ConditionalBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );

    // Use currentRouteProvider to rebuild when route changes
    final currentLocation = ref.watch(currentRouteProvider);
    final shouldShowBottomNav = routes.contains(currentLocation);

    return shouldShowBottomNav ? child : const SizedBox.shrink();
  }
}
