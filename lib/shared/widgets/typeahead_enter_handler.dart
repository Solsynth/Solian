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
        SingleActivator(LogicalKeyboardKey.arrowUp):
            _TypeAheadPreviousSuggestionIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            _TypeAheadNextSuggestionIntent(),
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
          _TypeAheadPreviousSuggestionIntent:
              _TypeAheadPreviousSuggestionAction<T>(suggestionsController),
          _TypeAheadNextSuggestionIntent: _TypeAheadNextSuggestionAction<T>(
            suggestionsController,
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

class _TypeAheadPreviousSuggestionIntent extends Intent {
  const _TypeAheadPreviousSuggestionIntent();
}

class _TypeAheadNextSuggestionIntent extends Intent {
  const _TypeAheadNextSuggestionIntent();
}

class _TypeAheadPreviousSuggestionAction<T>
    extends CallbackAction<_TypeAheadPreviousSuggestionIntent> {
  _TypeAheadPreviousSuggestionAction(this.suggestionsController)
    : super(
        onInvoke: (_) {
          suggestionsController.highlightPrevious();
          return null;
        },
      );

  final SuggestionsController<T> suggestionsController;

  @override
  bool isEnabled(covariant _TypeAheadPreviousSuggestionIntent intent) =>
      suggestionsController.isOpen;

  @override
  bool consumesKey(covariant _TypeAheadPreviousSuggestionIntent intent) =>
      suggestionsController.isOpen;
}

class _TypeAheadNextSuggestionAction<T>
    extends CallbackAction<_TypeAheadNextSuggestionIntent> {
  _TypeAheadNextSuggestionAction(this.suggestionsController)
    : super(
        onInvoke: (_) {
          suggestionsController.highlightNext();
          return null;
        },
      );

  final SuggestionsController<T> suggestionsController;

  @override
  bool isEnabled(covariant _TypeAheadNextSuggestionIntent intent) =>
      suggestionsController.isOpen;

  @override
  bool consumesKey(covariant _TypeAheadNextSuggestionIntent intent) =>
      suggestionsController.isOpen;
}
