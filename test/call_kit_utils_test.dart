import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/utils/call_kit_utils.dart';

void main() {
  group('createSystemCallDescriptor', () {
    test('creates a stable descriptor with a native uuid distinct from room id', () {
      final descriptor = createSystemCallDescriptor(
        roomId: 'room-123',
        callerName: 'Solian Room',
        handle: '@alice',
        hasVideo: true,
        source: NativeCallSource.outgoingLocal,
      );

      expect(descriptor.roomId, 'room-123');
      expect(descriptor.callerName, 'Solian Room');
      expect(descriptor.handle, '@alice');
      expect(descriptor.hasVideo, isTrue);
      expect(descriptor.source, NativeCallSource.outgoingLocal);
      expect(descriptor.callUuid, isNotEmpty);
      expect(descriptor.callUuid, isNot('room-123'));
      expect(descriptor.metadata['room_id'], 'room-123');
    });
  });

  group('systemCallDescriptorFromPushPayload', () {
    test('normalizes nested push payload metadata', () {
      final descriptor = systemCallDescriptorFromPushPayload({
        'meta': {
          'room_id': 'room-456',
          'caller_name': 'Bob',
          'caller_id': 'bob',
          'has_video': true,
          'uuid': 'native-uuid',
        },
      });

      expect(descriptor, isNotNull);
      expect(descriptor!.roomId, 'room-456');
      expect(descriptor.callUuid, 'native-uuid');
      expect(descriptor.callerName, 'Bob');
      expect(descriptor.handle, '@bob');
      expect(descriptor.hasVideo, isTrue);
      expect(descriptor.metadata['caller_id'], 'bob');
      expect(descriptor.source, NativeCallSource.incomingPush);
    });
  });
}
