import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/route.gr.dart';
import 'package:logging/logging.dart';

import 'package:quick_actions/quick_actions.dart';

class QuickActionsService {
  static final QuickActionsService _instance = QuickActionsService._internal();
  factory QuickActionsService() => _instance;
  QuickActionsService._internal();

  final QuickActions _quickActions = const QuickActions();
  bool _initialized = false;

  late WidgetRef _ref;

  Future<void> initialize(WidgetRef ref) async {
    _ref = ref;

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      Logger.root.warning(
        '[QuickActions] Quick Actions only supported on Android and iOS',
      );
      return;
    }

    if (_initialized) {
      Logger.root.info('[QuickActions] Already initialized');
      return;
    }

    try {
      Logger.root.info('[QuickActions] Initializing Quick Actions...');

      // TODO Add icons for these
      final shortcuts = <ShortcutItem>[
        const ShortcutItem(type: 'compose_post', localizedTitle: 'New Post'),
        const ShortcutItem(type: 'explore', localizedTitle: 'Explore'),
        const ShortcutItem(type: 'chats', localizedTitle: 'Chats'),
        const ShortcutItem(
          type: 'notifications',
          localizedTitle: 'Notifications',
        ),
      ];

      await _quickActions.initialize(_handleShortcut);
      await _quickActions.setShortcutItems(shortcuts);

      _initialized = true;
      Logger.root.info('[QuickActions] Quick Actions initialized successfully');
    } catch (e, stack) {
      Logger.root.severe('[QuickActions] Initialization failed', e, stack);
      rethrow;
    }
  }

  void _handleShortcut(String type) {
    Logger.root.info('[QuickActions] Shortcut tapped: $type');

    final context = _ref.read(routerProvider).navigatorKey.currentContext;
    if (context == null) {
      Logger.root.warning(
        '[QuickActions] Context not available, skipping action',
      );
      return;
    }

    switch (type) {
      case 'compose_post':
        eventBus.fire(const ShowComposeSheetEvent());
        break;

      case 'explore':
        context.router.navigate(const ExploreRoute());
        break;

      case 'chats':
        context.router.navigate(const ChatRoute());
        break;

      case 'notifications':
        eventBus.fire(ShowNotificationModalEvent());
        break;

      default:
        Logger.root.warning('[QuickActions] Unknown shortcut type: $type');
    }
  }

  void dispose() {
    _initialized = false;
  }
}
