import 'package:flutter_test/flutter_test.dart';
import 'package:island/drive/widgets/cloud_files.dart';

void main() {
  test('uses up to two letters for a single Latin word', () {
    expect(avatarFallbackText('alice'), 'AL');
    expect(avatarFallbackText(' A '), 'A');
  });

  test('uses one CJK grapheme for CJK names', () {
    expect(avatarFallbackText('太阳'), '太');
    expect(avatarFallbackText('李四'), '李');
  });

  test('uses one whole emoji grapheme', () {
    expect(avatarFallbackText('😀'), '😀');
    expect(avatarFallbackText('👨‍👩‍👧'), '👨‍👩‍👧');
  });

  test('uses word initials for multi-word Latin names', () {
    expect(avatarFallbackText('Alice Zhang'), 'AZ');
    expect(avatarFallbackText('john doe'), 'JD');
  });

  test('does not create fallback text for missing nicknames', () {
    expect(avatarFallbackText(null), isNull);
    expect(avatarFallbackText('   '), isNull);
  });
}
