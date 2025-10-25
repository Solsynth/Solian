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
