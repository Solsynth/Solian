import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:island/route.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/talker.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsService {
  static final QuickActionsService _instance = QuickActionsService._internal();
  factory QuickActionsService() => _instance;
  QuickActionsService._internal();

  final QuickActions _quickActions = const QuickActions();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      talker.warning(
        '[QuickActions] Quick Actions only supported on Android and iOS',
      );
      return;
    }

    if (_initialized) {
      talker.info('[QuickActions] Already initialized');
      return;
    }

    try {
      talker.info('[QuickActions] Initializing Quick Actions...');

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
      talker.info('[QuickActions] Quick Actions initialized successfully');
    } catch (e, stack) {
      talker.error('[QuickActions] Initialization failed', e, stack);
      rethrow;
    }
  }

  void _handleShortcut(String type) {
    talker.info('[QuickActions] Shortcut tapped: $type');

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      talker.warning('[QuickActions] Context not available, skipping action');
      return;
    }

    switch (type) {
      case 'compose_post':
        eventBus.fire(const ShowComposeSheetEvent());
        break;

      case 'explore':
        context.go('/explore');
        break;

      case 'chats':
        context.go('/chat');
        break;

      case 'notifications':
        context.go('/notifications');
        break;

      default:
        talker.warning('[QuickActions] Unknown shortcut type: $type');
    }
  }

  void dispose() {
    _initialized = false;
  }
}
