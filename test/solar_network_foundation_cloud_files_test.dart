import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

void main() {
  group('cloudFileUrl', () {
    test('adds a workspace query parameter', () {
      expect(
        cloudFileUrl(
          serverUrl: 'https://api.example.com',
          id: 'file-1',
          workspaceId: 'workspace-1',
        ),
        'https://api.example.com/drive/files/file-1?workspace_id=workspace-1',
      );
    });

    test('preserves existing storage URL query parameters', () {
      expect(
        cloudFileUrl(
          serverUrl: 'https://api.example.com',
          id: 'file-1',
          storageUrl: 'https://storage.example.com/file-1?signature=abc',
          original: true,
          workspaceId: 'workspace-1',
        ),
        'https://storage.example.com/file-1?signature=abc&original=true&workspace_id=workspace-1',
      );
    });
  });
}
