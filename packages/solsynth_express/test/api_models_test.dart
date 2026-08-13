import 'package:flutter_test/flutter_test.dart';
import 'package:solsynth_express/solsynth_express.dart';

void main() {
  test('parses release artifacts and selects a compatible download', () {
    final release = distributionReleaseFromJson({
      'id': 'release-1',
      'version': '1.4.0',
      'title': 'Maintenance release',
      'release_notes': 'Fixes',
      'force_update': true,
      'artifacts': [
        {
          'id': 'artifact-1',
          'platform': 'macos',
          'architecture': 'arm64',
          'file_name': 'solian.zip',
          'download_url': 'https://cdn.example/solian.zip',
          'size': 42,
        },
        {'platform': 'windows', 'architecture': 'amd64', 'download_url': ''},
      ],
    });

    expect(release, isNotNull);
    expect(release!.tagName, '1.4.0');
    expect(release.forceUpdate, isTrue);
    expect(
      release.artifactFor('macos', 'arm64')!.downloadUrl,
      'https://cdn.example/solian.zip',
    );
    expect(release.artifactFor('windows', 'amd64'), isNull);
  });

  test('computes the digest used by the upload-url contract', () {
    expect(
      sha256Digest([1, 2, 3]),
      '039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81',
    );
  });

  test('parses remote update channels with localized labels', () {
    final channel = distributionChannelFromJson({
      'id': 'channel-1',
      'name': 'beta',
      'display_name': 'Beta',
      'display_names': {'zh-CN': '测试版'},
    });

    expect(channel, isNotNull);
    expect(channel!.name, 'beta');
    expect(channel.label('zh-CN'), '测试版');
    expect(channel.label('en-US'), 'Beta');
  });
}
