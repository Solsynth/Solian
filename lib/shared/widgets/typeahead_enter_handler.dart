import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TypeAheadEnterHandler<T> extends StatelessWidget {
  final SuggestionsController<T> suggestionsController;
  final VoidCallback onEnter;
  final Widget child;

  const TypeAheadEnterHandler({
    super.key,
    required this.suggestionsController,
    required this.onEnter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): _TypeAheadEnterIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter):
            _TypeAheadEnterIntent(),
      },
      child: Actions(
        actions: {
          _TypeAheadEnterIntent: CallbackAction<_TypeAheadEnterIntent>(
            onInvoke: (_) {
              final highlightedSuggestion =
                  suggestionsController.highlightedSuggestion;
              if (suggestionsController.isOpen &&
                  highlightedSuggestion != null) {
                suggestionsController.select(highlightedSuggestion);
                suggestionsController.unhighlight();
                return null;
              }

              onEnter();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _TypeAheadEnterIntent extends Intent {
  const _TypeAheadEnterIntent();
}
