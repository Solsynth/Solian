import 'package:event_bus/event_bus.dart';

/// Global event bus instance for the application
final eventBus = EventBus();

/// Event fired when a post is successfully created
class PostCreatedEvent {
  final String? postId;
  final String? title;
  final String? content;

  const PostCreatedEvent({this.postId, this.title, this.content});
}

/// Event fired when chat rooms need to be refreshed
class ChatRoomsRefreshEvent {
  const ChatRoomsRefreshEvent();
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
