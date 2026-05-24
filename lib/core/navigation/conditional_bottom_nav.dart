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
    return currentLocation == normalized;
  });
}

class ConditionalBottomNav extends StatefulWidget {
  final Widget child;
  final List<String>? routes;
  const ConditionalBottomNav({super.key, required this.child, this.routes});

  @override
  State<ConditionalBottomNav> createState() => _ConditionalBottomNavState();
}

class _ConditionalBottomNavState extends State<ConditionalBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Start fully visible
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateVisibility(bool shouldShow) {
    if (shouldShow == _isVisible) return;
    _isVisible = shouldShow;
    if (shouldShow) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultRoutes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );
    final effectiveRoutes = widget.routes ?? defaultRoutes;

    final shouldShowBottomNav = shouldShowBottomNavForCurrentPath(
      context,
      routes: effectiveRoutes,
    );

    // Schedule visibility update after the frame to avoid build during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateVisibility(shouldShowBottomNav);
    });

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1,
      child: SlideTransition(
        position: _slideAnimation,
        child: ClipRect(
          child: IgnorePointer(ignoring: !_isVisible, child: widget.child),
        ),
      ),
    );
  }
}
