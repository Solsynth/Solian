import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/route.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:share_plus/share_plus.dart';

class SharingIntentService {
  static final SharingIntentService _instance =
      SharingIntentService._internal();
  factory SharingIntentService() => _instance;
  SharingIntentService._internal();

  StreamSubscription<List<SharedFile>>? _intentSub;

  List<SharedFile>? _pendingSharedFiles;
  WidgetRef? _widgetRef;

  bool get hasPendingShare => _pendingSharedFiles != null;

  void setWidgetRef(WidgetRef ref) {
    _widgetRef = ref;
  }

  void initialize() {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return;
    debugPrint("SharingIntentService: Initializing");
    _setupSharingListeners();
  }

  void checkAndShowShareSheet() {
    if (_pendingSharedFiles == null || _widgetRef == null) return;
    debugPrint("SharingIntentService: checkAndShowShareSheet called");
    final files = _pendingSharedFiles!;
    _pendingSharedFiles = null;
    _handleSharedContentWithRef(files);
  }

  void _setupSharingListeners() {
    debugPrint("SharingIntentService: Setting up sharing listeners");

    _intentSub = FlutterSharingIntent.instance.getMediaStream().listen(
      (List<SharedFile> value) {
        debugPrint(
          "SharingIntentService: Media stream received ${value.length} files",
        );
        if (value.isNotEmpty) {
          _pendingSharedFiles = value;
          if (_widgetRef != null) {
            checkAndShowShareSheet();
          }
        }
      },
      onError: (err) {
        debugPrint("SharingIntentService: Stream error: $err");
      },
    );

    FlutterSharingIntent.instance.getInitialSharing().then((
      List<SharedFile> value,
    ) {
      debugPrint(
        "SharingIntentService: Initial media received ${value.length} files",
      );
      if (value.isNotEmpty) {
        _pendingSharedFiles = value;
        FlutterSharingIntent.instance.reset();
        if (_widgetRef != null) {
          checkAndShowShareSheet();
        }
      }
    });
  }

  void _handleSharedContentWithRef(
    List<SharedFile> sharedFiles, {
    int retryCount = 0,
  }) {
    debugPrint(
      "SharingIntentService: Received ${sharedFiles.length} shared files",
    );
    for (final file in sharedFiles) {
      debugPrint(
        "SharingIntentService: File path: ${file.value}, type: ${file.type}",
      );
    }

    final List<XFile> files = sharedFiles
        .where(
          (file) =>
              file.type == SharedMediaType.IMAGE ||
              file.type == SharedMediaType.VIDEO ||
              file.type == SharedMediaType.FILE,
        )
        .map((file) => XFile(file.value!, name: file.value!.split('/').last))
        .toList();

    final List<String> links = sharedFiles
        .where((file) => file.type == SharedMediaType.URL)
        .map((file) => file.value!)
        .toList();

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
        debugPrint(
          "SharingIntentService: Dispatching deep link $solianDeepLink",
        );
        eventBus.fire(SolianDeepLinkEvent(uri));
        return;
      }
    }

    final ctx = _widgetRef!.read(routerProvider).navigatorKey.currentContext;
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
        _handleSharedContentWithRef(sharedFiles, retryCount: retryCount + 1);
      });
      return;
    }

    debugPrint("SharingIntentService: Showing share sheet");
    if (files.isNotEmpty) {
      showShareSheet(context: ctx, content: ShareContent.files(files));
    } else if (links.isNotEmpty) {
      showShareSheet(context: ctx, content: ShareContent.link(links.first));
    } else {
      showShareSheet(
        context: ctx,
        content: ShareContent.text(
          sharedFiles
              .where((file) => file.type == SharedMediaType.TEXT)
              .map((text) => text.message)
              .join('\n'),
        ),
      );
    }
  }

  void dispose() {
    _intentSub?.cancel();
  }
}
