import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/landing_splash_service.dart';
import 'package:island/shared/widgets/app_startup_splash.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1x1 transparent PNG
final _kTestPngBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _FakeAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Solar Network',
      packageName: 'dev.solsynth.solian',
      version: '3.15.0',
      buildNumber: '306',
      buildSignature: '',
    );
    await EasyLocalization.ensureInitialized();
  });

  test('resolveLocalLandingAsset prioritizes active limited-time over general', () async {
    final tempDir = await Directory.systemTemp.createTemp('landing_resolve_');
    addTearDown(() => tempDir.delete(recursive: true));

    final generalFile = File('${tempDir.path}/general.png')
      ..writeAsBytesSync(_kTestPngBytes);
    final eventFile = File('${tempDir.path}/event.png')
      ..writeAsBytesSync(_kTestPngBytes);
    final expiredFile = File('${tempDir.path}/expired.png')
      ..writeAsBytesSync(_kTestPngBytes);

    final now = DateTime.utc(2026, 6, 15, 12);
    SharedPreferences.setMockInitialValues({
      kLandingSplashManifestKey: jsonEncode([
        CloudLandingAsset(
          id: 'general',
          url: 'https://cdn.solian.app/general.png',
          orientation: 'landscape',
          localPath: generalFile.path,
        ).toJson(),
        CloudLandingAsset(
          id: 'event',
          url: 'https://cdn.solian.app/event.png',
          orientation: 'landscape',
          isLimitedTime: true,
          startsAt: DateTime.utc(2026, 6, 1),
          endsAt: DateTime.utc(2026, 6, 30),
          localPath: eventFile.path,
        ).toJson(),
        CloudLandingAsset(
          id: 'expired',
          url: 'https://cdn.solian.app/expired.png',
          orientation: 'landscape',
          isLimitedTime: true,
          startsAt: DateTime.utc(2026, 5, 1),
          endsAt: DateTime.utc(2026, 5, 31),
          localPath: expiredFile.path,
        ).toJson(),
      ]),
    });
    final prefs = await SharedPreferences.getInstance();

    final duringEvent = resolveLocalLandingAsset(
      prefs: prefs,
      isLandscape: true,
      now: now,
    );
    expect(duringEvent?.id, 'event');

    final afterEvent = resolveLocalLandingAsset(
      prefs: prefs,
      isLandscape: true,
      now: DateTime.utc(2026, 7, 2),
    );
    expect(afterEvent?.id, 'general');
  });

  test('syncLandingSplashAssets downloads assets and prunes stale files', () async {
    final tempDir = await Directory.systemTemp.createTemp('landing_sync_');
    addTearDown(() => tempDir.delete(recursive: true));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    var cdnDownloads = 0;
    var activeUrl = 'https://cdn.solian.app/landing/a.png';

    final apiDio = Dio()
      ..httpClientAdapter = _FakeAdapter((options) async {
        expect(options.path, '/stargate/landing');
        return ResponseBody.fromString(
          jsonEncode({
            'assets': [
              {
                'id': 'a',
                'url': activeUrl,
                'orientation': 'vertical',
                'background_color': '#112233',
                'is_limited_time': false,
              },
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

    final cdnDio = Dio()
      ..httpClientAdapter = _FakeAdapter((options) async {
        cdnDownloads++;
        return ResponseBody.fromBytes(_kTestPngBytes, 200);
      });

    await syncLandingSplashAssets(
      apiClient: apiDio,
      prefs: prefs,
      downloadClient: cdnDio,
      storageDirProvider: () async => tempDir,
    );

    expect(cdnDownloads, 1);
    final first = resolveLocalLandingAsset(prefs: prefs, isLandscape: false);
    expect(first, isNotNull);
    expect(first!.id, 'a');
    expect(first.backgroundColor, const Color(0xFF112233));
    expect(File(first.localPath!).existsSync(), isTrue);

    // Second sync with same URL should reuse existing file without re-downloading.
    await syncLandingSplashAssets(
      apiClient: apiDio,
      prefs: prefs,
      downloadClient: cdnDio,
      storageDirProvider: () async => tempDir,
    );
    expect(cdnDownloads, 1);

    // Updating URL downloads the new asset and prunes the old file.
    final oldPath = first.localPath!;
    activeUrl = 'https://cdn.solian.app/landing/b.png';
    await syncLandingSplashAssets(
      apiClient: apiDio,
      prefs: prefs,
      downloadClient: cdnDio,
      storageDirProvider: () async => tempDir,
    );
    expect(cdnDownloads, 2);
    expect(File(oldPath).existsSync(), isFalse);
  });

  testWidgets('StartupSplashScreen renders local cloud file when available', (
    tester,
  ) async {
    final tempDir = await Directory.systemTemp.createTemp('landing_widget_');
    addTearDown(() => tempDir.delete(recursive: true));
    final localFile = File('${tempDir.path}/cloud.png')
      ..writeAsBytesSync(_kTestPngBytes);

    SharedPreferences.setMockInitialValues({
      kLandingSplashManifestKey: jsonEncode([
        CloudLandingAsset(
          id: 'cloud-vertical',
          url: 'https://cdn.solian.app/cloud.png',
          orientation: 'vertical',
          backgroundColorValue: 0xFF123456,
          localPath: localFile.path,
        ).toJson(),
      ]),
    });
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              connectivityStatusProvider.overrideWith(
                (ref) => Stream.value([ConnectivityResult.wifi]),
              ),
            ],
            child: Builder(
              builder: (context) => mui.MaterialApp(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                theme: mui.ThemeData(
                  colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
                ),
                home: StartupSplashScreen(
                  runBootstrap: false,
                  showCompleted: true,
                  onCompleted: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    final image = tester.widget<Image>(
      find.byKey(const Key('startup-portrait-image')),
    );
    expect(image.image, isA<FileImage>());
    expect((image.image as FileImage).file.path, localFile.path);
  });
}
