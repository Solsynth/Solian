import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final activityListProvider = AsyncNotifierProvider(ActivityListNotifier.new);

class ActivityListNotifier
    extends AsyncNotifier<PaginationState<SnTimelineEvent>>
    with
        AsyncPaginationController<SnTimelineEvent>,
        AsyncPaginationFilter<String?, SnTimelineEvent> {
  static const int pageSize = 20;
  static const Duration retryAdjustmentDuration = Duration(seconds: 10);
  static const int maxRetryAttempts = 1;

  bool isAggressiveMode = true;
  String currentMode = 'personalized';

  StreamSubscription? _postCreatedSubscription;
  StreamSubscription? _postUpdateSubscription;
  StreamSubscription? _postDeleteSubscription;
  StreamSubscription? _postReactionSubscription;

  @override
  FutureOr<PaginationState<SnTimelineEvent>> build() async {
    final exploreSettings = ref.watch(appSettingsProvider).exploreSettings;
    isAggressiveMode = exploreSettings.aggressiveMode;
    currentMode = exploreSettings.mode;

    // Listen to real-time post created events
    _postCreatedSubscription = eventBus.on<PostCreatedEvent>().listen((event) {
      _handlePostCreated(event.post);
    });

    // Listen to real-time post update events
    _postUpdateSubscription = eventBus.on<PostUpdateEvent>().listen((event) {
      _handlePostUpdate(event.post);
    });

    // Listen to real-time post delete events
    _postDeleteSubscription = eventBus.on<PostDeleteEvent>().listen((event) {
      _handlePostDelete(event.postId);
    });

    // Listen to real-time reaction update events
    _postReactionSubscription = eventBus.on<PostReactionUpdateEvent>().listen((
      event,
    ) {
      _handleReactionUpdate(event);
    });

    ref.onCancel(() {
      _postCreatedSubscription?.cancel();
      _postDeleteSubscription?.cancel();
      _postReactionSubscription?.cancel();
      _postUpdateSubscription?.cancel();
    });

    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  void _handlePostCreated(SnPost post) {
    final currentState = state.value;
    if (currentState == null) return;

    // Check for duplicate
    if (currentState.items.any((item) => item.id == post.id)) return;

    final now = DateTime.now();
    final timelineEvent = SnTimelineEvent(
      id: post.id,
      type: 'posts.new',
      resourceIdentifier: post.id,
      data: post.toJson(),
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );

    final updatedItems = [timelineEvent, ...currentState.items];
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void _handlePostUpdate(SnPost post) {
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.items.indexWhere((item) {
      final itemData = item.data;
      if (item.type.startsWith('posts.new') && itemData['id'] == post.id) {
        return true;
      }
      return false;
    });

    if (index == -1) return;

    final existingEvent = currentState.items[index];
    final updatedEvent = existingEvent.copyWith(
      data: post.toJson(),
      updatedAt: DateTime.now(),
    );

    final updatedItems = [...currentState.items];
    updatedItems[index] = updatedEvent;

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void _handlePostDelete(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = currentState.items.where((item) {
      final itemData = item.data;
      if (item.type.startsWith('posts.new') && itemData['id'] == postId) {
        return true;
      }
      return false;
    }).toList();

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void _handleReactionUpdate(PostReactionUpdateEvent event) {
    final currentState = state.value;
    if (currentState == null) return;

    final postId = event.reaction.postId;
    final symbol = event.reaction.symbol;
    final delta = event.action == ReactionAction.added ? 1 : -1;

    final index = currentState.items.indexWhere((item) {
      if (item.resourceIdentifier == postId) {
        return true;
      }
      final itemData = item.data;
      if (itemData is SnPost && itemData.id == postId) {
        return true;
      }
      return false;
    });

    if (index == -1) return;

    final item = currentState.items[index];
    final itemData = item.data;
    if (itemData is! SnPost) return;

    final updatedReactionsCount = Map<String, int>.from(
      itemData.reactionsCount,
    );
    updatedReactionsCount[symbol] =
        (updatedReactionsCount[symbol] ?? 0) + delta;

    // Remove the reaction count if it becomes 0 or less
    if (updatedReactionsCount[symbol]! <= 0) {
      updatedReactionsCount.remove(symbol);
    }

    final updatedPost = itemData.copyWith(
      reactionsCount: updatedReactionsCount,
    );
    updatePostById(updatedPost);
  }

  @override
  String? currentFilter;

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async {
    final client = ref.read(solarNetworkClientProvider);

    final queryParameters = {
      if (cursor != null) 'cursor': cursor,
      'take': pageSize,
      'mode': currentMode,
      'aggressive': isAggressiveMode,
      if (currentFilter != null) 'filter': currentFilter,
    };

    final response = await client.dio.get(
      '/sphere/timeline',
      queryParameters: queryParameters,
    );

    final payload = Map<String, dynamic>.from(response.data as Map);
    final rawItems = (payload['items'] as List?) ?? const [];
    final nextCursor =
        (payload['next_cursor'] ?? payload['nextCursor']) as String?;
    currentMode = (payload['mode'] as String?) ?? currentMode;

    final List<SnTimelineEvent> items = rawItems
        .whereType<Map>()
        .map((e) => SnTimelineEvent.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    hasMore = nextCursor != null && nextCursor.isNotEmpty;
    cursor = hasMore ? nextCursor : null;

    // Check for duplicate items by id
    final existingItemIds = state.value?.items.map((e) => e.id).toSet() ?? {};
    final uniqueItems = items
        .where((item) => !existingItemIds.contains(item.id))
        .toList();

    // If no new items and we haven't reached max retry attempts, adjust cursor and retry
    if (uniqueItems.isEmpty && retryCount < maxRetryAttempts) {
      final prevCursor = DateTime.tryParse(nextCursor ?? '');
      if (prevCursor != null) {
        // Adjust cursor by subtracting retry adjustment duration
        final adjustedCursor = prevCursor.subtract(retryAdjustmentDuration);
        cursor = adjustedCursor.toUtc().toIso8601String();
        // Retry fetch with adjusted cursor
        return fetch(retryCount: retryCount + 1);
      }
    }

    return uniqueItems;
  }

  void updateOne(int index, SnTimelineEvent activity) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = [...currentState.items];
    updatedItems[index] = activity;

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void addPost(SnPost post) {
    final currentState = state.value;
    if (currentState == null) return;

    final now = DateTime.now();
    final timelineEvent = SnTimelineEvent(
      id: post.id,
      type: 'posts.created',
      resourceIdentifier: post.id,
      data: post,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );

    final updatedItems = [timelineEvent, ...currentState.items];
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void updatePostById(SnPost post) {
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.items.indexWhere((item) {
      if (item.resourceIdentifier == post.id) {
        return true;
      }
      final itemData = item.data;
      if (itemData is SnPost && itemData.id == post.id) {
        return true;
      }
      return false;
    });

    if (index == -1) return;

    final existingEvent = currentState.items[index];
    final updatedEvent = existingEvent.copyWith(
      data: post,
      updatedAt: DateTime.now(),
    );

    final updatedItems = [...currentState.items];
    updatedItems[index] = updatedEvent;

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void removePost(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = currentState.items.where((item) {
      if (item.resourceIdentifier == postId) {
        return false;
      }
      final itemData = item.data;
      if (itemData is SnPost && itemData.id == postId) {
        return false;
      }
      return true;
    }).toList();

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  Future<void> applyAggressiveMode(bool isAggressive) async {
    if (isAggressiveMode == isAggressive) return;

    state = AsyncData(
      PaginationState(
        items: [],
        isLoading: true,
        isReloading: true,
        totalCount: null,
        hasMore: true,
        cursor: null,
      ),
    );
    cursor = null;
    hasMore = true;
    isAggressiveMode = isAggressive;

    final newItems = await fetch();

    if (!ref.mounted) return;
    state = AsyncData(
      PaginationState(
        items: newItems,
        isLoading: false,
        isReloading: false,
        totalCount: totalCount,
        hasMore: hasMore,
        cursor: cursor,
      ),
    );
  }

  Future<void> applyMode(String mode) async {
    if (currentMode == mode) return;

    state = AsyncData(
      PaginationState(
        items: [],
        isLoading: true,
        isReloading: true,
        totalCount: null,
        hasMore: true,
        cursor: null,
      ),
    );
    cursor = null;
    hasMore = true;
    currentMode = mode;

    final newItems = await fetch();

    if (!ref.mounted) return;
    state = AsyncData(
      PaginationState(
        items: newItems,
        isLoading: false,
        isReloading: false,
        totalCount: totalCount,
        hasMore: hasMore,
        cursor: cursor,
      ),
    );
  }
}
