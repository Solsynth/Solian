/// The API revision implemented by this version of the app.
///
/// Bump this when the client starts depending on a newer server protocol.
const kSupportedServerApiRevision = 1;

/// The capabilities required before the app can safely start its core flows.
/// Optional product capabilities are deliberately not listed here.
const kClientSupportedCapabilities = <String, int>{
  'auth': 1,
  'accounts': 1,
  'chat': 1,
  'posts': 1,
};

final kRequiredServerCapabilities = kClientSupportedCapabilities.keys;

enum ServerCompatibilityIssue {
  invalidMetadata,
  incomplete,
  serverTooOld,
  clientTooOld,
  missingCapability,
}

class ServerCompatibility {
  final ServerCompatibilityIssue? issue;
  final String? capability;

  const ServerCompatibility._({this.issue, this.capability});

  const ServerCompatibility.compatible() : this._();

  bool get isCompatible => issue == null;

  static ServerCompatibility fromMetadata(Map<String, dynamic> metadata) {
    final apiRevision = _readInt(metadata['api_revision']);
    final minimumRevision = _readInt(metadata['minimum_revision']);
    if (apiRevision == null || minimumRevision == null) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.invalidMetadata,
      );
    }
    if (metadata['incomplete'] == true) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.incomplete,
      );
    }
    if (apiRevision < kSupportedServerApiRevision) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.serverTooOld,
      );
    }
    if (minimumRevision > kSupportedServerApiRevision) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.clientTooOld,
      );
    }

    final capabilities = metadata['capabilities'];
    if (capabilities is! Map) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.invalidMetadata,
      );
    }
    for (final capability in kRequiredServerCapabilities) {
      final value = capabilities[capability];
      final enabled = value is Map && value['enabled'] == true;
      final revision = value is Map ? _readInt(value['revision']) : null;
      if (!enabled || revision == null || revision < 1) {
        return ServerCompatibility._(
          issue: ServerCompatibilityIssue.missingCapability,
          capability: capability,
        );
      }
    }

    return const ServerCompatibility.compatible();
  }
}

int? _readInt(Object? value) => switch (value) {
  int value => value,
  num value => value.toInt(),
  _ => null,
};
