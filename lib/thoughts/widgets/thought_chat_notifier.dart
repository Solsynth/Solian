import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/thoughts/screens/think.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

part 'thought_chat_notifier.g.dart';

class StreamItem {
  const StreamItem(this.type, this.data);
  final String type;
  final dynamic data;
}

class ThoughtChatState {
  final String? sequenceId;
  final List<SnThinkingThought> localThoughts;
  final String? currentTopic;
  final String? currentStatus;
  final String? compactSummary;
  final int? archivedCount;
  final List<ThoughtService> services;
  final String selectedServiceId;
  final String? selectedModel;
  final bool isStreaming;
  final List<StreamItem> streamingItems;
  final List<UniversalFile> attachments;
  final Map<int, double?> attachmentProgress;
  final bool hasInitialAttachmentsBeenSent;

  const ThoughtChatState({
    this.sequenceId,
    this.localThoughts = const [],
    this.currentTopic,
    this.currentStatus,
    this.compactSummary,
    this.archivedCount,
    this.services = const [],
    this.selectedServiceId = '',
    this.selectedModel,
    this.isStreaming = false,
    this.streamingItems = const [],
    this.attachments = const [],
    this.attachmentProgress = const {},
    this.hasInitialAttachmentsBeenSent = false,
  });

  ThoughtChatState copyWith({
    String? sequenceId,
    List<SnThinkingThought>? localThoughts,
    String? currentTopic,
    String? currentStatus,
    String? compactSummary,
    int? archivedCount,
    List<ThoughtService>? services,
    String? selectedServiceId,
    String? selectedModel,
    bool? isStreaming,
    List<StreamItem>? streamingItems,
    List<UniversalFile>? attachments,
    Map<int, double?>? attachmentProgress,
    bool? hasInitialAttachmentsBeenSent,
  }) {
    return ThoughtChatState(
      sequenceId: sequenceId ?? this.sequenceId,
      localThoughts: localThoughts ?? this.localThoughts,
      currentTopic: currentTopic ?? this.currentTopic,
      currentStatus: currentStatus ?? this.currentStatus,
      compactSummary: compactSummary ?? this.compactSummary,
      archivedCount: archivedCount ?? this.archivedCount,
      services: services ?? this.services,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      selectedModel: selectedModel ?? this.selectedModel,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingItems: streamingItems ?? this.streamingItems,
      attachments: attachments ?? this.attachments,
      attachmentProgress: attachmentProgress ?? this.attachmentProgress,
      hasInitialAttachmentsBeenSent:
          hasInitialAttachmentsBeenSent ?? this.hasInitialAttachmentsBeenSent,
    );
  }

  List<ThoughtServiceModel> get availableModels {
    if (selectedServiceId.isEmpty) return const [];
    return services
            .where((service) => service.id == selectedServiceId)
            .firstOrNull
            ?.availableModels ??
        const [];
  }
}

class ThoughtChatArgs {
  final String? initialSequenceId;
  final List<SnThinkingThought>? initialThoughts;
  final String? initialTopic;
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ThoughtChatArgs({
    this.initialSequenceId,
    this.initialThoughts,
    this.initialTopic,
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThoughtChatArgs &&
        other.initialSequenceId == initialSequenceId &&
        other.initialTopic == initialTopic &&
        other.initialMessage == initialMessage;
  }

  @override
  int get hashCode =>
      initialSequenceId.hashCode ^
      initialTopic.hashCode ^
      initialMessage.hashCode;
}

@riverpod
class ThoughtChatNotifier extends _$ThoughtChatNotifier {
  TextEditingController? _messageController;
  ScrollController? _scrollController;
  ListController? _listController;
  late List<Map<String, dynamic>> _attachedMessages;
  late List<String> _attachedPosts;

  TextEditingController get messageController {
    _messageController ??= TextEditingController();
    return _messageController!;
  }

