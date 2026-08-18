import 'package:flutter_test/flutter_test.dart';
import 'package:island/drive/widgets/cloud_files.dart';

void main() {
  test('uses up to two nickname characters for avatar fallback text', () {
    expect(avatarFallbackText('alice'), 'AL');
    expect(avatarFallbackText(' A '), 'A');
    expect(avatarFallbackText('太阳'), '太阳');
  });

  test('does not create fallback text for missing nicknames', () {
    expect(avatarFallbackText(null), isNull);
    expect(avatarFallbackText('   '), isNull);
  });
}
