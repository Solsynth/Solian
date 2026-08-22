import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/call_window.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EmptyResponseAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('call window builds with localization delegates', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final dio = Dio()..httpClientAdapter = _EmptyResponseAdapter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(dio),
        ],
        child: const CallWindowApp(
          args: CallWindowArgs(roomId: 'room-1', roomName: 'Test room'),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
