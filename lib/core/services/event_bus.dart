import 'package:event_bus/event_bus.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Global event bus instance for the application
final eventBus = EventBus();

/// Event fired when a post is successfully created
class PostCreatedEvent {
  final SnPost post;

  const PostCreatedEvent(this.post);
}

/// Event fired when a post is updated
class PostUpdateEvent {
  final SnPost post;

  const PostUpdateEvent(this.post);
}

/// Event fired when a post is deleted
class PostDeleteEvent {
  final String postId;

  const PostDeleteEvent(this.postId);
}

/// Enum for reaction update actions
enum ReactionAction { added, removed }

/// Event fired when a post reaction is added or removed
class PostReactionUpdateEvent {
  final SnPostReaction reaction;
  final ReactionAction action;

  const PostReactionUpdateEvent({required this.reaction, required this.action});
}

/// Event fired when chat rooms need to be refreshed
class ChatRoomsRefreshEvent {
  const ChatRoomsRefreshEvent();
}

/// Event fired when chat groups need to be refreshed.
class ChatGroupsRefreshEvent {
  const ChatGroupsRefreshEvent();
}

/// Event fired when global chat message sync completes.
class ChatMessagesSyncedEvent {
  final Set<String> roomIds;

  const ChatMessagesSyncedEvent({required this.roomIds});
}

/// Event fired when a new chat message is received
class ChatMessageNewEvent {
  final SnChatMessage message;

  const ChatMessageNewEvent(this.message);
}

/// Event fired when a chat message is updated
class ChatMessageUpdateEvent {
  final SnChatMessage message;
  final bool appliedInBackground;

  const ChatMessageUpdateEvent(
    this.message, {
    this.appliedInBackground = false,
  });
}

/// Event fired when a chat message is deleted
class ChatMessageDeleteEvent {
  final String messageId;
  final String roomId;

  const ChatMessageDeleteEvent({required this.messageId, required this.roomId});
}

/// Event fired when a user is typing in a chat room
class ChatTypingEvent {
  final String roomId;
  final SnChatMember sender;
  final bool isTyping;
  final String activityType;
  final double? progress;
  final DateTime? timestamp;

  const ChatTypingEvent({
    required this.roomId,
    required this.sender,
    required this.isTyping,
    this.activityType = 'typing',
    this.progress,
    this.timestamp,
  });
}

/// Event fired when OIDC auth callback is received
class OidcAuthCallbackEvent {
  final String challengeId;

  const OidcAuthCallbackEvent(this.challengeId);
}

/// Event fired when a cross-device login approval request is received
class ChallengePendingEvent {
  final Map<String, dynamic> data;

  const ChallengePendingEvent(this.data);
}

/// Event fired to trigger the command palette
class CommandPaletteTriggerEvent {
  const CommandPaletteTriggerEvent();
}

/// Event fired to show the compose post sheet
class ShowComposeSheetEvent {
  const ShowComposeSheetEvent();
}

/// Event fired to show the notification sheet
class ShowNotificationSheetEvent {
  const ShowNotificationSheetEvent();
}

/// Event fired to show the thought sheet
class ShowThoughtSheetEvent {
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ShowThoughtSheetEvent({
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });
}

/// Event fired when a custom solian:// deep link is received on platforms
/// that deliver it via sharing intents.
class SolianDeepLinkEvent {
  final Uri uri;

  const SolianDeepLinkEvent(this.uri);
}

/// Event fired when MLS epoch changes for a room
class MlsEpochChangedEvent {
  final String mlsGroupId;
  final int newEpoch;

  const MlsEpochChangedEvent({
    required this.mlsGroupId,
    required this.newEpoch,
  });
}

/// Event fired when MLS requires a reshare for a room
class MlsReshareRequiredEvent {
  final String mlsGroupId;

  const MlsReshareRequiredEvent({required this.mlsGroupId});
}

/// Event fired when a key package is uploaded
class MlsKeyPackageUploadedEvent {
  const MlsKeyPackageUploadedEvent();
}

/// Event fired when MLS device registration completes
class MlsDeviceRegisteredEvent {
  final String deviceId;

  const MlsDeviceRegisteredEvent({required this.deviceId});
}

/// Event fired when MLS needs external join (e.g., epoch mismatch recovery)
class MlsExternalJoinStartedEvent {
  final String mlsGroupId;

  const MlsExternalJoinStartedEvent({required this.mlsGroupId});
}

/// Event fired when MLS external join completes (success or failure)
class MlsExternalJoinCompletedEvent {
  final String mlsGroupId;
  final bool success;
  final String? error;

  const MlsExternalJoinCompletedEvent({
    required this.mlsGroupId,
    required this.success,
    this.error,
  });
}

/// Event fired when MLS recovery (epoch recovery + external join + reshare) all failed
class MlsRecoveryFailedEvent {
  final String mlsGroupId;

  const MlsRecoveryFailedEvent({required this.mlsGroupId});
}

/// Event fired when MLS E2EE check/initialization starts for a room
class MlsE2eeCheckStartedEvent {
  final String mlsGroupId;

  const MlsE2eeCheckStartedEvent({required this.mlsGroupId});
}

/// Event fired when MLS E2EE check/initialization completes for a room
class MlsE2eeCheckCompletedEvent {
  final String mlsGroupId;
  final bool success;

  const MlsE2eeCheckCompletedEvent({
    required this.mlsGroupId,
    required this.success,
  });
}
