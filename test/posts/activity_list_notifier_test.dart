import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

Map<String, dynamic> _timelineEvent(String id, String type) => {
  'id': id,
  'type': type,
  'resource_identifier': id,
  'data': <String, dynamic>{'id': id},
  'created_at': '2026-01-01T00:00:00.000Z',
  'updated_at': '2026-01-01T00:00:00.000Z',
  'deleted_at': null,
};

/// Serves scripted `/sphere/timeline` pages keyed by the incoming cursor.
/// The `null` key is the first page (no cursor query parameter).
class _TimelineAdapter implements HttpClientAdapter {
  _TimelineAdapter(this.pages);

  final Map<String?, Map<String, dynamic>> pages;
  final List<String?> requestedCursors = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final cursor = options.queryParameters['cursor'] as String?;
    requestedCursors.add(cursor);
    final page = pages[cursor];
    if (page == null) {
      throw StateError('Unexpected cursor: $cursor');
    }
    return ResponseBody.fromString(
      jsonEncode(page),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

final _defaultRefreshProvider = AsyncNotifierProvider<
  _DefaultRefreshNotifier,
  PaginationState<String>
>(_DefaultRefreshNotifier.new);

class _DefaultRefreshNotifier
    extends AsyncNotifier<PaginationState<String>>
    with AsyncPaginationController<String> {
  var _fetchCount = 0;

  @override
  Future<List<String>> fetch() async {
    _fetchCount++;
    return [_fetchCount == 1 ? 'old' : 'new'];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer makeContainer(_TimelineAdapter adapter) {
    return ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(
          Dio()..httpClientAdapter = adapter,
        ),
      ],
    );
  }

  test('pages without posts are skipped when advancing the timeline cursor',
      () async {
    final adapter = _TimelineAdapter({
      null: {
        'mode': 'personalized',
        'items': [
          _timelineEvent('presence-1', 'presence.friend'),
          _timelineEvent('status-1', 'status.friend'),
        ],
        'next_cursor': 'c1',
      },
      'c1': {
        'mode': 'personalized',
        'items': [_timelineEvent('post-1', 'posts.new')],
        'next_cursor': 'c2',
      },
    });
    container = makeContainer(adapter);

    final state = await container.read(activityListProvider.future);

    // The noise-only page is requested but never surfaces in the timeline.
    expect(adapter.requestedCursors, [null, 'c1']);
    expect(state.items.map((e) => e.type), ['posts.new']);
    expect(state.items.map((e) => e.id), ['post-1']);
  });

  test('a timeline with no posts at all terminates instead of looping',
      () async {
    final adapter = _TimelineAdapter({
      null: {
        'mode': 'personalized',
        'items': [_timelineEvent('presence-1', 'presence.friend')],
        'next_cursor': 'n1',
      },
      'n1': {
        'mode': 'personalized',
        'items': [_timelineEvent('status-1', 'status.friend')],
        'next_cursor': null,
      },
    });
    container = makeContainer(adapter);

    final state = await container.read(activityListProvider.future);

    // Every page is requested exactly once; the trailing page is kept.
    expect(adapter.requestedCursors, [null, 'n1']);
    expect(state.items, hasLength(1));
    expect(state.items.single.type, 'status.friend');
  });

  test('the next cursor is only adopted from pages that contain posts',
      () async {
    final adapter = _TimelineAdapter({
      null: {
        'mode': 'personalized',
        'items': [_timelineEvent('noise-1', 'discovery')],
        'next_cursor': 'c1',
      },
      'c1': {
        'mode': 'personalized',
        'items': [_timelineEvent('post-1', 'posts.new')],
        'next_cursor': 'c2',
      },
    });
    container = makeContainer(adapter);
    await container.read(activityListProvider.future);

    final notifier = container.read(activityListProvider.notifier);
    // Settled state as produced by the pagination controller after a refresh.
    notifier.state = AsyncData(
      PaginationState(
        items: const [],
        isLoading: false,
        isReloading: false,
        totalCount: null,
        hasMore: true,
        cursor: null,
      ),
    );

    final items = await notifier.fetch();

    expect(items.map((e) => e.type), ['posts.new']);
    expect(notifier.cursor, 'c2');
    expect(notifier.hasMore, isTrue);
  });
  test('refresh fetches items already present in the old timeline', () async {
    final adapter = _TimelineAdapter({
      null: {
        'mode': 'personalized',
        'items': [_timelineEvent('post-1', 'posts.new')],
        'next_cursor': null,
      },
    });
    container = makeContainer(adapter);
    await container.read(activityListProvider.future);

    final notifier = container.read(activityListProvider.notifier);
    expect(notifier.clearOnRefresh, isTrue);
    await notifier.refresh();

    final state = await container.read(activityListProvider.future);
    expect(state.items.map((e) => e.id), ['post-1']);
    expect(adapter.requestedCursors, [null, null]);
  });

  test('refresh keeps existing items by default', () async {
    container = makeContainer(_TimelineAdapter({}));
    final notifier = container.read(_defaultRefreshProvider.notifier);

    await container.read(_defaultRefreshProvider.future);
    final refresh = notifier.refresh();

    expect(notifier.clearOnRefresh, isFalse);
    expect(notifier.state.value?.items, ['old']);
    expect(notifier.state.value?.isReloading, isTrue);

    await refresh;
    expect(notifier.state.value?.items, ['new']);
  });
}
