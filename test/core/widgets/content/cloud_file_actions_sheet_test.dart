import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_actions_sheet.dart';
import 'package:island/drive/drive_service.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  testWidgets('executes media save from the action sheet', (tester) async {
    final item = SnCloudFileReference(
      id: 'remote-image',
      name: 'image.jpg',
      mimeType: 'image/jpeg',
      storageUrl: 'https://example.com/image.jpg',
    );
    final downloader = _RecordingDownloader();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverUrlProvider.overrideWithValue('https://example.com'),
          driveFileDownloaderProvider.overrideWithValue(downloader),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CloudFileActionsSheet.show(
                  context: context,
                  item: item,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('saveToGallery'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(downloader.savedItem, same(item));
  });
}

class _RecordingDownloader extends Fake implements FileDownloadService {
  IDisplayableCloudFile? savedItem;

  @override
  Future<void> saveToGallery(
    IDisplayableCloudFile item, {
    bool useDownloadsFolder = false,
  }) async {
    savedItem = item;
  }
}
