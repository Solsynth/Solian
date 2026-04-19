import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/accounts/account_pod.dart';
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

/// A stream item represents a piece of data received from the thought streaming API
class StreamItem {
  const StreamItem(this.type, this.data);
  final String type;
  final dynamic data;
}

/// Immutable state for the thought chat
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

  /// Gets the available models for the currently selected service
  List<ThoughtServiceModel> get availableModels {
    if (selectedServiceId.isEmpty) return [];
    final service = services
        .where((s) => s.id == selectedServiceId)
        .firstOrNull;
    return service?.availableModels ?? [];
  }
}

/// Arguments for the thought chat notifier
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

/// Notifier for managing thought chat state
@riverpod
class ThoughtChatNotifier extends _$ThoughtChatNotifier {
  TextEditingController? _messageController;
  ScrollController? _scrollController;
  ListController? _listController;

  // Track attached messages and posts for sending
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
    // Initialize controllers
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _listController = ListController();
    _attachedMessages = args.attachedMessages;
    _attachedPosts = args.attachedPosts;

    // Listen to services provider
    final servicesAsync = ref.watch(thoughtServicesProvider);

    // Initialize state from args and services
    String selectedServiceId = '';
    String? selectedModel;
    List<ThoughtService> services = [];

    if (servicesAsync.hasValue) {
      final response = servicesAsync.value!;
      services = response.services;
      selectedServiceId = response.defaultBot;
      // Default model is null (Auto - let server decide)
      selectedModel = null;
    }

