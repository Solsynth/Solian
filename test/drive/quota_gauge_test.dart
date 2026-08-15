import 'package:flutter_test/flutter_test.dart';
import 'package:island/drive/widgets/quota_sidebar.dart';

void main() {
  test('gauge spans base quota when there is no extra quota', () {
    final f = quotaGaugeFractions(baseMb: 100, extraMb: 0, usedMb: 50);
    expect(f.span, 100);
    expect(f.baseFraction, 1);
    expect(f.usedFraction, 0.5);
    expect(f.baseUsed, 0.5);
    expect(f.extraUsed, 0);
  });

  test('gauge splits the span between base and extra bands', () {
    final f = quotaGaugeFractions(baseMb: 100, extraMb: 50, usedMb: 50);
    expect(f.span, 150);
    expect(f.baseFraction, closeTo(100 / 150, 1e-9));
    expect(f.usedFraction, closeTo(50 / 150, 1e-9));
    expect(f.baseUsed, closeTo(50 / 150, 1e-9));
    expect(f.extraUsed, 0);
  });

  test('gauge moves fill into the hatched extra band once base is full', () {
    final f = quotaGaugeFractions(baseMb: 100, extraMb: 50, usedMb: 120);
    expect(f.baseUsed, closeTo(100 / 150, 1e-9));
    expect(f.extraUsed, closeTo(20 / 150, 1e-9));
    expect(f.usedFraction, closeTo(120 / 150, 1e-9));
  });

  test('gauge clamps used to the full span', () {
    final f = quotaGaugeFractions(baseMb: 100, extraMb: 50, usedMb: 500);
    expect(f.usedFraction, 1);
    expect(f.baseUsed, closeTo(100 / 150, 1e-9));
    expect(f.extraUsed, closeTo(50 / 150, 1e-9));
  });

  test('gauge degrades to empty fractions on a zero span', () {
    final f = quotaGaugeFractions(baseMb: 0, extraMb: 0, usedMb: 10);
    expect(f.span, 0);
    expect(f.baseFraction, 0);
    expect(f.usedFraction, 0);
    expect(f.baseUsed, 0);
    expect(f.extraUsed, 0);
  });
}
