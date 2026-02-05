import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:island/core/widgets/share/share_sheet.dart';
import 'package:share_plus/share_plus.dart';

class SharingIntentService {
  static final SharingIntentService _instance =
      SharingIntentService._internal();
  factory SharingIntentService() => _instance;
  SharingIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentSub;
  BuildContext? _context;

  /// Initialize the sharing intent service
  void initialize(BuildContext context) {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return;
    debugPrint("SharingIntentService: Initializing with context");
    _context = context;
    _setupSharingListeners();
  }

  /// Setup listeners for sharing intents
  void _setupSharingListeners() {
    debugPrint("SharingIntentService: Setting up sharing listeners");

    // Listen to media sharing coming from outside the app while the app is in memory
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        debugPrint(
          "SharingIntentService: Media stream received ${value.length} files",
        );
        if (value.isNotEmpty) {
          _handleSharedContent(value);
        }
      },
      onError: (err) {
        debugPrint("SharingIntentService: Stream error: $err");
      },
    );

    // Get the media sharing coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      debugPrint(
        "SharingIntentService: Initial media received ${value.length} files",
      );
      if (value.isNotEmpty) {
        _handleSharedContent(value);
        // Tell the library that we are done processing the intent
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  /// Handle shared media files
  void _handleSharedContent(List<SharedMediaFile> sharedFiles) {
    if (_context == null) {
      debugPrint(
        "SharingIntentService: Context is null, cannot handle shared content",
      );
      return;
    }

    debugPrint(
      "SharingIntentService: Received ${sharedFiles.length} shared files",
    );
    for (final file in sharedFiles) {
      debugPrint(
        "SharingIntentService: File path: ${file.path}, type: ${file.type}",
      );
    }

    // Convert SharedMediaFile to XFile for files
    final List<XFile> files =
        sharedFiles
            .where(
              (file) =>
                  file.type == SharedMediaType.file ||
                  file.type == SharedMediaType.video ||
                  file.type == SharedMediaType.image,
            )
            .map((file) => XFile(file.path, name: file.path.split('/').last))
            .toList();

    // Extract links from shared content
    final List<String> links =
        sharedFiles
            .where((file) => file.type == SharedMediaType.url)
            .map((file) => file.path)
            .toList();

    // Show ShareSheet with the shared files
    if (files.isNotEmpty) {
      showShareSheet(context: _context!, content: ShareContent.files(files));
    } else if (links.isNotEmpty) {
      showShareSheet(
        context: _context!,
        content: ShareContent.link(links.first),
      );
    } else {
      showShareSheet(
        context: _context!,
        content: ShareContent.text(
          sharedFiles
              .where((file) => file.type == SharedMediaType.text)
              .map((text) => text.message)
              .join('\n'),
        ),
      );
    }
  }

  /// Dispose of resources
  void dispose() {
    _intentSub?.cancel();
    _context = null;
  }
}
