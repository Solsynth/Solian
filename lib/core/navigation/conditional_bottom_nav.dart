import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:island/core/services/responsive.dart';

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

String? _normalizeRoutePath(String? route) {
  if (route == null) return null;
  if (route.isEmpty) return '/';

  Uri uri;
  try {
    uri = Uri.parse(route);
  } catch (_) {
    return route;
  }

  var path = uri.path;
  if (path.isEmpty) path = '/';
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path;
}

bool shouldShowBottomNavForCurrentPath(
  BuildContext context, {
  List<String>? routes,
}) {
  final effectiveRoutes = routes ?? kTabRoutes;
  final currentLocation = _normalizeRoutePath(context.router.root.currentPath);
  if (currentLocation == null) return false;

  return effectiveRoutes.any((route) {
    final normalized = _normalizeRoutePath(route);
    if (normalized == null) return false;
    if (normalized == '/') return currentLocation == '/';
    return currentLocation == normalized ||
        currentLocation.startsWith('$normalized/');
  });
}

class ConditionalBottomNav extends StatelessWidget {
  final Widget child;
  final List<String>? routes;
  const ConditionalBottomNav({super.key, required this.child, this.routes});

  @override
  Widget build(BuildContext context) {
    final defaultRoutes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );
    final effectiveRoutes = routes ?? defaultRoutes;

    final shouldShowBottomNav = shouldShowBottomNavForCurrentPath(
      context,
      routes: effectiveRoutes,
    );

    return shouldShowBottomNav ? child : const SizedBox.shrink();
  }
}
