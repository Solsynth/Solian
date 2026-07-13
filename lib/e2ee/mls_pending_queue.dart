import 'dart:collection';
import 'dart:typed_data';

import 'package:logging/logging.dart';

const _mlsLogPrefix = '[MLS] ';

void _mlsLog(dynamic msg) {
  Logger.root.info('$_mlsLogPrefix$msg');
}

class PendingMlsMessage {
  final String messageId;
  final String mlsGroupId;
  final Uint8List ciphertextBytes;
  final int? epoch;
  final DateTime receivedAt;

  PendingMlsMessage({
    required this.messageId,
    required this.mlsGroupId,
    required this.ciphertextBytes,
    this.epoch,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();
}

class MlsPendingMessageQueue {
  final Map<String, Queue<PendingMlsMessage>> _pendingByGroup = {};

  void enqueue(PendingMlsMessage message) {
    final groupQueue = _pendingByGroup.putIfAbsent(
      message.mlsGroupId,
      () => Queue<PendingMlsMessage>(),
    );
    if (groupQueue.any((pending) => pending.messageId == message.messageId)) {
      return;
    }
    groupQueue.add(message);
    _mlsLog(
      'Enqueued pending message ${message.messageId} for group ${message.mlsGroupId}, queue size: ${groupQueue.length}',
    );
  }

  List<PendingMlsMessage> dequeueAllForGroup(String mlsGroupId) {
    final queue = _pendingByGroup[mlsGroupId];
    if (queue == null || queue.isEmpty) {
      return [];
    }
    final messages = queue.toList();
    queue.clear();
    _mlsLog(
      'Dequeued ${messages.length} pending messages for group $mlsGroupId',
    );
    return messages;
  }

  List<PendingMlsMessage> peekAllForGroup(String mlsGroupId) {
    final queue = _pendingByGroup[mlsGroupId];
    if (queue == null || queue.isEmpty) {
      return [];
    }
    return queue.toList();
  }

  int countForGroup(String mlsGroupId) {
    return _pendingByGroup[mlsGroupId]?.length ?? 0;
  }

  bool hasPendingForGroup(String mlsGroupId) {
    return countForGroup(mlsGroupId) > 0;
  }

  void clearForGroup(String mlsGroupId) {
    _pendingByGroup[mlsGroupId]?.clear();
    _pendingByGroup.remove(mlsGroupId);
    _mlsLog('Cleared pending messages for group $mlsGroupId');
  }

  void clearAll() {
    _pendingByGroup.clear();
    _mlsLog('Cleared all pending messages');
  }
}

final mlsPendingMessageQueue = MlsPendingMessageQueue();
