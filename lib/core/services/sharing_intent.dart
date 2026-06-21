import 'dart:async';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_share_payload.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/ios_share_suggestions.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
    Logger.root.info("SharingIntentService: Initializing");
    _setupSharingListeners();
  }

  void checkAndShowShareSheet() {
    if (_pendingSharedFiles == null || _widgetRef == null) return;
    Logger.root.info("SharingIntentService: checkAndShowShareSheet called");
    final files = _pendingSharedFiles!;
    _pendingSharedFiles = null;
    unawaited(_handleSharedContentWithRef(files));
  }

  void _setupSharingListeners() {
    Logger.root.info("SharingIntentService: Setting up sharing listeners");

    _intentSub = FlutterSharingIntent.instance.getMediaStream().listen(
      (List<SharedFile> value) {
        Logger.root.info(
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
        Logger.root.severe("SharingIntentService: Stream error", err);
      },
    );

    FlutterSharingIntent.instance.getInitialSharing().then((
      List<SharedFile> value,
    ) {
      Logger.root.info(
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

  Future<void> _handleSharedContentWithRef(
    List<SharedFile> sharedFiles, {
    int retryCount = 0,
  }) async {
    Logger.root.info(
      "SharingIntentService: Received ${sharedFiles.length} shared files",
    );
    for (final file in sharedFiles) {
      Logger.root.info(
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
        .map(
          (file) => XFile(
            file.value!,
            name: file.value!.split('/').last,
            mimeType: file.mimeType,
          ),
        )
        .toList();

    final List<String> links = sharedFiles
        .where((file) => file.type == SharedMediaType.URL)
        .map((file) => file.value!)
        .toList();
    final pendingTarget = await IosShareSuggestionsService.instance
        .consumePendingTarget();

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
        Logger.root.info(
          "SharingIntentService: Dispatching deep link $solianDeepLink",
        );
        eventBus.fire(SolianDeepLinkEvent(uri));
        return;
      }
    }

    final ctx = _widgetRef!.read(routerProvider).navigatorKey.currentContext;
    if (ctx == null) {
      if (retryCount >= 12) {
        Logger.root.info(
          "SharingIntentService: Navigator context unavailable, dropping shared content",
        );
        return;
      }
      Logger.root.info(
        "SharingIntentService: Navigator context not ready, retrying...",
      );
      Future.delayed(const Duration(milliseconds: 250), () {
        unawaited(
          _handleSharedContentWithRef(sharedFiles, retryCount: retryCount + 1),
        );
      });
      return;
    }

    if (pendingTarget != null) {
      Logger.root.info(
        "SharingIntentService: Routing suggested share to room ${pendingTarget.roomId}",
      );
      _widgetRef!.read(chatSharePayloadProvider(pendingTarget.roomId)).value =
          _buildChatComposerSharePayload(sharedFiles);
      _widgetRef!
          .read(routerProvider)
          .navigate(ChatRoomRoute(id: pendingTarget.roomId));
      return;
    }

    Logger.root.info("SharingIntentService: Showing share sheet");
    final currentContext = _widgetRef!
        .read(routerProvider)
        .navigatorKey
        .currentContext;
    if (currentContext == null || !currentContext.mounted) {
      return;
    }
    if (files.isNotEmpty) {
      showShareSheet(
        context: currentContext,
        content: ShareContent.files(files),
      );
    } else if (links.isNotEmpty) {
      showShareSheet(
        context: currentContext,
        content: ShareContent.link(links.first),
      );
    } else {
      showShareSheet(
        context: currentContext,
        content: ShareContent.text(
          sharedFiles
              .where((file) => file.type == SharedMediaType.TEXT)
              .map((text) => text.value ?? text.message ?? '')
              .join('\n'),
        ),
      );
    }
  }

  ChatComposerSharePayload _buildChatComposerSharePayload(
    List<SharedFile> sharedFiles,
  ) {
    final attachments = sharedFiles
        .where(
          (file) =>
              file.value != null &&
              (file.type == SharedMediaType.IMAGE ||
                  file.type == SharedMediaType.VIDEO ||
                  file.type == SharedMediaType.FILE),
        )
        .map((file) {
          final type = switch (file.type) {
            SharedMediaType.IMAGE => UniversalFileType.image,
            SharedMediaType.VIDEO => UniversalFileType.video,
            _ => UniversalFileType.file,
          };
          return UniversalFile(
            data: XFile(
              file.value!,
              name: file.value!.split('/').last,
              mimeType: file.mimeType,
            ),
            type: type,
          );
        })
        .toList();

    final segments = <String>[];
    final shareMessage = sharedFiles
        .map((file) => file.message?.trim() ?? '')
        .firstWhere((message) => message.isNotEmpty, orElse: () => '');
    if (shareMessage.isNotEmpty) {
      segments.add(shareMessage);
    }

    segments.addAll(
      sharedFiles
          .where((file) => file.type == SharedMediaType.TEXT)
          .map((file) => file.value?.trim() ?? '')
          .where((text) => text.isNotEmpty),
    );
    segments.addAll(
      sharedFiles
          .where((file) => file.type == SharedMediaType.URL)
          .map((file) => file.value?.trim() ?? '')
          .where((link) => link.isNotEmpty),
    );

    return ChatComposerSharePayload(
      text: segments.join('\n\n'),
      attachments: attachments,
    );
  }

  void dispose() {
    _intentSub?.cancel();
  }
}
