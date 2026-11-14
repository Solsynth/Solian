import 'dart:async';
import 'dart:math' as math;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:island/discovery/models/autocomplete_response.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The server-backed `@` / `:` mention-and-sticker autocomplete for the
/// Solar editor, ported from the old Quill editor's overlay.
///
/// The host widget state owns one instance per editor and wires three
/// callbacks: [onFetchSuggestions] hits the autocomplete endpoint, [isEnabled]
/// reports whether the composer accepts input, and the [EditorState] comes
/// from the Solar controller. Call [onTransaction] from the editor's
/// transaction stream, [handleKey] from the editor's key handler, and
/// [dispose] when the widget unmounts.
///
/// Whenever the caret sits inside an `@query` or `:query` token (no
/// whitespace), it fetches suggestions and shows a popup anchored to the
/// caret rect. Selecting one replaces the whole token with
/// [AutocompleteSuggestion.keyword].
class BlockMentionAutocomplete {
  BlockMentionAutocomplete(
    this._context,
    this._editorState, {
    required Future<List<AutocompleteSuggestion>> Function(String query)
    onFetchSuggestions,
    required bool Function() isEnabled,
  }) : _fetch = onFetchSuggestions,
       _isEnabled = isEnabled;

  final BuildContext _context;
  final EditorState _editorState;
  final Future<List<AutocompleteSuggestion>> Function(String query) _fetch;
  final bool Function() _isEnabled;

  OverlayEntry? _entry;
  Timer? _debounce;
  int _generation = 0;
  Rect _caretRect = Rect.zero;

  List<AutocompleteSuggestion> _suggestions = const [];
  int _highlighted = 0;

  /// The plain-text token under the caret, including the trigger char, or
  /// null when no trigger is active. Mirrors the old Quill
  /// `triggerAtCaret`: the nearest `@` or `:` before the caret with no
  /// whitespace in between.
  ({int index, String token})? _triggerAtCaret() {
    final selection = _editorState.selection;
    if (selection == null || !selection.isCollapsed) return null;
    final node = _editorState.getNodeAtPath(selection.start.path);
    final delta = node?.delta;
    if (node == null || delta == null) return null;
    final plain = delta.toPlainText();
    final caret = selection.start.offset.clamp(0, plain.length);
    if (caret < 1) return null;
    final before = plain.substring(0, caret);
    final atIndex = before.lastIndexOf('@');
    final colonIndex = before.lastIndexOf(':');
    final triggerIndex = math.max(atIndex, colonIndex);
    if (triggerIndex == -1) return null;
    final token = before.substring(triggerIndex);
    if (token.contains(' ')) return null;
    return (index: triggerIndex, token: token);
  }

  /// The token spans from the trigger index to the first whitespace at or
  /// after the caret (the caret may sit mid-token after moving left).
  int _tokenEnd() {
    final selection = _editorState.selection!;
    final node = _editorState.getNodeAtPath(selection.start.path)!;
    final plain = node.delta!.toPlainText();
    var end = selection.start.offset;
    while (end < plain.length && plain[end] != ' ') {
      end++;
    }
    return end;
  }

  /// Replaces the active token with [suggestion.keyword] and closes.
  void _select(AutocompleteSuggestion suggestion) {
    final trigger = _triggerAtCaret();
    if (trigger == null) {
      close();
      return;
    }
    final selection = _editorState.selection!;
    final node = _editorState.getNodeAtPath(selection.start.path)!;
    final end = _tokenEnd();
    final transaction = _editorState.transaction
      ..replaceText(node, trigger.index, end - trigger.index, suggestion.keyword);
    _editorState.apply(transaction);
    close();
  }

