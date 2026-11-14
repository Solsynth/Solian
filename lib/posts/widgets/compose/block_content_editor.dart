import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

import 'package:island/discovery/discovery_service.dart';
import 'package:island/posts/widgets/compose/block_mention_autocomplete.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';

/// The Solian compose content editor: the shared [SolarBlockEditor]
/// (AppFlowy-based, Notion-like) over the markdown-backed
/// [ComposeState.contentController].
///
/// Edits flow editor → [SolarEditorController.onChange] → markdown →
/// `contentController`; external writes (draft restore, attachment
/// placeholders, imports) flow back through
/// [ComposeState.syncContentFromTextController].
class BlockContentEditor extends ConsumerStatefulWidget {
  const BlockContentEditor({
    super.key,
    required this.state,
    required this.enabled,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.shrinkWrap = true,
  });

  final ComposeState state;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  /// Render inside the host scrollable (compose cards). Article pages that
  /// want editor-internal scrolling can pass false.
  final bool shrinkWrap;

  @override
  ConsumerState<BlockContentEditor> createState() => _BlockContentEditorState();
}

class _BlockContentEditorState extends ConsumerState<BlockContentEditor> {
  BlockMentionAutocomplete? _autocomplete;
  StreamSubscription? _transactionSub;

  @override
  void initState() {
    super.initState();
    widget.state.editorLoaded.addListener(_onEditorLoaded);
    // The composer may have built its editor before this widget mounted.
    _onEditorLoaded();
  }

  void _onEditorLoaded() {
    if (!mounted) return;
    final controller = widget.state.solarEditorController;
    if (controller == null || _autocomplete != null) return;
    _autocomplete = BlockMentionAutocomplete(
      context,
      controller.editorState,
      onFetchSuggestions: (query) =>
          ref.read(autocompleteServiceProvider).getGeneralSuggestions(query),
      isEnabled: () => widget.enabled,
    );
    _transactionSub = controller.editorState.transactionStream.listen(
      (_) => _autocomplete!.onTransaction(),
    );
  }

  @override
  void dispose() {
    widget.state.editorLoaded.removeListener(_onEditorLoaded);
    _transactionSub?.cancel();
    _autocomplete?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Host flows (the cloud image picker sheet) need a context; keep the
    // state's reference current on every build.
    widget.state.editorContext = context;
    final controller = widget.state.solarEditorController;
    if (controller == null) {
      return const SizedBox(height: 48);
    }

    final editor = SolarBlockEditor(
      controller: controller,
      editable: widget.enabled,
      shrinkWrap: widget.shrinkWrap,
      // Route keys through the mention popup first: while it is open,
      // arrows/enter/escape navigate it instead of the document.
      onKeyEvent: (event) => _autocomplete?.handleKey(event),
    );

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.hasBoundedHeight) {
            return editor;
          }
          // The editor hosts an internal Overlay that requires finite
          // constraints. Inside a host scrollable (compose form/card) the
          // height is unbounded, so give the editor a generous fixed height
          // and let it scroll internally; the host can still scroll to it.
          return SizedBox(height: 480, child: editor);
        },
      ),
    );
  }
}

/// Solian's editor theme hooks, shared by every host surface.
SolarEditorConfig solianEditorConfig() {
  return const SolarEditorConfig();
}

/// Solian's inline styling for Solar-specific attributes (mention,
/// highlight, spoiler, sticker) — mirrored in the editor bridge.
TextStyle? solianSolarSpanStyle(
  BuildContext context,
  TextStyle base,
  Map<String, dynamic> attributes,
) {
  final theme = Theme.of(context);
  if (attributes[SolarInlineKeys.highlight] == true) {
    return base.copyWith(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
    );
  }
  if (attributes[SolarInlineKeys.spoiler] == true) {
    return base.copyWith(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      color: Colors.transparent,
    );
  }
  if (attributes[SolarInlineKeys.mention] is String ||
      attributes[SolarInlineKeys.sticker] is String) {
    return base.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w500,
    );
  }
  return null;
}

