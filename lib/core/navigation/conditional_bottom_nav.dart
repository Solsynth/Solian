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

class ConditionalBottomNav extends StatelessWidget {
  final Widget child;
  const ConditionalBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final routes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );

    final currentLocation = _normalizeRoutePath(
      context.router.root.currentPath,
    );
    final shouldShowBottomNav =
        currentLocation != null &&
        routes.any((route) => _normalizeRoutePath(route) == currentLocation);

    return shouldShowBottomNav ? child : const SizedBox.shrink();
  }
}