  /// Call from the editor's transaction stream; schedules a debounced
  /// suggestion fetch for whatever token is now under the caret.
  void onTransaction() {
    if (!_isEnabled()) {
      close();
      return;
    }
    _debounce?.cancel();
    final trigger = _triggerAtCaret();
    if (trigger == null) {
      close();
      return;
    }
    final generation = ++_generation;
    final query = trigger.token;
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      List<AutocompleteSuggestion> result;
      try {
        result = await _fetch(query);
      } catch (_) {
        if (generation == _generation) close();
        return;
      }
      if (generation != _generation || _triggerAtCaret()?.token != query) {
        return;
      }
      if (result.isEmpty) {
        close();
        return;
      }
      _suggestions = result;
      _highlighted = 0;
      _show();
    });
  }

  void _show() {
    final selection = _editorState.selection;
    if (selection == null) return;
    final node = _editorState.getNodeAtPath(selection.start.path);
    final selectable = node?.selectable;
    final rect = selectable?.getCursorRectInPosition(
      selection.start,
      shiftWithBaseOffset: true,
    );
    final renderBox = node?.renderBox;
    if (rect == null || renderBox == null || !renderBox.attached) return;
    _caretRect = Rect.fromPoints(
      renderBox.localToGlobal(rect.topLeft),
      renderBox.localToGlobal(rect.bottomRight),
    );

    if (_entry == null) {
      _entry = OverlayEntry(builder: _buildPopup);
      Overlay.of(_context, rootOverlay: true).insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  Widget _buildPopup(BuildContext overlayContext) {
    final media = MediaQuery.of(overlayContext);
    final theme = Theme.of(overlayContext);
    const maxWidth = 360.0;
    const maxHeight = 260.0;
    const gap = 8.0;

    final width = math.min(maxWidth, media.size.width);
    final left = (_caretRect.left - 12)
        .clamp(0.0, math.max(0.0, media.size.width - width))
        .toDouble();
    final maxBottom = media.size.height - media.viewInsets.bottom;
    final belowSpace = maxBottom - _caretRect.bottom - gap;
    final top = belowSpace >= maxHeight
        ? _caretRect.bottom + gap
        : math.max(0.0, _caretRect.top - gap - maxHeight);

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surfaceContainerHigh,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: maxHeight),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return _MentionTile(
                suggestion: suggestion,
                selected: index == _highlighted,
                onTap: () => _select(suggestion),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Arrow / enter / escape navigation while the popup is open. Returns null
  /// when the popup is closed so the editor's own shortcuts run.
  KeyEventResult? handleKey(KeyEvent event) {
    if (_entry == null || _suggestions.isEmpty) return null;
    if (event is! KeyDownEvent) return null;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _highlighted = (_highlighted + 1) % _suggestions.length;
      _entry!.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _highlighted =
          (_highlighted - 1 + _suggestions.length) % _suggestions.length;
      _entry!.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _select(_suggestions[_highlighted.clamp(0, _suggestions.length - 1)]);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      close();
      return KeyEventResult.handled;
    }
    return null;
  }

  void close() {
    _debounce?.cancel();
    _debounce = null;
    _generation++;
    _entry?.remove();
    _entry = null;
    _suggestions = const [];
  }

  void dispose() {
    close();
  }
}

class _MentionTile extends StatelessWidget {
  final AutocompleteSuggestion suggestion;
  final bool selected;
  final VoidCallback onTap;

  const _MentionTile({
    required this.suggestion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'unknown'.tr();
    Widget leading = const Icon(Icons.help);
    switch (suggestion.type) {
      case 'user':
        final user = SnAccount.fromJson(suggestion.data);
        title = user.nick;
        leading = ProfilePictureWidget(
          file: user.profile.picture,
          fallbackName: user.nick,
          radius: 18,
        );
        break;
      case 'chatroom':
        final chatRoom = SnChatRoom.fromJson(suggestion.data);
        title = chatRoom.name ?? 'Chat Room';
        leading = ProfilePictureWidget(
          file: chatRoom.picture,
          fallbackName: chatRoom.name,
          radius: 18,
        );
        break;
      case 'realm':
        final realm = SnRealm.fromJson(suggestion.data);
        title = realm.name;
        leading = ProfilePictureWidget(
          file: realm.picture,
          fallbackName: realm.name,
          radius: 18,
        );
        break;
      case 'publisher':
        final publisher = SnPublisher.fromJson(suggestion.data);
        title = publisher.name;
        leading = ProfilePictureWidget(
          file: publisher.picture,
          fallbackName: publisher.nick,
          radius: 18,
        );
        break;
      case 'sticker':
        final sticker = SnSticker.fromJson(suggestion.data);
        title = sticker.name?.trim().isNotEmpty == true
            ? sticker.name!
            : sticker.slug;
        leading = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 28,
            height: 28,
            child: CloudImageWidget(file: sticker.image),
          ),
        );
        break;
      default:
    }
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(suggestion.keyword),
      dense: true,
      selected: selected,
      onTap: onTap,
    );
  }
}
