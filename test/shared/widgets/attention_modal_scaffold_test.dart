import 'package:flutter_test/flutter_test.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('fills the bottom edge in narrow mode', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 832));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 832),
            padding: EdgeInsets.only(bottom: 24),
          ),
          child: AttentionModalScaffold(
            showHeader: false,
            onDismiss: _noop,
            child: const SizedBox.expand(key: ValueKey('modal-content')),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('modal-content'))),
      const Size(400, 776),
    );

    expect(
      tester.getSize(find.byType(AttentionModalScaffold)),
      const Size(400, 832),
    );
  });
}

void _noop() {}
