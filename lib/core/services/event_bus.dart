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

  const ChatMessageUpdateEvent(this.message);
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

  const ChatTypingEvent({
    required this.roomId,
    required this.sender,
    required this.isTyping,
  });
}

/// Event fired when OIDC auth callback is received
class OidcAuthCallbackEvent {
  final String challengeId;

  const OidcAuthCallbackEvent(this.challengeId);
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
  final String roomId;
  final int newEpoch;

  const MlsEpochChangedEvent({required this.roomId, required this.newEpoch});
}

/// Event fired when MLS requires a reshare for a room
class MlsReshareRequiredEvent {
  final String roomId;

  const MlsReshareRequiredEvent({required this.roomId});
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
