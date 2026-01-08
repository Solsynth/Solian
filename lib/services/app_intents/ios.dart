import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:go_router/go_router.dart';
import 'package:island/models/auth.dart';
import 'package:island/pods/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:island/talker.dart';
import 'package:island/route.dart';

class AppIntentsService {
  static final AppIntentsService _instance = AppIntentsService._internal();
  factory AppIntentsService() => _instance;
  AppIntentsService._internal();

  FlutterAppIntentsClient? _client;
  bool _initialized = false;
  Dio? _dio;

  Future<void> initialize() async {
    if (!Platform.isIOS) {
      talker.warning('[AppIntents] App Intents only supported on iOS');
      return;
    }

    if (_initialized) {
      talker.info('[AppIntents] Already initialized');
      return;
    }

    try {
      talker.info('[AppIntents] Initializing App Intents client...');
      _client = FlutterAppIntentsClient.instance;

      // Initialize Dio for API calls
      final prefs = await SharedPreferences.getInstance();
      final serverUrl =
          prefs.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;
      final tokenString = prefs.getString(kTokenPairStoreKey);

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (tokenString != null) {
        try {
          final token = AppToken.fromJson(jsonDecode(tokenString));
          headers['Authorization'] = 'AtField ${token.token}';
        } catch (e) {
          talker.warning('[AppIntents] Failed to parse token: $e');
        }
      }

      _dio = Dio(
        BaseOptions(
          baseUrl: serverUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: headers,
        ),
      );

      await _registerIntents();
      _initialized = true;
      talker.info('[AppIntents] All intents registered successfully');
    } catch (e, stack) {
      talker.error('[AppIntents] Initialization failed', e, stack);
      rethrow;
    }
  }

