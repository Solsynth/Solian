import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatComposerSharePayload {
  final String text;
  final List<UniversalFile> attachments;

  const ChatComposerSharePayload({this.text = '', this.attachments = const []});

  bool get isEmpty => text.trim().isEmpty && attachments.isEmpty;
}

final chatSharePayloadProvider =
    Provider.family<ValueNotifier<ChatComposerSharePayload?>, String>((
      ref,
      roomId,
    ) {
      final notifier = ValueNotifier<ChatComposerSharePayload?>(null);
      ref.onDispose(notifier.dispose);
      return notifier;
    });
