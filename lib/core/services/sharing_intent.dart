import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/route.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:share_plus/share_plus.dart';

class SharingIntentService {
  static final SharingIntentService _instance =
      SharingIntentService._internal();
  factory SharingIntentService() => _instance;
  SharingIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentSub;

  /// Initialize the sharing intent service
  void initialize(BuildContext _) {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return;
    debugPrint("SharingIntentService: Initializing with context");
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
  void _handleSharedContent(
    List<SharedMediaFile> sharedFiles, {
    int retryCount = 0,
  }) {
    debugPrint(
      "SharingIntentService: Received ${sharedFiles.length} shared files",
    );
    for (final file in sharedFiles) {
      debugPrint(
        "SharingIntentService: File path: ${file.path}, type: ${file.type}",
      );
    }

    // Convert SharedMediaFile to XFile for files
    final List<XFile> files = sharedFiles
        .where(
          (file) =>
              file.type == SharedMediaType.file ||
              file.type == SharedMediaType.video ||
              file.type == SharedMediaType.image,
        )
        .map((file) => XFile(file.path, name: file.path.split('/').last))
        .toList();

    // Extract links from shared content
    final List<String> links = sharedFiles
        .where((file) => file.type == SharedMediaType.url)
        .map((file) => file.path)
        .toList();

    // Treat solian:// URLs as deep links, not share payload.
    String? solianDeepLink;
    for (final url in links) {
      final normalized = url.trim();
      if (normalized.toLowerCase().startsWith('solian://')) {
        solianDeepLink = normalized;
        break;
      }
    }
    if (solianDeepLink != null) {
      final uri = Uri.tryParse(solianDeepLink);
      if (uri != null) {
        debugPrint("SharingIntentService: Dispatching deep link $solianDeepLink");
        eventBus.fire(SolianDeepLinkEvent(uri));
        return;
      }
    }

    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) {
      if (retryCount >= 12) {
        debugPrint(
          "SharingIntentService: Navigator context unavailable, dropping shared content",
        );
        return;
      }
      debugPrint(
        "SharingIntentService: Navigator context not ready, retrying...",
      );
      Future.delayed(const Duration(milliseconds: 250), () {
        _handleSharedContent(sharedFiles, retryCount: retryCount + 1);
      });
      return;
    }

    // Show ShareSheet with the shared files
    if (files.isNotEmpty) {
      showShareSheet(context: ctx, content: ShareContent.files(files));
    } else if (links.isNotEmpty) {
      showShareSheet(context: ctx, content: ShareContent.link(links.first));
    } else {
      showShareSheet(
        context: ctx,
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
  }
}