  ScrollController get scrollController {
    _scrollController ??= ScrollController();
    return _scrollController!;
  }

  ListController get listController {
    _listController ??= ListController();
    return _listController!;
  }

  @override
  ThoughtChatState build(ThoughtChatArgs args) {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _listController = ListController();
    _attachedMessages = args.attachedMessages;
    _attachedPosts = args.attachedPosts;

    final servicesAsync = ref.watch(thoughtServicesProvider);
    final services = servicesAsync.value?.services ?? const <ThoughtService>[];
    final initialServiceId = _resolveInitialServiceId(
      services,
      args.initialThoughts,
      args.initialSequenceId,
    );

    if (args.initialMessage?.isNotEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sendMessage(message: args.initialMessage);
      });
    }

    ref.onDispose(() {
      _messageController?.dispose();
      _scrollController?.dispose();
    });

    return ThoughtChatState(
      sequenceId: args.initialSequenceId,
      localThoughts: args.initialThoughts ?? const [],
      currentTopic: args.initialTopic ?? 'aiThought'.tr(),
      services: services,
      selectedServiceId: initialServiceId,
    );
  }

  String _resolveInitialServiceId(
    List<ThoughtService> services,
    List<SnThinkingThought>? initialThoughts,
    String? initialSequenceId,
  ) {
    final botName = initialThoughts?.firstOrNull?.botName;
    if (botName != null && services.any((service) => service.id == botName)) {
      return botName;
    }
    final serviceFromConversation = stateOrNull?.selectedServiceId;
    if (serviceFromConversation != null &&
        services.any((service) => service.id == serviceFromConversation)) {
      return serviceFromConversation;
    }
    return services.firstOrNull?.id ?? '';
  }

  @override
  ThoughtChatState? get stateOrNull {
    try {
      return state;
    } catch (_) {
      return null;
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> loadConversation(String conversationId) async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      final conversation = await client.thoughts.getSequence(conversationId);
      final thoughts = await client.thoughts.getSequenceMessages(conversationId);

      state = state.copyWith(
        sequenceId: conversationId,
        localThoughts: thoughts,
        currentTopic: conversation.topic ?? 'aiThought'.tr(),
        selectedServiceId: conversation.botName ?? state.selectedServiceId,
        attachments: const [],
        attachmentProgress: const {},
        hasInitialAttachmentsBeenSent: true,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (error) {
      showErrorAlert(error);
    }
  }

  void updateSequenceId(String? sequenceId) {
    state = state.copyWith(sequenceId: sequenceId);
  }

  void updateThoughts(List<SnThinkingThought> thoughts) {
    state = state.copyWith(localThoughts: thoughts);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void updateTopic(String? topic) {
    if (topic == null) return;
    state = state.copyWith(currentTopic: topic);
  }

  void updateServices(ThoughtServicesResponse response) {
    final currentValue = state.selectedServiceId;
    final isValueValid = response.services.any((s) => s.id == currentValue);
    state = state.copyWith(
      services: response.services,
      selectedServiceId: isValueValid
          ? currentValue
          : (response.defaultBot.isNotEmpty
                ? response.defaultBot
                : response.services.firstOrNull?.id ?? ''),
      selectedModel: null,
    );
  }

  void syncServiceId(String serviceId) {
    if (serviceId == state.selectedServiceId) return;
    state = state.copyWith(selectedServiceId: serviceId);
  }

  Future<void> setSelectedServiceId(String serviceId) async {
    if (serviceId == state.selectedServiceId) return;
    clearChat(selectedServiceId: serviceId);
  }

  void setSelectedModel(String? modelId) {
    state = state.copyWith(selectedModel: modelId);
  }

  void updateAttachments(List<UniversalFile> attachments) {
    state = state.copyWith(attachments: attachments);
  }

  void deleteAttachment(int index) {
    final newAttachments = [...state.attachments];
    if (index >= 0 && index < newAttachments.length) {
      newAttachments.removeAt(index);
      state = state.copyWith(attachments: newAttachments);
    }
  }

  Future<UniversalFile> uploadAttachment(int index) async {
    final attachment = state.attachments[index];
    if (attachment.isOnCloud) return attachment;

    state = state.copyWith(
      attachmentProgress: {...state.attachmentProgress, index: 0.0},
    );

    try {
      final pools = await ref.read(poolsProvider.future);
      final selectedPoolId = resolveDefaultPoolId(
        ref.read(appSettingsProvider),
        pools,
      );

      final cloudFile = await ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: attachment,
            poolId: selectedPoolId,
            usage: 'thought',
            mode: attachment.type == UniversalFileType.file
                ? FileUploadMode.generic
                : FileUploadMode.mediaSafe,
            onProgress: (progress, _) {
              state = state.copyWith(
                attachmentProgress: {
                  ...state.attachmentProgress,
                  index: progress ?? 0.0,
                },
              );
            },
          )
          .future;

      if (cloudFile == null) {
        throw ArgumentError('Failed to upload the file.');
      }

      final clone = List.of(state.attachments);
      clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
      state = state.copyWith(attachments: clone);
      return clone[index];
    } catch (err) {
      showErrorAlert(err);
      return attachment;
    } finally {
      state = state.copyWith(
        attachmentProgress: {...state.attachmentProgress}..remove(index),
      );
    }
  }

  Future<void> sendMessage({String? message}) async {
    if (message == null && messageController.text.trim().isEmpty) return;

    final client = ref.read(solarNetworkClientProvider);
    final userMessage = message ?? messageController.text.trim();
    final uploadedAttachments = List<UniversalFile>.from(state.attachments);

    for (int i = 0; i < uploadedAttachments.length; i++) {
      if (!uploadedAttachments[i].isOnCloud) {
        uploadedAttachments[i] = await uploadAttachment(i);
      }
    }

    final now = DateTime.now();
    final conversationId = await _ensureConversation(userMessage);

    final userThought = SnThinkingThought(
      id: 'user-${now.microsecondsSinceEpoch}',
      role: ThinkingThoughtRole.user,
      sequenceId: conversationId,
      botName: state.selectedServiceId,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
      parts: [
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: userMessage,
          files: uploadedAttachments
              .map((item) => item.data)
              .whereType<SnCloudFileReference>()
              .toList(),
        ),
      ],
    );

    state = state.copyWith(
      localThoughts: [userThought, ...state.localThoughts],
      attachments: const [],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final inputParts = await _buildInputParts(
      userMessage: userMessage,
      attachments: uploadedAttachments,
    );

    if (!state.hasInitialAttachmentsBeenSent) {
      state = state.copyWith(hasInitialAttachmentsBeenSent: true);
    }

    try {
      state = state.copyWith(
        isStreaming: true,
        streamingItems: const [],
        currentStatus: 'thoughtStatusPreparingContext'.tr(),
      );

      final response = await client.thoughts.createRun(
        conversationId: conversationId,
        stream: true,
        data: {
          'message': userMessage,
          'stream': true,
          if (inputParts.isNotEmpty) 'input_parts': inputParts,
        },
      );

      final stream = response.data.stream as Stream<List<int>>;
      await _consumeRunStream(stream, conversationId);
      messageController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (error) {
      _handleStreamError(error.toString());
    }
  }

  Future<String> _ensureConversation(String firstMessage) async {
    if (state.sequenceId != null && state.sequenceId!.isNotEmpty) {
      return state.sequenceId!;
    }

    final client = ref.read(solarNetworkClientProvider);
    final conversation = await client.thoughts.createConversation(
      agentId: state.selectedServiceId.isNotEmpty
          ? state.selectedServiceId
          : (state.services.firstOrNull?.id ?? 'assistant'),
      title: firstMessage.trim().isEmpty
          ? 'New conversation'
          : firstMessage.trim().split('\n').first,
    );

    state = state.copyWith(
      sequenceId: conversation.id,
      currentTopic: conversation.title,
    );
    return conversation.id;
  }

  Future<List<Map<String, dynamic>>> _buildInputParts({
    required String userMessage,
    required List<UniversalFile> attachments,
  }) async {
    final parts = <Map<String, dynamic>>[];
    final contextLines = <String>[];
    final serverUrl = ref.read(serverUrlProvider);

    if (!state.hasInitialAttachmentsBeenSent) {
      if (_attachedMessages.isNotEmpty) {
        contextLines.add('Attached messages context:');
        contextLines.add(const JsonEncoder.withIndent('  ').convert(_attachedMessages));
      }
      if (_attachedPosts.isNotEmpty) {
        contextLines.add('Attached post IDs: ${_attachedPosts.join(', ')}');
      }
    }

    for (final attachment in attachments) {
      final cloudFile = attachment.data is SnCloudFile
          ? attachment.data as SnCloudFile
          : null;
      if (cloudFile == null) continue;

      final fileUrl = cloudFile.storageUrl ?? '$serverUrl/drive/files/${cloudFile.id}';
      if (cloudFile.mimeType.startsWith('image/')) {
        parts.add({
          'type': 'image_url',
          'image_url': fileUrl,
          'detail': 'high',
        });
      } else {
        contextLines.add(
          'Attached file: ${cloudFile.name} (${cloudFile.mimeType}) $fileUrl',
        );
      }
    }

    if (contextLines.isNotEmpty) {
      parts.insert(0, {
        'type': 'text',
        'text': contextLines.join('\n'),
      });
    }

    return parts;
  }

  Future<void> _consumeRunStream(
    Stream<List<int>> stream,
    String conversationId,
  ) async {
    String? eventName;
    final lineBuffer = StringBuffer();

    await for (final data in stream) {
      final chunk = utf8.decode(data);
      lineBuffer.write(chunk);
      final lines = lineBuffer.toString().split('\n');
      lineBuffer
        ..clear()
        ..write(lines.last);

      for (final rawLine in lines.take(lines.length - 1)) {
        final line = rawLine.trimRight();
        if (line.isEmpty) {
          eventName = null;
          continue;
        }
        if (line.startsWith('event: ')) {
          eventName = line.substring(7).trim();
          continue;
        }
        if (!line.startsWith('data: ')) continue;

        final payload = line.substring(6);
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleSseEvent(
          eventName: eventName ?? '',
          data: data,
          conversationId: conversationId,
        );
      }
    }

    if (state.isStreaming) {
      state = state.copyWith(
        isStreaming: false,
        streamingItems: const [],
        currentStatus: null,
      );
    }
  }

  void _handleSseEvent({
    required String eventName,
    required Map<String, dynamic> data,
    required String conversationId,
  }) {
    switch (eventName) {
      case 'run.started':
        state = state.copyWith(
          sequenceId: data['conversation_id']?.toString() ?? conversationId,
          currentStatus: 'Running',
        );
        break;
      case 'reasoning.delta':
        final delta = data['delta']?.toString() ?? '';
        if (delta.isEmpty) break;
        final lastItem = state.streamingItems.lastOrNull;
        if (lastItem != null && lastItem.type == 'reasoning') {
          state = state.copyWith(
            streamingItems: [
              ...state.streamingItems.sublist(0, state.streamingItems.length - 1),
              StreamItem('reasoning', '${lastItem.data}$delta'),
            ],
          );
        } else {
          state = state.copyWith(
            streamingItems: [...state.streamingItems, StreamItem('reasoning', delta)],
          );
        }
        break;
      case 'tool_call.delta':
        state = state.copyWith(
          streamingItems: [
            ...state.streamingItems,
            StreamItem('function_call', SnFunctionCall.fromJson(data)),
          ],
        );
        break;
      case 'message.delta':
        final delta = data['delta']?.toString() ?? '';
        if (delta.isEmpty) break;
        state = state.copyWith(
          streamingItems: [...state.streamingItems, StreamItem('text', delta)],
          currentStatus: null,
        );
        break;
      case 'message.completed':
        final content = data['content']?.toString() ?? '';
        final messageId = data['message_id']?.toString() ?? '';
        final completedAt = DateTime.now();
        final assistantThought = SnThinkingThought(
          id: messageId.isNotEmpty
              ? messageId
              : 'assistant-${completedAt.microsecondsSinceEpoch}',
          role: ThinkingThoughtRole.assistant,
          sequenceId: conversationId,
          botName: state.selectedServiceId,
          createdAt: completedAt,
          updatedAt: completedAt,
          isArchived: false,
          modelName: state.services
              .where((service) => service.id == state.selectedServiceId)
              .firstOrNull
              ?.availableModels
              .firstOrNull
              ?.id,
          parts: _streamingItemsToParts(state.streamingItems, fallbackText: content),
        );
        state = state.copyWith(
          localThoughts: [assistantThought, ...state.localThoughts],
          isStreaming: false,
          streamingItems: const [],
          currentStatus: null,
          compactSummary: null,
          archivedCount: null,
        );
        ref.invalidate(thoughtQuotaProvider);
        break;
      case 'run.completed':
        state = state.copyWith(isStreaming: false, currentStatus: null);
        break;
      case 'run.failed':
        _handleStreamError(data['error']?.toString() ?? 'Run failed');
        break;
      case 'heartbeat':
        Logger.root.fine('[Thought] heartbeat');
        break;
    }
  }

  List<SnThinkingMessagePart> _streamingItemsToParts(
    List<StreamItem> items, {
    required String fallbackText,
  }) {
    final parts = <SnThinkingMessagePart>[];
    for (final item in items) {
      switch (item.type) {
        case 'text':
          parts.add(
            SnThinkingMessagePart(
              type: ThinkingMessagePartType.text,
              text: item.data.toString(),
            ),
          );
          break;
        case 'reasoning':
          parts.add(
            SnThinkingMessagePart(
              type: ThinkingMessagePartType.reasoning,
              reasoning: item.data.toString(),
            ),
          );
          break;
        case 'function_call':
          parts.add(
            SnThinkingMessagePart(
              type: ThinkingMessagePartType.functionCall,
              functionCall: item.data as SnFunctionCall,
            ),
          );
          break;
        case 'function_result':
          parts.add(
            SnThinkingMessagePart(
              type: ThinkingMessagePartType.functionResult,
              functionResult: item.data as SnFunctionResult,
            ),
          );
          break;
      }
    }

    if (parts.where((part) => part.type == ThinkingMessagePartType.text).isEmpty &&
        fallbackText.isNotEmpty) {
      parts.add(
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: fallbackText,
        ),
      );
    }
    return parts;
  }

  void _handleStreamError(String errorMessage) {
    final now = DateTime.now();
    final errorThought = SnThinkingThought(
      id: 'error-${now.microsecondsSinceEpoch}',
      role: ThinkingThoughtRole.assistant,
      sequenceId: state.sequenceId ?? '',
      botName: state.selectedServiceId,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
      parts: [
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: 'Error: $errorMessage',
        ),
      ],
    );

    state = state.copyWith(
      isStreaming: false,
      localThoughts: [errorThought, ...state.localThoughts],
      streamingItems: const [],
      currentStatus: null,
      compactSummary: null,
      archivedCount: null,
    );
  }

  void clearChat({String? selectedServiceId}) {
    state = ThoughtChatState(
      currentTopic: 'aiThought'.tr(),
      services: state.services,
      selectedServiceId: selectedServiceId ?? state.selectedServiceId,
    );
    messageController.clear();
  }
}
