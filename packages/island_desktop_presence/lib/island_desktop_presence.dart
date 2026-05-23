import 'island_desktop_presence_platform_interface.dart';

enum PresenceState { active, idle }

class PresenceEvent {
  const PresenceEvent({required this.state, required this.idleTime});

  final PresenceState state;
  final Duration idleTime;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PresenceEvent &&
        other.state == state &&
        other.idleTime == idleTime;
  }

  @override
  int get hashCode => Object.hash(state, idleTime);
}

class IslandDesktopPresence {
  Stream<PresenceEvent> get events {
    return IslandDesktopPresencePlatform.instance.events;
  }

  Future<Duration> getIdleTime() {
    return IslandDesktopPresencePlatform.instance.getIdleTime();
  }

  Future<void> startMonitoring({required Duration idleThreshold}) {
    return IslandDesktopPresencePlatform.instance.startMonitoring(
      idleThreshold: idleThreshold,
    );
  }

  Future<void> stopMonitoring() {
    return IslandDesktopPresencePlatform.instance.stopMonitoring();
  }
}