  Future<void> _registerIntents() async {
    if (_client == null) {
      throw StateError('Client not initialized');
    }

    // Navigation Intents
    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('open_chat')
          .title('Open Chat')
          .description('Open a specific chat room')
          .parameter(
            const AppIntentParameter(
              name: 'channelId',
              title: 'Channel ID',
              type: AppIntentParameterType.string,
              isOptional: false,
            ),
          )
          .build(),
      _handleOpenChatIntent,
    );

    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('open_post')
          .title('Open Post')
          .description('Open a specific post')
          .parameter(
            const AppIntentParameter(
              name: 'postId',
              title: 'Post ID',
              type: AppIntentParameterType.string,
              isOptional: false,
            ),
          )
          .build(),
      _handleOpenPostIntent,
    );

    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('open_compose')
          .title('Open Compose')
          .description('Open compose post screen')
          .build(),
      _handleOpenComposeIntent,
    );

    // Action Intent
    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('compose_post')
          .title('Compose Post')
          .description('Create a new post')
          .build(),
      _handleComposePostIntent,
    );

    // Query Intents
    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('search_content')
          .title('Search Content')
          .description('Search for content')
          .parameter(
            const AppIntentParameter(
              name: 'query',
              title: 'Search Query',
              type: AppIntentParameterType.string,
              isOptional: false,
            ),
          )
          .build(),
      _handleSearchContentIntent,
    );

    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('view_notifications')
          .title('View Notifications')
          .description('View notifications')
          .build(),
      _handleViewNotificationsIntent,
    );

    await _client!.registerIntent(
      AppIntentBuilder()
          .identifier('check_notifications')
          .title('Check Notifications')
          .description('Check notification count')
          .build(),
      _handleCheckNotificationsIntent,
    );
  }

  void dispose() {
    _client = null;
    _initialized = false;
  }

  Future<AppIntentResult> _handleOpenChatIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final channelId = parameters['channelId'] as String?;
      if (channelId == null) {
        throw ArgumentError('channelId is required');
      }

      talker.info('[AppIntents] Opening chat: $channelId');

      if (rootNavigatorKey.currentContext == null) {
        return AppIntentResult.failed(error: 'App context not available');
      }

      rootNavigatorKey.currentContext!.push('/chat/$channelId');

      return AppIntentResult.successful(
        value: 'Opening chat $channelId',
        needsToContinueInApp: true,
      );
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to open chat', e, stack);
      return AppIntentResult.failed(error: 'Failed to open chat: $e');
    }
  }

  Future<AppIntentResult> _handleOpenPostIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final postId = parameters['postId'] as String?;
      if (postId == null) {
        throw ArgumentError('postId is required');
      }

      talker.info('[AppIntents] Opening post: $postId');

      if (rootNavigatorKey.currentContext == null) {
        return AppIntentResult.failed(error: 'App context not available');
      }

      rootNavigatorKey.currentContext!.push('/posts/$postId');

      return AppIntentResult.successful(
        value: 'Opening post $postId',
        needsToContinueInApp: true,
      );
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to open post', e, stack);
      return AppIntentResult.failed(error: 'Failed to open post: $e');
    }
  }

  Future<AppIntentResult> _handleOpenComposeIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      talker.info('[AppIntents] Opening compose screen');

      if (rootNavigatorKey.currentContext == null) {
        return AppIntentResult.failed(error: 'App context not available');
      }

      rootNavigatorKey.currentContext!.push('/posts/compose');

      return AppIntentResult.successful(
        value: 'Opening compose screen',
        needsToContinueInApp: true,
      );
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to open compose', e, stack);
      return AppIntentResult.failed(error: 'Failed to open compose: $e');
    }
  }

  Future<AppIntentResult> _handleComposePostIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      talker.info('[AppIntents] Composing new post');

      if (rootNavigatorKey.currentContext == null) {
        return AppIntentResult.failed(error: 'App context not available');
      }

      rootNavigatorKey.currentContext!.push('/posts/compose');

      return AppIntentResult.successful(
        value: 'Opening compose screen',
        needsToContinueInApp: true,
      );
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to compose post', e, stack);
      return AppIntentResult.failed(error: 'Failed to compose post: $e');
    }
  }

  Future<AppIntentResult> _handleSearchContentIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final query = parameters['query'] as String?;
      if (query == null) {
        throw ArgumentError('query is required');
      }

      talker.info('[AppIntents] Searching for: $query');

      if (rootNavigatorKey.currentContext == null) {
        return AppIntentResult.failed(error: 'App context not available');
      }

      rootNavigatorKey.currentContext!.push('/search?q=$query');

      return AppIntentResult.successful(
        value: 'Searching for "$query"',
        needsToContinueInApp: true,
      );
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to search', e, stack);
      return AppIntentResult.failed(error: 'Failed to search: $e');
    }
  }

  Future<AppIntentResult> _handleViewNotificationsIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      talker.info('[AppIntents] Opening notifications');

      if (rootNavigatorKey.currentContext == null) {
        return AppIntentResult.failed(error: 'App context not available');
      }

      // Note: You may need to adjust the route based on your actual notifications route
      // This is a common pattern - check your route.dart for exact path
      // If you don't have a dedicated notifications route, you might need to add one
      return AppIntentResult.failed(
        error: 'Notifications route not implemented',
      );
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to view notifications', e, stack);
      return AppIntentResult.failed(error: 'Failed to view notifications: $e');
    }
  }

  Future<AppIntentResult> _handleCheckNotificationsIntent(
    Map<String, dynamic> parameters,
  ) async {
    try {
      talker.info('[AppIntents] Checking notifications count');

      if (_dio == null) {
        return AppIntentResult.failed(error: 'API client not initialized');
      }

      try {
        final response = await _dio!.get('/ring/notifications/count');
        final count = (response.data as num).toInt();
        final countValue = count;

        String message;
        if (countValue == 0) {
          message = 'You have no new notifications';
        } else if (countValue == 1) {
          message = 'You have 1 new notification';
        } else {
          message = 'You have $countValue new notifications';
        }

        return AppIntentResult.successful(
          value: message,
          needsToContinueInApp: false,
        );
      } on DioException catch (e) {
        talker.error('[AppIntents] API error checking notifications', e);
        return AppIntentResult.failed(
          error:
              'Failed to fetch notifications: ${e.message ?? 'Network error'}',
        );
      }
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to check notifications', e, stack);
      return AppIntentResult.failed(error: 'Failed to check notifications: $e');
    }
  }

  // Donation Methods - to be called manually from your app code

  Future<void> donateOpenChat(String channelId) async {
    if (!_initialized) return;
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        'open_chat',
        {'channelId': channelId},
        relevanceScore: 0.8,
        context: {'feature': 'chat', 'userAction': true},
      );
      talker.info('[AppIntents] Donated open_chat intent');
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to donate open_chat', e, stack);
    }
  }

  Future<void> donateOpenPost(String postId) async {
    if (!_initialized) return;
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        'open_post',
        {'postId': postId},
        relevanceScore: 0.8,
        context: {'feature': 'posts', 'userAction': true},
      );
      talker.info('[AppIntents] Donated open_post intent');
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to donate open_post', e, stack);
    }
  }

  Future<void> donateCompose() async {
    if (!_initialized) return;
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        'open_compose',
        {},
        relevanceScore: 0.9,
        context: {'feature': 'compose', 'userAction': true},
      );
      talker.info('[AppIntents] Donated compose intent');
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to donate compose', e, stack);
    }
  }

  Future<void> donateSearch(String query) async {
    if (!_initialized) return;
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        'search_content',
        {'query': query},
        relevanceScore: 0.7,
        context: {'feature': 'search', 'userAction': true},
      );
      talker.info('[AppIntents] Donated search intent');
    } catch (e, stack) {
      talker.error('[AppIntents] Failed to donate search', e, stack);
    }
  }

  Future<void> donateCheckNotifications() async {
    if (!_initialized) return;
    try {
      await FlutterAppIntentsService.donateIntentWithMetadata(
        'check_notifications',
        {},
        relevanceScore: 0.6,
        context: {'feature': 'notifications', 'userAction': true},
      );
      talker.info('[AppIntents] Donated check_notifications intent');
    } catch (e, stack) {
      talker.error(
        '[AppIntents] Failed to donate check_notifications',
        e,
        stack,
      );
    }
  }
}
