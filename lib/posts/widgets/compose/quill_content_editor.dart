import 'dart:math' as math;
import 'dart:async';

import 'dart:ui' show PointerDeviceKind;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/discovery_service.dart';
import 'package:island/discovery/models/autocomplete_response.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _kToolbarMouseIdleDuration = Duration(seconds: 2);
const _kToolbarAnimationDuration = Duration(milliseconds: 180);
const _kFloatingToolbarHeight = 44.0;
const _kFloatingToolbarMaxWidth = 520.0;

/// Gap between the toolbar and the caret (desktop) or the soft keyboard.
const _kToolbarCaretGap = 50.0;

/// Extra leftward shift so the pill's edge visually lines up with the caret
/// (the selection endpoint already includes the editor's text padding).
const _kToolbarLeftShift = 12.0;

const _kComposeToolbarConfig = QuillSimpleToolbarConfig(
  buttonOptions: QuillSimpleToolbarButtonOptions(
    base: QuillToolbarBaseButtonOptions(
      iconSize: 16,
      iconButtonFactor: 1.35,
    ),
  ),
  multiRowsDisplay: true,
  toolbarIconAlignment: WrapAlignment.start,
  showFontFamily: false,
  showFontSize: false,
  showBoldButton: true,
  showItalicButton: true,
  showUnderLineButton: true,
  showStrikeThrough: true,
  showInlineCode: false,
  showColorButton: false,
  showBackgroundColorButton: false,
  showClearFormat: false,
  showAlignmentButtons: false,
  showHeaderStyle: true,
  showListNumbers: true,
  showListBullets: true,
  showListCheck: false,
  showCodeBlock: true,
  showQuote: true,
  showIndent: false,
  showLink: true,
  showUndo: false,
  showRedo: false,
  showDirection: false,
  showSearchButton: false,
  showSubscript: false,
  showSuperscript: false,
);

/// WYSIWYG content editor for compose screens.
///
/// Renders [ComposeState.contentQuillController] with a selection-following
/// formatting toolbar and the server-backed `@`/`:` mention autocomplete.
/// On desktop the toolbar appears after recent mouse movement; on touch
/// platforms it appears above the keyboard while the editor is focused.
class QuillContentEditor extends HookConsumerWidget {
  final ComposeState state;
  final bool enabled;
  final bool expands;
  final double? minHeight;
  final EdgeInsetsGeometry padding;
  final bool showToolbar;

