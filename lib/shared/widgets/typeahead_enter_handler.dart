import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TypeAheadEnterHandler<T> extends StatelessWidget {
  final SuggestionsController<T> suggestionsController;
  final TextEditingController controller;
  final VoidCallback onEnter;
  final Widget child;

  const TypeAheadEnterHandler({
    super.key,
    required this.suggestionsController,
    required this.controller,
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
              _TypeAheadPreviousSuggestionAction<T>(
                suggestionsController,
                controller,
              ),
          _TypeAheadNextSuggestionIntent: _TypeAheadNextSuggestionAction<T>(
            suggestionsController,
            controller,
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
  _TypeAheadPreviousSuggestionAction(
    this.suggestionsController,
    this.controller,
  ) : super(
        onInvoke: (_) {
          if (_hasSuggestions(suggestionsController)) {
            suggestionsController.highlightPrevious();
          } else {
            _moveCaretToAdjacentLine(controller, forward: false);
          }
          return null;
        },
      );

  final SuggestionsController<T> suggestionsController;
  final TextEditingController controller;

  @override
  bool isEnabled(covariant _TypeAheadPreviousSuggestionIntent intent) =>
      suggestionsController.isOpen;

  @override
  bool consumesKey(covariant _TypeAheadPreviousSuggestionIntent intent) =>
      suggestionsController.isOpen;
}

class _TypeAheadNextSuggestionAction<T>
    extends CallbackAction<_TypeAheadNextSuggestionIntent> {
  _TypeAheadNextSuggestionAction(this.suggestionsController, this.controller)
    : super(
        onInvoke: (_) {
          if (_hasSuggestions(suggestionsController)) {
            suggestionsController.highlightNext();
          } else {
            _moveCaretToAdjacentLine(controller, forward: true);
          }
          return null;
        },
      );

  final SuggestionsController<T> suggestionsController;
  final TextEditingController controller;

  @override
  bool isEnabled(covariant _TypeAheadNextSuggestionIntent intent) =>
      suggestionsController.isOpen;

  @override
  bool consumesKey(covariant _TypeAheadNextSuggestionIntent intent) =>
      suggestionsController.isOpen;
}

bool _hasSuggestions<T>(SuggestionsController<T> controller) =>
    controller.isOpen && (controller.suggestions?.isNotEmpty ?? false);

void _moveCaretToAdjacentLine(
  TextEditingController controller, {
  required bool forward,
}) {
  final text = controller.text;
  final selection = controller.selection;
  if (!selection.isValid) return;

  final offset = selection.extentOffset.clamp(0, text.length);
  final currentLineStart = text.lastIndexOf('\n', offset - 1) + 1;
  final currentLineEnd = text.indexOf('\n', offset);
  final currentLineLimit = currentLineEnd == -1 ? text.length : currentLineEnd;
  final column = offset - currentLineStart;

  int? target;
  if (forward) {
    if (currentLineLimit < text.length) {
      final nextLineStart = currentLineLimit + 1;
      final nextLineEnd = text.indexOf('\n', nextLineStart);
      final nextLineLimit = nextLineEnd == -1 ? text.length : nextLineEnd;
      target = (nextLineStart + column).clamp(nextLineStart, nextLineLimit);
    }
  } else if (currentLineStart > 0) {
    final previousLineLimit = currentLineStart - 1;
    final previousLineStart = text.lastIndexOf('\n', previousLineLimit - 1) + 1;
    target = (previousLineStart + column).clamp(
      previousLineStart,
      previousLineLimit,
    );
  }

  if (target != null) {
    controller.selection = TextSelection.collapsed(offset: target);
  }
}