    // Handle initial message if provided
    if (args.initialMessage?.isNotEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sendMessage(message: args.initialMessage);
      });
    }

    // Dispose controllers when provider is disposed
    ref.onDispose(() {
      _messageController?.dispose();
      _scrollController?.dispose();
      // ListController doesn't need disposal
    });

    return ThoughtChatState(
      sequenceId: args.initialSequenceId,
      localThoughts: args.initialThoughts ?? [],
      currentTopic: args.initialTopic ?? 'aiThought'.tr(),
      services: services,
      selectedServiceId: selectedServiceId,
      selectedModel: selectedModel,
    );
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

  Future<void> loadMichanCanonicalThread() async {
    try {
      final apiClient = ref.read(solarNetworkClientProvider).dio;
      final sequenceResponse = await apiClient.get(
        '/insight/thought/michan/sequence',
      );
      final sequence = SnThinkingSequence.fromJson(sequenceResponse.data);

      final thoughtsResponse = await apiClient.get(
        '/insight/thought/sequences/${sequence.id}',
        queryParameters: {'offset': 0, 'take': 50},
      );
      final thoughts = (thoughtsResponse.data as List)
          .map((e) => SnThinkingThought.fromJson(e))
          .toList();

      state = state.copyWith(
        sequenceId: sequence.id,
        localThoughts: thoughts,
        currentTopic: sequence.topic ?? 'aiThought'.tr(),
        selectedServiceId: 'michan',
        selectedModel: null,
        attachments: const [],
        attachmentProgress: const {},
        hasInitialAttachmentsBeenSent: false,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        state = state.copyWith(
          sequenceId: null,
          localThoughts: const [],
          currentTopic: 'aiThought'.tr(),
          selectedServiceId: 'michan',
          selectedModel: null,
          attachments: const [],
          attachmentProgress: const {},
          hasInitialAttachmentsBeenSent: false,
        );
        return;
      }
      showErrorAlert(error);
    } catch (error) {
      showErrorAlert(error);
    }
  }

  /// Updates the sequence ID (e.g., when loaded from external source)
  void updateSequenceId(String? sequenceId) {
    state = state.copyWith(
      sequenceId: sequenceId,
      hasInitialAttachmentsBeenSent: false,
    );
  }

  /// Updates the thoughts list (e.g., when loaded from external source)
  void updateThoughts(List<SnThinkingThought> thoughts) {
    state = state.copyWith(localThoughts: thoughts);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  /// Updates the topic
  void updateTopic(String? topic) {
    if (topic != null) {
      state = state.copyWith(currentTopic: topic);
    }
  }

  /// Updates the services list and default service
  void updateServices(ThoughtServicesResponse response) {
    final currentValue = state.selectedServiceId;
    final isValueValid =
        currentValue.isNotEmpty &&
        response.services.any((s) => s.id == currentValue);

    final newServiceId = isValueValid ? currentValue : response.defaultBot;

    state = state.copyWith(
      services: response.services,
      selectedServiceId: newServiceId,
      selectedModel: null,
    );
  }

  /// Sets the selected service ID
  Future<void> setSelectedServiceId(String serviceId) async {
    final previousServiceId = state.selectedServiceId;
    if (serviceId == previousServiceId) return;

    // Clear the chat state for the new service
    clearChat(selectedServiceId: serviceId);

    // Load michan canonical thread when switching to michan
    if (serviceId == 'michan') {
      await loadMichanCanonicalThread();
    }
  }

  /// Sets the selected model ID
  void setSelectedModel(String? modelId) {
    state = state.copyWith(selectedModel: modelId);
  }

  /// Updates attachments
  void updateAttachments(List<UniversalFile> attachments) {
    state = state.copyWith(attachments: attachments);
  }

  /// Deletes an attachment at the given index
  void deleteAttachment(int index) {
    final newAttachments = [...state.attachments];
    if (index >= 0 && index < newAttachments.length) {
      newAttachments.removeAt(index);
      state = state.copyWith(attachments: newAttachments);
    }
  }

  /// Uploads an attachment at the given index
  Future<UniversalFile> uploadAttachment(int index) async {
    final attachment = state.attachments[index];
    if (attachment.isOnCloud) return attachment;

    state = state.copyWith(
      attachmentProgress: {...state.attachmentProgress, index: 0.0},
    );

    try {
      SnCloudFile? cloudFile;

      final pools = await ref.read(poolsProvider.future);
      final selectedPoolId = resolveDefaultPoolId(
        ref.read(appSettingsProvider),
        pools,
      );

      cloudFile = await ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: attachment,
            poolId: selectedPoolId,
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
        throw ArgumentError('Failed to upload the file...');
      }

      final clone = List.of(state.attachments);
      clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
      state.copyWith(attachments: clone);
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

  /// Sends a message to the thought API
  Future<void> sendMessage({String? message}) async {
    if (message == null && messageController.text.trim().isEmpty) {
      return;
    }

    final userMessage = message ?? messageController.text.trim();

    // Upload any pending attachments first
    List<String>? attachmentIds;
    final attachments = List.from(state.attachments);
    if (attachments.isNotEmpty) {
      for (int i = 0; i < attachments.length; i++) {
        if (!attachments[i].isOnCloud) {
          final newFile = await uploadAttachment(i);
          attachments[i] = newFile;
        }
      }
      attachmentIds = attachments
          .where((a) => a.isOnCloud)
          .map((a) => (a.data as SnCloudFile).id)
          .toList();
    }

    // Add user message to local thoughts
    final userInfo = ref.read(userInfoProvider);
    final now = DateTime.now();
    final userThought = SnThinkingThought(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      isArchived: false,
      parts: [
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: userMessage,
          files: attachments
              .where((a) => a.isOnCloud)
              .map((a) => a.data)
              .cast<SnCloudFile>()
              .toList(),
        ),
      ],
      role: ThinkingThoughtRole.user,
      sequenceId: state.sequenceId ?? '',
      createdAt: now,
      updatedAt: now,
      sequence: SnThinkingSequence(
        id: state.sequenceId ?? '',
        accountId: userInfo.value!.id,
        createdAt: now,
        updatedAt: now,
        lastMessageAt: now,
      ),
    );

    // Clear attachments after upload
    state = state.copyWith(attachments: []);

    state = state.copyWith(
      localThoughts: [userThought, ...state.localThoughts],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Only include attached messages/posts on the first message of the conversation
    final shouldIncludeAttachments = !state.hasInitialAttachmentsBeenSent;

    final request = StreamThinkingRequest(
      userMessage: userMessage,
      sequenceId: state.sequenceId,
      acceptProposals: ['post_create'],
      attachedMessages: shouldIncludeAttachments ? _attachedMessages : const [],
      attachedPosts: shouldIncludeAttachments ? _attachedPosts : const [],
      attachedFiles: attachmentIds,
      bot: state.selectedServiceId.isNotEmpty
          ? state.selectedServiceId
          : 'snchan',
      model: state.selectedModel,
    );

    // Mark initial attachments as sent after first message
    if (shouldIncludeAttachments) {
      state = state.copyWith(hasInitialAttachmentsBeenSent: true);
    }

    try {
      state = state.copyWith(isStreaming: true, streamingItems: []);

      final apiClient = ref.read(solarNetworkClientProvider).dio;
      final response = await apiClient.post(
        '/insight/thought',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          sendTimeout: Duration(hours: 1),
          receiveTimeout: Duration(hours: 1),
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      final lineBuffer = StringBuffer();

      stream.listen(
        (data) {
          final chunk = utf8.decode(data);
          lineBuffer.write(chunk);
          final lines = lineBuffer.toString().split('\n');
          lineBuffer.clear();
          lineBuffer.write(lines.last); // keep incomplete line

          for (final line in lines.sublist(0, lines.length - 1)) {
            if (line.trim().isEmpty) continue;
            try {
              if (line.startsWith('data: ')) {
                final jsonStr = line.substring(6);
                final event = jsonDecode(jsonStr);
                final type = event['type'];
                final eventData = event['data'];
                if (type != 'text') {
                  Logger.root.info(
                    '[Thought] Received event: $type ${jsonEncode(eventData)}',
                  );
                }
                switch (type) {
                  case 'text':
                    state = state.copyWith(
                      streamingItems: [
                        ...state.streamingItems,
                        StreamItem('text', eventData),
                      ],
                    );
                    break;
                  case 'function_call':
                    try {
                      final mappedData = {
                        'id': eventData['Id'],
                        'name': eventData['Name'],
                        'arguments': eventData['Arguments'] ?? '',
                      };
                      state = state.copyWith(
                        streamingItems: [
                          ...state.streamingItems,
                          StreamItem(
                            'function_call',
                            SnFunctionCall.fromJson(mappedData),
                          ),
                        ],
                      );
                    } catch (e, st) {
                      Logger.root.severe(
                        'Failed to parse function_call: $eventData',
                        e,
                        st,
                      );
                    }
                    break;
                  case 'function_result':
                    try {
                      final mappedData = {
                        'callId': eventData['CallId'],
                        'result': eventData['Result'],
                        'isError': eventData['IsError'] ?? false,
                      };
                      state = state.copyWith(
                        streamingItems: [
                          ...state.streamingItems,
                          StreamItem(
                            'function_result',
                            SnFunctionResult.fromJson(mappedData),
                          ),
                        ],
                      );
                    } catch (e, st) {
                      Logger.root.severe(
                        'Failed to parse function_result: $eventData',
                        e,
                        st,
                      );
                    }
                    break;
                  case 'reasoning':
                    state = state.copyWith(
                      streamingItems: [
                        ...state.streamingItems,
                        StreamItem('reasoning', eventData),
                      ],
                    );
                    break;
                  case 'status':
                    final statusText = eventData as String?;
                    String? localizedStatus;
                    switch (statusText) {
                      case 'compacting':
                        localizedStatus = 'thoughtStatusCompacting'.tr();
                        break;
                      case 'preparing_context':
                        localizedStatus = 'thoughtStatusPreparingContext'.tr();
                        break;
                      default:
                        localizedStatus = statusText;
                    }
                    state = state.copyWith(currentStatus: localizedStatus);
                    break;
                  case 'context_cleared':
                    state = state.copyWith(
                      sequenceId: eventData['new_sequence_id'],
                      compactSummary: eventData['summary'],
                      archivedCount: eventData['archived_count'] as int?,
                      currentStatus: 'thoughtStatusContextCleared'.tr(),
                    );
                    final newSeqId = eventData['new_sequence_id'] as String?;
                    if (newSeqId != null) {
                      ref.invalidate(thoughtSequenceProvider(newSeqId));
                    }
                    break;
                  case 'compacted':
                    state = state.copyWith(
                      compactSummary: eventData['summary'],
                      archivedCount: eventData['archived_count'] as int?,
                      currentStatus: 'thoughtStatusCompacted'.tr(),
                    );
                    break;
                  case 'auto_compacted':
                    state = state.copyWith(
                      compactSummary: eventData['summary'],
                      archivedCount: eventData['archived_count'] as int?,
                      currentStatus: 'thoughtStatusAutoCompacted'.tr(),
                    );
                    break;
                  default:
                    // ignore unknown types
                    break;
                }
              } else if (line.startsWith('topic: ')) {
                final jsonStr = line.substring(7);
                final event = jsonDecode(jsonStr);
                state = state.copyWith(currentTopic: event['data']);
              } else if (line.startsWith('thought: ')) {
                final jsonStr = line.substring(9);
                final event = jsonDecode(jsonStr);
                final aiThought = SnThinkingThought.fromJson(event['data']);
                state = state.copyWith(
                  localThoughts: [aiThought, ...state.localThoughts],
                  isStreaming: false,
                  currentStatus: null,
                  compactSummary: null,
                  archivedCount: null,
                );
                if (state.sequenceId == null &&
                    aiThought.sequenceId.isNotEmpty) {
                  state = state.copyWith(sequenceId: aiThought.sequenceId);
                }

                // Refresh quota after message response completes
                ref.invalidate(thoughtQuotaProvider);
              }
            } catch (e) {
              // Ignore parsing errors for individual events
            }
          }
        },
        onDone: () {
          if (state.isStreaming) {
            _handleStreamError('thoughtParseError'.tr());
          }
        },
        onError: (error) {
          final errorMessage =
              error is DioException && error.response?.data is ResponseBody
              ? 'thoughtParseError'.tr()
              : error.toString();
          _handleStreamError(errorMessage);
        },
      );

      messageController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (error) {
      _handleStreamError(error.toString());
    }
  }

  void _handleStreamError(String errorMessage) {
    final now = DateTime.now();
    final errorThought = SnThinkingThought(
      id: 'error-${DateTime.now().millisecondsSinceEpoch}',
      isArchived: false,
      parts: [
        SnThinkingMessagePart(
          type: ThinkingMessagePartType.text,
          text: 'Error: $errorMessage',
        ),
      ],
      role: ThinkingThoughtRole.assistant,
      sequenceId: state.sequenceId ?? '',
      createdAt: now,
      updatedAt: now,
      sequence: SnThinkingSequence(
        id: state.sequenceId ?? '',
        accountId: '',
        createdAt: now,
        updatedAt: now,
        lastMessageAt: now,
      ),
    );

    state = state.copyWith(
      isStreaming: false,
      localThoughts: [errorThought, ...state.localThoughts],
      currentStatus: null,
      compactSummary: null,
      archivedCount: null,
    );
  }

  /// Clears the chat state for a new conversation
  void clearChat({String? selectedServiceId}) {
    final serviceId = selectedServiceId ?? state.selectedServiceId;

    state = ThoughtChatState(
      currentTopic: 'aiThought'.tr(),
      services: state.services,
      selectedServiceId: serviceId,
      selectedModel: null,
    );
    messageController.clear();
  }
}
