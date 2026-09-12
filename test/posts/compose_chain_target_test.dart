import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/data/database.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/widgets/compose/compose_card.dart';
import 'package:island/posts/widgets/compose/compose_info_banner.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers every request with an empty list so nothing touches the network.
class _EmptyResponseAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    jsonEncode(const []),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
      'x-total': ['0'],
    },
  );
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

/// Drives [ComposeStateUtils.usePublisherInitialization] and exposes the
/// publisher it settled on.
class _PublisherInitHost extends HookConsumerWidget {
  final ComposeState state;
  final SnPublisher? preferredPublisher;

  const _PublisherInitHost({required this.state, this.preferredPublisher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ComposeStateUtils.usePublisherInitialization(
      ref,
      state,
      preferredPublisher: preferredPublisher,
    );
    return mui.Text(state.currentPublisher.value?.id ?? 'none');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final defaultPublisher = _publisher('default-publisher', 'default', 'D');
  final chainedPublisher = _publisher('chained-publisher', 'chained', 'C');
  late AppDatabase database;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    database = AppDatabase.web();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
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
              databaseProvider.overrideWithValue(database),
              apiClientProvider.overrideWithValue(
                Dio()..httpClientAdapter = _EmptyResponseAdapter(),
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
                  defaultPostingPublisherId: defaultPublisher.id,
                  createdAt: DateTime.utc(2026, 1, 1),
                ),
              ),
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

  testWidgets('compose banner announces the post being chained to', (
    tester,
  ) async {
    await pump(
      tester,
      ComposeInfoBanner(
        chainingTo: _post('head', 'head content', chainedPublisher),
      ),
    );

    expect(find.text('Chaining to'), findsOneWidget);
    expect(find.text('head content'), findsOneWidget);
  });

  testWidgets('chained post publisher wins over the configured default', (
    tester,
  ) async {
    await pump(
      tester,
      _PublisherInitHost(
        state: ComposeLogic.createState(),
        preferredPublisher: chainedPublisher,
      ),
    );

    expect(find.text('chained-publisher'), findsOneWidget);
  });

  testWidgets('falls back to the configured default without a chain', (
    tester,
  ) async {
    await pump(tester, _PublisherInitHost(state: ComposeLogic.createState()));

    expect(find.text('default-publisher'), findsOneWidget);
  });

  testWidgets('falls back to the default when the chain publisher is not managed', (
    tester,
  ) async {
    await pump(
      tester,
      _PublisherInitHost(
        state: ComposeLogic.createState(),
        preferredPublisher: _publisher('someone-else', 'other', 'O'),
      ),
    );

    expect(find.text('default-publisher'), findsOneWidget);
  });

  testWidgets('compose card wires the chain target into banner and publisher', (
    tester,
  ) async {
    final state = ComposeLogic.createState();
    await pump(
      tester,
      PostComposeCard(
        initialState: PostComposeInitialState(
          chainingTo: _post('head', 'head content', chainedPublisher),
        ),
        providedState: state,
      ),
    );

    expect(find.text('Chaining to'), findsOneWidget);
    expect(find.text('head content'), findsOneWidget);
    expect(state.currentPublisher.value?.id, 'chained-publisher');
  });
}
