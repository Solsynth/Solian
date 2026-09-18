import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _account = SnAccount.fromJson({
  'id': 'account-1',
  'name': 'alice',
  'nick': 'Alice',
  'language': 'en-US',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': 'profile-1',
    'experience': 0,
    'level': 0,
    'leveling_progress': 0.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'perk_subscription': null,
  'activated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

class _UserInfoAuthor extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => _account;
}

class _UserInfoGuest extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Records the outgoing request body and query instead of hitting the network.
class _RecordingAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastBody;
  Map<String, dynamic>? lastQuery;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    final data = options.data;
    if (data is String) {
      lastBody = jsonDecode(data) as Map<String, dynamic>;
    } else if (data is Map) {
      lastBody = Map<String, dynamic>.from(data);
    }
    lastQuery = options.queryParameters;
    return ResponseBody.fromString(
      jsonEncode(const []),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-total': ['0'],
      },
    );
  }
}

SnPublisher _publisher(String id, String name, String nick) {
  return SnPublisher.fromJson({
    'id': id,
    'type': 0,
    'name': name,
    'nick': nick,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

SnPost _post(String id, String content, SnPublisher publisher) {
  return SnPost.fromJson({
    'id': id,
    'type': 0,
    'content': content,
    'chained_posts': const [],
    'publisher': publisher.toJson(),
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final defaultPublisher = _publisher('default-publisher', 'default', 'D');
  final chainedPublisher = _publisher('chained-publisher', 'chained', 'C');

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required _RecordingAdapter adapter,
    required UserInfoNotifier user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              apiClientProvider.overrideWithValue(
                Dio()..httpClientAdapter = adapter,
              ),
              publishersManagedProvider.overrideWith(
                (ref) async => <SnPublisher>[
                  defaultPublisher,
                  chainedPublisher,
                ],
              ),
              publishingSettingsProvider.overrideWith(
                (ref) async => SnPublishingSettings(
                  id: 'settings',
                  accountId: 'account',
                  defaultReplyPublisherId: defaultPublisher.id,
                  createdAt: DateTime.utc(2026, 1, 1),
                ),
              ),
              userInfoProvider.overrideWith(() => user),
            ],
            child: Builder(
              builder: (context) => mui.MaterialApp(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                theme: mui.ThemeData(
                  colorScheme: mui.ColorScheme.fromSeed(
                    seedColor: Colors.indigo,
                  ),
                ),
                home: mui.Material(child: child),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Symbols.send));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('quick chains an own post and switches publisher to the head', (
    tester,
  ) async {
    final adapter = _RecordingAdapter();
    await pump(
      tester,
      PostQuickReply(parent: _post('head', 'head content', chainedPublisher)),
      adapter: adapter,
      user: _UserInfoAuthor(),
    );

    // Chain toggle present for own posts; no suggestion before typing.
    expect(find.byIcon(Symbols.link), findsOneWidget);
    expect(
      find.text('Replying to your own post? Chain it instead.'),
      findsNothing,
    );

    await tester.enterText(find.byType(mui.TextField), 'continuation');
    await tester.pump();

    // Suggestion nudges toward a chain (leading icon + toggle button).
    expect(
      find.text('Replying to your own post? Chain it instead.'),
      findsOneWidget,
    );
    expect(find.byIcon(Symbols.link), findsNWidgets(2));

    await tester.tap(find.text('Chain Post'));
    await tester.pump();

    // Placeholder flips to the chain prompt and the suggestion clears.
    final field = tester.widget<mui.TextField>(find.byType(mui.TextField));
    expect(field.decoration?.hintText, 'Add to your chain');
    expect(find.byIcon(Symbols.link), findsOneWidget);

    await send(tester);

    expect(adapter.lastBody?['chained_post_id'], 'head');
    expect(adapter.lastBody?.containsKey('replied_post_id'), isFalse);
    // A chain child inherits the head's publisher over the configured default.
    expect(adapter.lastQuery?['pub'], 'chained');
  });

  testWidgets('replies normally for posts it does not own', (tester) async {
    final adapter = _RecordingAdapter();
    await pump(
      tester,
      PostQuickReply(parent: _post('head', 'head content', chainedPublisher)),
      adapter: adapter,
      user: _UserInfoGuest(),
    );

    expect(find.byIcon(Symbols.link), findsNothing);

    await tester.enterText(find.byType(mui.TextField), 'a reply');
    await tester.pump();
    expect(
      find.text('Replying to your own post? Chain it instead.'),
      findsNothing,
    );

    await send(tester);

    expect(adapter.lastBody?['replied_post_id'], 'head');
    expect(adapter.lastBody?.containsKey('chained_post_id'), isFalse);
  });

  testWidgets('recognizes own posts via the linked account id', (tester) async {
    final adapter = _RecordingAdapter();
    final ownPublisher = SnPublisher.fromJson({
      ..._publisher('other-publisher', 'other', 'O').toJson(),
      'account_id': _account.id,
    });
    // Ownership comes from the account link, not the managed list.
    await pump(
      tester,
      PostQuickReply(parent: _post('head', 'head content', ownPublisher)),
      adapter: adapter,
      user: _UserInfoAuthor(),
    );

    expect(find.byIcon(Symbols.link), findsOneWidget);

    await tester.enterText(find.byType(mui.TextField), 'continue');
    await tester.pump();
    await tester.tap(find.text('Chain Post'));
    await tester.pump();
    await send(tester);

    expect(adapter.lastBody?['chained_post_id'], 'head');
  });
}
