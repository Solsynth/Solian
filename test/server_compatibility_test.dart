import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/server_compatibility.dart';

Map<String, dynamic> metadata({
  int apiRevision = 1,
  int minimumRevision = 0,
  bool incomplete = false,
  Set<String> disabledCapabilities = const {},
}) => {
  'api_revision': apiRevision,
  'minimum_revision': minimumRevision,
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
  test('accepts a server with a compatible protocol and core capabilities', () {
    expect(ServerCompatibility.fromMetadata(metadata()).isCompatible, isTrue);
  });

  test('rejects a server that requires a newer client protocol', () {
    final result = ServerCompatibility.fromMetadata(
      metadata(minimumRevision: 2),
    );
    expect(result.issue, ServerCompatibilityIssue.clientTooOld);
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