  const QuillContentEditor({
    super.key,
    required this.state,
    this.enabled = true,
    this.expands = false,
    this.minHeight,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.showToolbar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quill = state.contentQuillController;
    quill.readOnly = !enabled;

    // Root the editor's text (and therefore caret and placeholder metrics) in
    // the compose body style instead of flutter_quill's 16px/1.15 defaults.
    final theme = Theme.of(context);
    final bodyStyle =
        theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    const horizontalSpacing = HorizontalSpacing(0, 0);
    final noVertical = VerticalSpacing.zero;
    DefaultTextBlockStyle block(TextStyle style) => DefaultTextBlockStyle(
      style,
      horizontalSpacing,
      noVertical,
      noVertical,
      null,
    );
    final editorStyles = DefaultStyles.getInstance(context).merge(
      DefaultStyles(
        paragraph: block(bodyStyle),
        leading: block(bodyStyle),
        align: block(bodyStyle),
        lineHeightNormal: block(bodyStyle.copyWith(height: 1.15)),
        lineHeightTight: block(bodyStyle.copyWith(height: 1.30)),
        lineHeightOneAndHalf: block(bodyStyle.copyWith(height: 1.55)),
        lineHeightDouble: block(bodyStyle.copyWith(height: 2)),
        placeHolder: block(
          bodyStyle.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );

    final focusNode = useMemoized(() => FocusNode(), []);
    final scrollController = useMemoized(() => ScrollController(), []);
    final layerLink = useMemoized(() => LayerLink(), []);

    final overlayEntry = useRef<OverlayEntry?>(null);
    final suggestions = useRef<List<AutocompleteSuggestion>>(const []);
    final highlighted = useRef(0);
    final fetchTimer = useRef<Timer?>(null);
    final fetchGeneration = useRef(0);
    final editorWidth = useRef(0.0);

    final editorKey = useMemoized(() => GlobalKey<QuillEditorState>(), []);
    final editableTextKey = useMemoized(() => GlobalKey<EditorState>(), []);
    final toolbarEntry = useRef<OverlayEntry?>(null);
    final toolbarMouseTimer = useRef<Timer?>(null);
    final toolbarMouseActive = useRef(false);
    final toolbarRemovalTimer = useRef<Timer?>(null);
    final toolbarVisible = useRef(false);
    final mediaQuery = MediaQuery.of(context);
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;
    final isTouchPlatform = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
    late void Function(PointerEvent event) onToolbarPointerMove;

    void hideFloatingToolbar({bool immediate = false}) {
      toolbarMouseTimer.value?.cancel();
      toolbarMouseTimer.value = null;
      toolbarRemovalTimer.value?.cancel();
      final entry = toolbarEntry.value;
      if (entry == null) return;
      if (immediate) {
        // Called during unmount while the framework is locked; markNeedsBuild
        // on the entry widget would throw. OverlayEntry.remove() defers its
        // own rebuild to a post-frame callback, so it is safe here.
        toolbarEntry.value = null;
        entry.remove();
        return;
      }
      toolbarVisible.value = false;
      entry.markNeedsBuild();
      toolbarRemovalTimer.value = Timer(_kToolbarAnimationDuration, () {
        if (!toolbarVisible.value) {
          toolbarEntry.value = null;
          entry.remove();
        }
      });
    }

    void updateFloatingToolbar() {
      final shouldShow = showToolbar && enabled &&
          (isTouchPlatform
              ? keyboardVisible && focusNode.hasFocus
              : toolbarMouseActive.value);
      if (!shouldShow) {
        hideFloatingToolbar();
        return;
      }
      if (toolbarEntry.value == null) {
        toolbarVisible.value = true;
        toolbarEntry.value = OverlayEntry(
          builder: (overlayContext) => _FloatingToolbar(
            editorKey: editorKey,
            controller: quill,
            screenSize: mediaQuery.size,
            keyboardInset: mediaQuery.viewInsets.bottom,
            isTouchPlatform: isTouchPlatform,
            visible: toolbarVisible.value,
            onPointerMove: onToolbarPointerMove,
          ),
        );
        Overlay.of(context).insert(toolbarEntry.value!);
      } else {
        toolbarVisible.value = true;
        toolbarRemovalTimer.value?.cancel();
        toolbarEntry.value!.markNeedsBuild();
      }

    }
    onToolbarPointerMove = (event) {
      if (isTouchPlatform || event.kind != PointerDeviceKind.mouse) return;
      toolbarMouseActive.value = true;
      toolbarMouseTimer.value?.cancel();
      updateFloatingToolbar();
      toolbarMouseTimer.value = Timer(_kToolbarMouseIdleDuration, () {
        toolbarMouseActive.value = false;
        updateFloatingToolbar();
      });
    };
    void closeOverlay() {
      fetchTimer.value?.cancel();
      fetchTimer.value = null;
      fetchGeneration.value++;
      overlayEntry.value?.remove();
      overlayEntry.value = null;
    }

    /// Detects an active `@`/`:` mention trigger at the caret. Returns the
    /// trigger index (delta offset) and the query including the trigger char.
    ({int index, String chopped})? triggerAtCaret() {
      final selection = quill.selection;
      if (!selection.isValid) return null;
      final plain = quill.document.toPlainText();
      final caret = selection.end.clamp(0, plain.length);
      if (caret < 1) return null;
      final before = plain.substring(0, caret);
      final atIndex = before.lastIndexOf('@');
      final colonIndex = before.lastIndexOf(':');
      final triggerIndex = atIndex > colonIndex ? atIndex : colonIndex;
      if (triggerIndex == -1) return null;
      final chopped = before.substring(triggerIndex);
      if (chopped.contains(' ')) return null;
      return (index: triggerIndex, chopped: chopped);
    }

    void selectSuggestion(AutocompleteSuggestion suggestion) {
      final trigger = triggerAtCaret();
      if (trigger == null) {
        closeOverlay();
        return;
      }
      final selection = quill.selection;
      final start = trigger.index;
      final end = selection.isValid ? selection.end : quill.document.length;
      quill.replaceText(
        start,
        end - start,
        suggestion.keyword,
        TextSelection.collapsed(offset: start + suggestion.keyword.length),
      );
      closeOverlay();
    }

    void onQuillChanged() {
      if (!enabled || !focusNode.hasFocus) {
        closeOverlay();
        return;
      }
      fetchTimer.value?.cancel();
      final trigger = triggerAtCaret();
      if (trigger == null) {
        closeOverlay();
        return;
      }
      final generation = ++fetchGeneration.value;
      final chopped = trigger.chopped;
      fetchTimer.value = Timer(
        const Duration(milliseconds: 1000),
        () async {
          if (generation != fetchGeneration.value) return;
          List<AutocompleteSuggestion> result;
          try {
            result = await ref
                .read(autocompleteServiceProvider)
                .getGeneralSuggestions(chopped);
          } catch (_) {
            if (generation == fetchGeneration.value) closeOverlay();
            return;
          }
          if (generation != fetchGeneration.value) return;
          suggestions.value = result;
          highlighted.value = 0;
          if (result.isEmpty) {
            closeOverlay();
            return;
          }
          if (overlayEntry.value == null) {
            if (!context.mounted) return;
            overlayEntry.value = OverlayEntry(
              builder: (overlayContext) => _MentionsPopup(
                link: layerLink,
                width: editorWidth.value,
                suggestions: suggestions.value,
                highlighted: highlighted.value,
                onSelect: selectSuggestion,
              ),
            );
            Overlay.of(context).insert(overlayEntry.value!);
          } else {
            overlayEntry.value!.markNeedsBuild();
          }
        },
      );
    }

    // Desktop-only: arrow keys move the highlighted suggestion, Enter picks
    // it. On mobile the mention list is tapped directly.
    KeyEventResult? onKeyPressed(KeyEvent event, Node? node) {
      if (overlayEntry.value == null) return null;
      if (event is! KeyDownEvent) return null;
      final list = suggestions.value;
      if (list.isEmpty) return null;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        highlighted.value = (highlighted.value + 1) % list.length;
        overlayEntry.value?.markNeedsBuild();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        highlighted.value =
            (highlighted.value - 1 + list.length) % list.length;
        overlayEntry.value?.markNeedsBuild();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        selectSuggestion(list[highlighted.value.clamp(0, list.length - 1)]);
        return KeyEventResult.handled;
      }
      return null;
    }

    // Keep toolbar placement current as caret, focus, keyboard, or enablement
    // changes. Pointer activity is handled separately by the editor listener.
    useEffect(() {
      void onFocusChanged() {
        if (!focusNode.hasFocus) closeOverlay();
        updateFloatingToolbar();
      }

      void onControllerChanged() {
        onQuillChanged();
        updateFloatingToolbar();
      }

      quill.addListener(onControllerChanged);
      focusNode.addListener(onFocusChanged);
      updateFloatingToolbar();
      return () {
        quill.removeListener(onControllerChanged);
        focusNode.removeListener(onFocusChanged);
        closeOverlay();
        hideFloatingToolbar(immediate: true);
      };
    }, [quill, focusNode, enabled, keyboardVisible, showToolbar]);

    useEffect(() {
      return () {
        toolbarMouseTimer.value?.cancel();
        toolbarRemovalTimer.value?.cancel();
        hideFloatingToolbar(immediate: true);
        focusNode.dispose();
        scrollController.dispose();
      };
    }, []);

    return MouseRegion(
      onHover: onToolbarPointerMove,
      child: LayoutBuilder(
        builder: (context, constraints) {
          editorWidth.value = constraints.maxWidth;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuillEditor(
                key: editorKey,
                controller: quill,
                focusNode: focusNode,
                scrollController: scrollController,
                config: QuillEditorConfig(
                  placeholder: 'postContent'.tr(),
                  customStyles: editorStyles,
                  expands: expands,
                  minHeight: expands ? minHeight : (minHeight ?? 120),
                  padding: padding,
                  autoFocus: false,
                  enableInteractiveSelection: true,
                  onTapOutside: (event, _) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  embedBuilders: [
                    _SolianImageEmbedBuilder(state),
                    const _HorizontalRuleEmbedBuilder(),
                  ],
                  unknownEmbedBuilder: const _UnknownEmbedBuilder(),
                  editorKey: editableTextKey,
                  // ignore: experimental_member_use
                  onKeyPressed: onKeyPressed,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              // Zero-size anchor right below the editor for mention results.
              CompositedTransformTarget(
                link: layerLink,
                child: const SizedBox(width: double.infinity, height: 0),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FloatingToolbar extends StatefulWidget {
  final GlobalKey<QuillEditorState> editorKey;
  final QuillController controller;
  final Size screenSize;
  final double keyboardInset;
  final bool isTouchPlatform;
  final bool visible;
  final ValueChanged<PointerEvent> onPointerMove;

  const _FloatingToolbar({
    required this.editorKey,
    required this.controller,
    required this.screenSize,
    required this.keyboardInset,
    required this.isTouchPlatform,
    required this.visible,
    required this.onPointerMove,
  });

  @override
  State<_FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<_FloatingToolbar> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.visible) setState(() => _visible = true);
    });
  }

  @override
  void didUpdateWidget(covariant _FloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      setState(() => _visible = widget.visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final renderEditor = widget.editorKey.currentState?.editableTextKey
        .currentState?.renderEditor;
    if (renderEditor == null || !renderEditor.hasSize) {
      return const SizedBox.shrink();
    }

    final selection = widget.controller.selection;
    if (!selection.isValid) return const SizedBox.shrink();
    final endpoints = renderEditor.getEndpointsForSelection(selection);
    if (endpoints.isEmpty) return const SizedBox.shrink();
    // Anchor to the selection end: the point sits at the caret bottom.
    final globalCaret = renderEditor.localToGlobal(endpoints.last.point);
    final maxLeft = math.max(0.0, widget.screenSize.width - _kFloatingToolbarMaxWidth);
    final left = (globalCaret.dx - _kToolbarLeftShift)
        .clamp(0.0, maxLeft)
        .toDouble();
    final maxTop = math.max(
      0.0,
      widget.screenSize.height -
          widget.keyboardInset -
          _kFloatingToolbarHeight -
          _kToolbarCaretGap,
    );
    final aboveTop = globalCaret.dy - _kFloatingToolbarHeight - _kToolbarCaretGap;
    final belowTop = globalCaret.dy + _kToolbarCaretGap;
    final toolbarTop = widget.isTouchPlatform
        ? maxTop
        : (aboveTop >= 0 ? aboveTop : belowTop).clamp(0.0, maxTop).toDouble();

    return AnimatedPositioned(
      duration: _kToolbarAnimationDuration,
      curve: Curves.easeOutCubic,
      left: left,
      top: toolbarTop,
      width: math.min(widget.screenSize.width, _kFloatingToolbarMaxWidth),
      height: _kFloatingToolbarHeight,
      child: IgnorePointer(
        ignoring: !_visible,
        child: AnimatedOpacity(
          duration: _kToolbarAnimationDuration,
          curve: Curves.easeOut,
          opacity: _visible ? 1 : 0,
          child: AnimatedSlide(
            duration: _kToolbarAnimationDuration,
            curve: Curves.easeOutCubic,
            offset: _visible ? Offset.zero : const Offset(0, 0.15),
            child: TextFieldTapRegion(
              child: MouseRegion(
                onHover: widget.onPointerMove,
                child: Material(
                  key: const ValueKey('compose-floating-toolbar'),
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: QuillSimpleToolbar(
                      controller: widget.controller,
                      config: _kComposeToolbarConfig,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mention suggestion popup anchored below the editor.
class _MentionsPopup extends StatelessWidget {
  final LayerLink link;
  final double width;
  final List<AutocompleteSuggestion> suggestions;
  final int highlighted;
  final ValueChanged<AutocompleteSuggestion> onSelect;

  const _MentionsPopup({
    required this.link,
    required this.width,
    required this.suggestions,
    required this.highlighted,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CompositedTransformFollower(
      link: link,
      showWhenUnlinked: false,
      offset: const Offset(0, 4),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surfaceContainerHigh,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 260, maxWidth: width),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _MentionTile(
                suggestion: suggestion,
                selected: index == highlighted,
                onTap: () => onSelect(suggestion),
              );
            },
          ),
        ),
      ),
    );
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
    Widget leading = Icon(Icons.help);
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

/// Renders `![...](solian://files/<id>)` image embeds with the app's cloud
/// file widget (attachments are resolved by id, falling back to a network
/// lookup). Other image sources fall back to a plain network image.
class _SolianImageEmbedBuilder extends EmbedBuilder {
  const _SolianImageEmbedBuilder(this.state);

  final ComposeState state;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final source = embedContext.node.value.data as String? ?? '';
    final uri = Uri.tryParse(source);
    if (uri != null &&
        uri.scheme == 'solian' &&
        uri.host == 'files' &&
        uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      for (final attachment in state.attachments.value) {
        if (!attachment.isOnCloud) continue;
        final cloudFile = attachment.data as IDisplayableCloudFile;
        if (cloudFile.id == id) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CloudFileWidget(item: cloudFile, fit: BoxFit.cover),
          );
        }
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CloudImageWidget(fileId: id, fit: BoxFit.cover),
      );
    }
    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
    );
  }
}

class _HorizontalRuleEmbedBuilder extends EmbedBuilder {
  const _HorizontalRuleEmbedBuilder();

  @override
  String get key => 'divider';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1),
      );
}

class _UnknownEmbedBuilder extends EmbedBuilder {
  const _UnknownEmbedBuilder();

  @override
  String get key => 'unknown';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final theme = Theme.of(context);
    return Container(
      height: 24,
      alignment: Alignment.centerLeft,
      child: Icon(
        Icons.help_outline,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
