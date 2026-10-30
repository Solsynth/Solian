import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The timeline side of the realtime pipeline.
///
/// [RealtimeMessageHandler] only parses and persists websocket packets; this
/// sink decides what the open room does with the resulting rows. Keeping it an
/// interface avoids threading a growing list of closures through the handler.
abstract interface class MessageRealtimeSink {
  /// A row was created or re-delivered.
  void onMessageAdded(LocalChatMessage message, int? roomSequence);

  /// An existing row was edited, reacted to, or finalized.
  void onMessageChanged(LocalChatMessage message, int? roomSequence);

  /// A row was deleted or expired.
  void onMessageRemoved(LocalChatMessage message, int? roomSequence);

  /// A sender payload arrived and should refresh the member directory.
  Future<void> onSenderObserved(SnChatMember sender);

  /// The handler paused during a jump and needs a fresh load.
  void onRealtimeRefreshRequested();
}
