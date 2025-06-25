import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/tabs.dart';

class ConditionalBottomNav extends HookConsumerWidget {
  final Widget child;

  const ConditionalBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRouteName = ref.watch(currentRouteProvider);

    const mainTabRoutes = {
      ExploreRoute.name,
      ChatListRoute.name,
      RealmListRoute.name,
      AccountRoute.name,
    };

    debugPrint(currentRouteName);
    final shouldShowBottomNav = mainTabRoutes.contains(currentRouteName);

    return shouldShowBottomNav ? child : const SizedBox.shrink();
  }
}
