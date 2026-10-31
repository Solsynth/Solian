import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/server_compatibility.dart';

Map<String, dynamic> metadata({
  bool incomplete = false,
  Set<String> disabledCapabilities = const {},
}) => {
  'incomplete': incomplete,
  'capabilities': {
    for (final capability in kRequiredServerCapabilities)
      capability: {
        'enabled': !disabledCapabilities.contains(capability),
        'revision': 1,
      },
  },
};

void main() {
  test('accepts a server exposing the core capabilities', () {
    expect(ServerCompatibility.fromMetadata(metadata()).isCompatible, isTrue);
  });

  test('rejects an incomplete metadata response', () {
    final result = ServerCompatibility.fromMetadata(metadata(incomplete: true));
    expect(result.issue, ServerCompatibilityIssue.incomplete);
  });

  test('rejects a missing core capability', () {
    final result = ServerCompatibility.fromMetadata(
      metadata(disabledCapabilities: {'chat'}),
    );
    expect(result.issue, ServerCompatibilityIssue.missingCapability);
    expect(result.capability, 'chat');
  });
}
