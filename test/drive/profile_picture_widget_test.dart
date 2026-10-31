import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _serverUrl = 'https://api.example.com';

Future<void> _pumpAvatar(
  WidgetTester tester,
  IDisplayableCloudFile? file,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        serverUrlProvider.overrideWithValue(_serverUrl),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProfilePictureWidget(
              file: file,
              fallbackName: 'Littlesheep',
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ProfilePictureWidget image source', () {
    testWidgets('loads a remote avatar from its storage url', (tester) async {
      // Fediverse actors arrive as a file reference with an empty id: the image
      // lives on the remote instance, so it must not be fetched from the local
      // drive endpoint.
      await _pumpAvatar(
        tester,
        const SnCloudFileReference(
          id: '',
          storageUrl: 'https://files.mastodon.social/a.png',
        ),
      );

      final image = tester.widget<UniversalImage>(find.byType(UniversalImage));
      expect(image.uri, 'https://files.mastodon.social/a.png');
    });

    testWidgets('loads a local avatar from the drive endpoint', (tester) async {
      await _pumpAvatar(tester, const SnCloudFileReference(id: 'file-1'));

      final image = tester.widget<UniversalImage>(find.byType(UniversalImage));
      expect(image.uri, '$_serverUrl/drive/files/file-1');
    });

    testWidgets('loads a local avatar over a blank storage url', (
      tester,
    ) async {
      // A blank storage url is not an address. Falling through to the drive
      // endpoint is what keeps the avatar visible instead of failing with
      // "No host specified in URI".
      await _pumpAvatar(
        tester,
        const SnCloudFileReference(id: 'file-1', storageUrl: ''),
      );

      final image = tester.widget<UniversalImage>(find.byType(UniversalImage));
      expect(image.uri, '$_serverUrl/drive/files/file-1');
    });

    testWidgets('falls back when the reference has no image', (tester) async {
      await _pumpAvatar(tester, const SnCloudFileReference(id: ''));

      expect(find.byType(UniversalImage), findsNothing);
      expect(find.text('LI'), findsOneWidget);
    });
  });

  group('avatarFallbackText', () {
    test('uses up to two letters for a single Latin word', () {
      expect(avatarFallbackText('alice'), 'AL');
      expect(avatarFallbackText(' A '), 'A');
    });

    test('uses one CJK grapheme for CJK names', () {
      expect(avatarFallbackText('太阳'), '太');
      expect(avatarFallbackText('李四'), '李');
    });

    test('uses one whole emoji grapheme', () {
      expect(avatarFallbackText('😀'), '😀');
      expect(avatarFallbackText('👨‍👩‍👧'), '👨‍👩‍👧');
    });

    test('uses word initials for multi-word Latin names', () {
      expect(avatarFallbackText('Alice Zhang'), 'AZ');
      expect(avatarFallbackText('john doe'), 'JD');
    });

    test('does not create fallback text for missing nicknames', () {
      expect(avatarFallbackText(null), isNull);
      expect(avatarFallbackText('   '), isNull);
    });
  });
}
