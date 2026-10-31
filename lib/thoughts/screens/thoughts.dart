import 'dart:convert';
import 'dart:io' show File;

import 'package:auto_route/auto_route.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/auth/login_modal.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/glass_effects.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/measure_height.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/thoughts_controller.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Thoughts: a live conversation with a personality agent, with the account's
/// other threads in a responsive sidebar.
///
/// Moved here from the app that used to host it: the tab keeps the thread log
/// (user turns, streamed replies, reasoning and tool traces) and the run
/// controls it always had.
@RoutePage()
class ThoughtsScreen extends HookConsumerWidget {
  const ThoughtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chat = ref.watch(thoughtsControllerProvider);
    final controller = ref.read(thoughtsControllerProvider.notifier);
    final token = ref.watch(tokenProvider);
    final agents =
        ref.watch(personalityAgentsProvider).value ??
        const <SnPersonalityAgent>[];

    final inputController = useTextEditingController();
    final focusNode = useFocusNode();
    final wideScreen = MediaQuery.sizeOf(context).width > kWideScreenWidth;
    // An open panel when wide, an on-demand sheet when narrow.
    final showThreads = useState(wideScreen);
    final composerHeight = useState(0.0);

    final agentId = chat.agentId ?? (agents.isEmpty ? null : agents.first.id);
    final agentName = _agentLabel(agents, agentId);

    void send() {
      if (chat.busy || chat.attachmentsUploading) return;
      final text = inputController.text;
      if (text.trim().isEmpty && chat.pendingAttachments.isEmpty) return;
      inputController.clear();
      focusNode.requestFocus();
      controller.send(text);
    }

    Future<void> attach() async {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      await controller.attachImages([
        for (final file in files)
          if (file.xFile.path.isNotEmpty)
            UniversalFile(
              data: file.xFile,
              type: UniversalFileType.image,
              displayName: file.name,
            ),
      ]);
    }

    Future<void> attachFiles(List<UniversalFile> files) async {
      await controller.attachImages(files);
    }

    Future<void> linkCloudFile() async {
      final picked = await showModalBottomSheet<SnCloudFile>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => const _CloudFilePickerSheet(),
      );
      if (picked == null) return;
      controller.linkCloudFile(fileId: picked.id, name: picked.name);
    }

    void openThreads() {
      if (wideScreen) {
        showThreads.value = !showThreads.value;
        return;
      }
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => SheetScaffold(
          titleText: 'conversations'.tr(),
          onClose: () => Navigator.of(sheetContext).pop(),
          child: _ThreadList(
            activeId: chat.conversationId,
            onSelect: (id) {
              Navigator.of(sheetContext).pop();
              controller.openConversation(id);
            },
          ),
        ),
      );
    }

    final thread = chat.bubbles.isEmpty
        ? Padding(
            padding: EdgeInsets.only(
              bottom: composerHeight.value > 0 ? composerHeight.value : 80.0,
            ),
            child: EmptyState(
              icon: Symbols.psychology_rounded,
              title: 'thoughtsStartTitle'.tr(),
              description: 'thoughtsStartHint'.tr(
                namedArgs: {'name': agentName},
              ),
            ),
          )
        : _ThoughtThread(
            bubbles: chat.bubbles,
            busy: chat.busy,
            onToggleTrace: controller.toggleTrace,
            bottomInset: composerHeight.value,
          );

    // The pill floats over the page; the scaffold reserves its band, so the
    // body starts below it and both panes share the rest. The composer floats
    // over the thread in liquid glass, with the messages scrolling behind it.
    final mainContent = token == null
        ? const _SignedOutPanel()
        : Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    if (chat.error != null)
                      _ErrorBanner(
                        message: chat.error!,
                        onDismiss: controller.dismissError,
                      ),
                    Expanded(child: thread),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MeasureHeight(
                  onHeight: (height) => composerHeight.value = height,
                  child: _Composer(
                    controller: inputController,
                    focusNode: focusNode,
                    attachments: chat.pendingAttachments,
                    busy: chat.busy,
                    usage: chat.conversationUsage,
                    onSend: send,
                    onStop: controller.stop,
                    onAttach: attach,
                    onAttachFiles: attachFiles,
                    onLinkCloudFile: linkCloudFile,
                    onRemoveAttachment: chat.busy
                        ? null
                        : controller.removePendingAttachment,
                    onRetryAttachment: chat.busy
                        ? null
                        : controller.retryAttachment,
                  ),
                ),
              ),
            ],
          );

    return AppScaffold(
      extendBody: true,
      body: wideScreen
          ? ResponsiveSidebar(
              sidebarBackgroundColor: Colors.transparent,
              sidebarElevation: 0,
              showSidebar: showThreads,
              sidebarWidth: 320,
              minWideSidebarWidth: 260,
              maxWideSidebarWidth: 400,
              minMainContentWidth: 360,
              mainContent: mainContent,
              sidebarContent: _ThreadList(
                activeId: chat.conversationId,
                onSelect: controller.openConversation,
              ),
            )
          : mainContent,
      appBar: PillAppBar(
        statusTop: MediaQuery.paddingOf(context).top,
        child: Row(
          children: [
            const SolDrawerButton(),
            const Gap(SolSpace.sm),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'thoughts',
                  style: theme.appBarTheme.titleTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).tr(),
              ),
            ),
            if (token != null) ...[
              IconButton(
                tooltip: 'conversations'.tr(),
                onPressed: openThreads,
                icon: Icon(
                  Symbols.forum_rounded,
                  fill: wideScreen && showThreads.value ? 1 : null,
                ),
              ),
              IconButton(
                tooltip: 'newConversation'.tr(),
                onPressed: chat.busy ? null : controller.newConversation,
                icon: const Icon(Symbols.edit_square_rounded),
              ),
            ],
            const Gap(SolSpace.xs),
          ],
        ),
      ),
    );
  }
}

String _agentLabel(List<SnPersonalityAgent> agents, String? agentId) {
  if (agentId == null) return 'thoughts'.tr();
  for (final agent in agents) {
    if (agent.id != agentId) continue;
    final name = agent.name.trim();
    return name.isEmpty ? 'thoughts'.tr() : name;
  }
  return 'thoughts'.tr();
}

/// What stands in the page's place with no session: the sign-in, and nothing
/// that could send a message without one.
class _SignedOutPanel extends StatelessWidget {
  const _SignedOutPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SolSpace.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Symbols.lock_rounded,
                size: 44,
                color: scheme.onSurfaceVariant,
              ),
              const Gap(SolSpace.md),
              Text(
                'unauthorized'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const Gap(SolSpace.xs),
              Text(
                'unauthorizedHint'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(SolSpace.lg),
              FilledButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (_) => const LoginModal(),
                  );
                },
                icon: const Icon(Symbols.login_rounded, size: 20),
                label: Text('login').tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SolSpace.md,
        SolSpace.sm,
        SolSpace.md,
        0,
      ),
      child: Material(
        color: scheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SolRadius.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: SolSpace.md, right: SolSpace.xs),
          child: Row(
            children: [
              Icon(
                Symbols.error_rounded,
                size: 18,
                color: scheme.onErrorContainer,
              ),
              const Gap(SolSpace.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SolSpace.sm),
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'close'.tr(),
                iconSize: 16,
                onPressed: onDismiss,
                icon: Icon(
                  Symbols.close_rounded,
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The log, newest row at the bottom edge so a growing streamed reply stays in
/// view without fighting the reader's scroll position.
class _ThoughtThread extends StatelessWidget {
  const _ThoughtThread({
    required this.bubbles,
    required this.busy,
    required this.onToggleTrace,
    this.bottomInset = 0.0,
  });

  final List<ThoughtBubble> bubbles;
  final bool busy;
  final void Function(int index) onToggleTrace;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.fromLTRB(
        SolSpace.md,
        SolSpace.lg,
        SolSpace.md,
        bottomInset > 0 ? bottomInset + SolSpace.xs : SolSpace.sm,
      ),
      itemCount: bubbles.length + (busy ? 1 : 0),
      itemBuilder: (context, index) {
        final Widget row;
        if (busy && index == 0) {
          row = const _TurnIndicator();
        } else {
          final bubbleIndex = bubbles.length - 1 - (busy ? index - 1 : index);
          row = _BubbleRow(
            bubble: bubbles[bubbleIndex],
            onToggleTrace: () => onToggleTrace(bubbleIndex),
          );
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: row,
          ),
        );
      },
    );
  }
}

class _BubbleRow extends StatelessWidget {
  const _BubbleRow({required this.bubble, required this.onToggleTrace});

  final ThoughtBubble bubble;
  final VoidCallback onToggleTrace;

  @override
  Widget build(BuildContext context) {
    switch (bubble.kind) {
      case ThoughtBubbleKind.user:
        return _UserBubble(bubble: bubble);
      case ThoughtBubbleKind.assistant:
        return _AssistantBubble(bubble: bubble);
      case ThoughtBubbleKind.thinking:
        return _TraceRow(bubble: bubble, onToggle: onToggleTrace);
      case ThoughtBubbleKind.tool:
        return _ToolTraceRow(bubble: bubble, onToggle: onToggleTrace);
    }
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.bubble});

  static const double _imageSize = 96;

  final ThoughtBubble bubble;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SolSpace.xs),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Material(
            color: scheme.primaryContainer.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SolRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SolSpace.md,
                vertical: SolSpace.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bubble.attachments.isNotEmpty)
                    Wrap(
                      spacing: SolSpace.sm,
                      runSpacing: SolSpace.sm,
                      children: [
                        for (final attachment in bubble.attachments)
                          SizedBox.square(
                            dimension: _imageSize,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(SolRadius.sm),
                              child: _AttachmentPicture(attachment: attachment),
                            ),
                          ),
                      ],
                    ),
                  if (bubble.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: bubble.attachments.isEmpty ? 0 : SolSpace.sm,
                      ),
                      child: Text(
                        bubble.text,
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Assistant reply, on the app's own surface. [MarkdownTextContent] renders it
/// with the same markdown the rest of the app does.
class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.bubble});

  final ThoughtBubble bubble;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SolSpace.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Material(
            color: scheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SolRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SolSpace.lg,
                vertical: SolSpace.md,
              ),
              child: MarkdownTextContent(
                content: bubble.text,
                isSelectable: true,
                noMentionChip: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.bubble, required this.onToggle});

  final ThoughtBubble bubble;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final detailStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 11.5,
      height: 1.5,
      color: scheme.onSurfaceVariant,
      fontFamily: 'IBM Plex Mono',
    );
    final snippet = bubble.text.trim().split('\n').first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(SolRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SolSpace.sm,
              vertical: 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TraceChevron(collapsed: bubble.collapsed),
                    const Gap(6),
                    Icon(
                      Symbols.auto_awesome_rounded,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const Gap(SolSpace.xs),
                    Text(
                      bubble.streaming
                          ? 'thoughtThinking'.tr()
                          : 'thoughtThought'.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (bubble.collapsed && snippet.isNotEmpty) ...[
                      const Gap(6),
                      Expanded(
                        child: Text(
                          snippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: detailStyle,
                        ),
                      ),
                    ],
                  ],
                ),
                _TraceDetail(
                  collapsed: bubble.collapsed,
                  child: SelectableText(bubble.text, style: detailStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolTraceRow extends StatelessWidget {
  const _ToolTraceRow({required this.bubble, required this.onToggle});

  final ThoughtBubble bubble;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final detailStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 11.5,
      height: 1.5,
      color: scheme.onSurfaceVariant,
      fontFamily: 'IBM Plex Mono',
    );
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
      letterSpacing: 0.5,
    );
    final args = bubble.toolArgs;
    final resultLabel = bubble.toolResult == null
        ? ''
        : _toolResultLabel(bubble.toolResult!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(SolRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SolSpace.sm,
              vertical: 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TraceChevron(collapsed: bubble.collapsed),
                    const Gap(6),
                    if (bubble.toolRunning)
                      const SizedBox.square(
                        dimension: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        Symbols.build_rounded,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    const Gap(6),
                    Text(
                      bubble.text,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bubble.collapsed && resultLabel.isNotEmpty) ...[
                      const Gap(6),
                      Expanded(
                        child: Text(
                          resultLabel.replaceAll(RegExp(r'\s+'), ' ').trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: detailStyle,
                        ),
                      ),
                    ],
                  ],
                ),
                _TraceDetail(
                  collapsed: bubble.collapsed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (args != null && args.isNotEmpty) ...[
                        Text('thoughtArguments'.tr(), style: labelStyle),
                        const Gap(2),
                        SelectableText(
                          _formatToolArgs(args),
                          style: detailStyle,
                        ),
                      ],
                      if (resultLabel.isNotEmpty) ...[
                        const Gap(SolSpace.sm),
                        Text('thoughtResult'.tr(), style: labelStyle),
                        const Gap(2),
                        SelectableText(resultLabel, style: detailStyle),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TraceChevron extends StatelessWidget {
  const _TraceChevron({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: collapsed ? 0 : 0.25,
      duration: const Duration(milliseconds: 180),
      child: Icon(
        Symbols.chevron_right_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _TraceDetail extends StatelessWidget {
  const _TraceDetail({required this.collapsed, required this.child});

  final bool collapsed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 180),
      firstChild: const SizedBox(width: double.infinity, height: 0),
      secondChild: Padding(
        padding: const EdgeInsets.only(left: 22, top: 6, right: SolSpace.sm),
        child: child,
      ),
      crossFadeState: collapsed
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }
}

String _toolResultLabel(String result) => switch (result) {
  kThoughtToolResultInterrupted => 'thoughtInterrupted'.tr(),
  kThoughtToolResultEarlierTurn => 'thoughtEarlierTurn'.tr(),
  _ => result,
};

String _formatToolArgs(Map<String, dynamic> args) {
  try {
    return const JsonEncoder.withIndent('  ').convert(args);
  } on JsonUnsupportedObjectError {
    return args.toString();
  }
}

/// The turn in flight: the assistant's slot in the log, holding the dots until
/// the turn ends.
class _TurnIndicator extends StatefulWidget {
  const _TurnIndicator();

  @override
  State<_TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<_TurnIndicator>
    with SingleTickerProviderStateMixin {
  static const _dotCount = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(int index, double offset) =>
      (_controller.value - index * offset) % 1.0;

  double _progress(int index) {
    final phase = _phase(index, 0.14);
    return phase < 0.55
        ? Curves.easeOutCubic.transform(phase / 0.55)
        : 1 - Curves.easeInCubic.transform((phase - 0.55) / 0.45);
  }

  double _lift(int index) {
    final phase = _phase(index, 0.16);
    return phase < 0.5
        ? Curves.easeOut.transform(phase / 0.5)
        : 1 - Curves.easeIn.transform((phase - 0.5) / 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dot = scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SolSpace.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          label: 'thoughtThinking'.tr(),
          child: Material(
            color: scheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SolRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SolSpace.xl,
                vertical: SolSpace.md,
              ),
              child: SizedBox(
                width: 28,
                height: 12,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_dotCount, (index) {
                      final progress = _progress(index);
                      final size = 3.4 + progress * 1.8;
                      return Transform.translate(
                        offset: Offset(0, -_lift(index)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              dot.withValues(alpha: 0.32),
                              dot,
                              progress,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
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

void _insertNewline(TextEditingController controller) {
  final text = controller.text;
  final selection = controller.selection;
  final start = selection.start >= 0 ? selection.start : text.length;
  final end = selection.end >= 0 ? selection.end : text.length;
  final newText = text.replaceRange(start, end, '\n');
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + 1),
  );
}

/// The composer, with the pending strip above the field and the run controls
/// below it, encased in floating liquid glass.
class _Composer extends HookConsumerWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.attachments,
    required this.busy,
    required this.usage,
    required this.onSend,
    required this.onStop,
    required this.onAttach,
    required this.onAttachFiles,
    required this.onLinkCloudFile,
    required this.onRemoveAttachment,
    required this.onRetryAttachment,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<ThoughtAttachment> attachments;
  final bool busy;
  final SnConversationUsage? usage;

  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback onAttach;
  final Future<void> Function(List<UniversalFile> files) onAttachFiles;
  final VoidCallback onLinkCloudFile;
  final void Function(int index)? onRemoveAttachment;
  final void Function(int index)? onRetryAttachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glass = GlassEffects.of(context);
    final settings = ref.watch(appSettingsProvider);
    final isDraggingOver = useState(false);

    Future<void> handlePaste() async {
      try {
        final image = await Pasteboard.image;
        if (image != null && image.isNotEmpty) {
          final tempDir = await getTemporaryDirectory();
          final file = File(
            '${tempDir.path}/thought_paste_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await file.writeAsBytes(image);
          await onAttachFiles([
            UniversalFile(
              data: XFile(file.path),
              type: UniversalFileType.image,
              displayName: 'image.jpg',
            ),
          ]);
          return;
        }
      } catch (_) {
        // Fall back to plain text paste
      }

      final textData = await Clipboard.getData(Clipboard.kTextPlain);
      if (textData != null && textData.text != null) {
        final text = controller.text;
        final selection = controller.selection;
        final start = selection.start >= 0 ? selection.start : text.length;
        final end = selection.end >= 0 ? selection.end : text.length;
        final newText = text.replaceRange(start, end, textData.text!);
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: start + textData.text!.length,
          ),
        );
      }
    }

    Future<void> handleDroppedFiles(DropDoneDetails details) async {
      final droppedFiles = <UniversalFile>[];
      for (final xfile in details.files) {
        if (xfile.path.isEmpty) continue;
        final ext = xfile.name.split('.').last.toLowerCase();
        const imageExts = {
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'bmp',
          'heic',
          'heif',
        };
        if (imageExts.contains(ext)) {
          droppedFiles.add(
            UniversalFile(
              data: xfile,
              type: UniversalFileType.image,
              displayName: xfile.name,
            ),
          );
        }
      }
      if (droppedFiles.isNotEmpty) {
        await onAttachFiles(droppedFiles);
      }
    }

    useEffect(() {
      focusNode.onKeyEvent = (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
        final isPasteModifierPressed =
            HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;

        if (isPaste && isPasteModifierPressed) {
          handlePaste();
          return KeyEventResult.handled;
        }

        final isEnter =
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter;
        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        final isMetaOrCtrlPressed =
            HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;

        if (isEnter) {
          if (settings.enterToSend) {
            if (isShiftPressed) {
              _insertNewline(controller);
              return KeyEventResult.handled;
            } else {
              if (!busy) onSend();
              return KeyEventResult.handled;
            }
          } else {
            if (isMetaOrCtrlPressed) {
              if (!busy) onSend();
              return KeyEventResult.handled;
            }
          }
        }

        return KeyEventResult.ignored;
      };
      return null;
    }, [focusNode, settings.enterToSend, busy, controller, onSend]);

    final double bottomMargin =
        SolSpace.md + MediaQuery.paddingOf(context).bottom;

    return DropTarget(
      onDragEntered: (_) => isDraggingOver.value = true,
      onDragExited: (_) => isDraggingOver.value = false,
      onDragDone: (details) async {
        isDraggingOver.value = false;
        await handleDroppedFiles(details);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          SolSpace.md,
          SolSpace.xs,
          SolSpace.md,
          bottomMargin,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _GlassComposerSurface(
              radius: BorderRadius.circular(SolRadius.xl),
              highlight: isDraggingOver.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1.0,
                          child: child,
                        ),
                      ),
                    ),
                    child: attachments.isNotEmpty
                        ? Padding(
                            key: ValueKey('attachments-${attachments.length}'),
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              top: 4,
                              bottom: 6,
                            ),
                            child: SizedBox(
                              height: 64,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: attachments.length,
                                separatorBuilder: (_, _) =>
                                    const Gap(SolSpace.sm),
                                itemBuilder: (context, index) =>
                                    _PendingAttachment(
                                      attachment: attachments[index],
                                      onRemove: onRemoveAttachment == null
                                          ? null
                                          : () => onRemoveAttachment!(index),
                                      onRetry: onRetryAttachment == null
                                          ? null
                                          : () => onRetryAttachment!(index),
                                    ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('no-attachments'),
                          ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 2),
                        child: GestureDetector(
                          onSecondaryTap: busy ? null : onLinkCloudFile,
                          child: Tooltip(
                            message: 'attach'.tr(),
                            child: IconButton(
                              onPressed: busy ? null : onAttach,
                              onLongPress: busy ? null : onLinkCloudFile,
                              icon: const Icon(Symbols.attach_file_rounded),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: settings.enterToSend
                              ? TextInputAction.send
                              : TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: InputDecoration(
                            hintText: 'thoughtsHint'.tr(),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: SolSpace.sm,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 2, bottom: 2),
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller,
                          builder: (context, value, _) {
                            final uploading = attachments
                                .where((attachment) => attachment.isUploading)
                                .length;
                            final canSend =
                                uploading == 0 &&
                                (value.text.trim().isNotEmpty ||
                                    attachments.any(
                                      (attachment) => attachment.isSendable,
                                    ));

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                              child: busy
                                  ? IconButton.filled(
                                      key: const ValueKey('composer-stop-btn'),
                                      tooltip: 'stop'.tr(),
                                      style: IconButton.styleFrom(
                                        backgroundColor: scheme.errorContainer,
                                        foregroundColor:
                                            scheme.onErrorContainer,
                                      ),
                                      onPressed: onStop,
                                      icon: const Icon(Symbols.stop_rounded),
                                    )
                                  : IconButton.filled(
                                      key: const ValueKey('composer-send-btn'),
                                      tooltip: uploading > 0
                                          ? 'thoughtUploading'.tr()
                                          : 'send'.tr(),
                                      onPressed: canSend ? onSend : null,
                                      icon: const Icon(Symbols.send_rounded),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SolSpace.xs,
                      0,
                      SolSpace.xs,
                      SolSpace.xs,
                    ),
                    child: Row(
                      children: [
                        const _ReasoningControl(),
                        const Gap(SolSpace.md),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: usage == null || usage!.totalTokens <= 0
                                ? const SizedBox.shrink()
                                : Tooltip(
                                    message: _usageTooltip(usage!),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.surfaceContainerHigh
                                            .withValues(
                                              alpha: glass ? 0.35 : 0.6,
                                            ),
                                        borderRadius: BorderRadius.circular(
                                          SolRadius.pill,
                                        ),
                                        border: Border.all(
                                          color: scheme.outlineVariant
                                              .withValues(alpha: 0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        thoughtTokensSpent(usage!.totalTokens),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontSize: 11,
                                              color: scheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alpha of the solid fallback's hairline, matching the pill's own edge.
const double _kPillBorderOpacity = 0.5;

/// The composer's floating shell: the same iOS 27 liquid glass material as the
/// chat composer and pill app bar.
class _GlassComposerSurface extends StatelessWidget {
  final BorderRadius radius;
  final Widget child;
  final bool highlight;

  const _GlassComposerSurface({
    required this.radius,
    required this.child,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final glass = GlassEffects.of(context);
    final edgeColor = highlight
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: _kPillBorderOpacity);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (glass)
            Positioned.fill(
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings.ios27Regular(
                  brightness: theme.brightness,
                ),
                defaultAppearance: LiquidGlassAppearance.ios27Regular(
                  brightness: theme.brightness,
                ),
                child: LiquidGlass(
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: radius.topLeft.x,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            )
          else
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: radius,
                  border: Border.all(
                    color: edgeColor,
                    width: highlight ? 1.5 : 1,
                  ),
                ),
              ),
            ),
          if (highlight && glass)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: colorScheme.primary, width: 1.5),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ],
      ),
    );
  }
}

/// The reasoning-effort dial, living where the message is written: the level is
/// a property of the turn about to be sent, not a global setting.
class _ReasoningControl extends ConsumerWidget {
  const _ReasoningControl();

  static const _levels = [
    ('low', 'thoughtReasoningLow'),
    ('medium', 'thoughtReasoningMedium'),
    ('high', 'thoughtReasoningHigh'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glass = GlassEffects.of(context);
    final active = ref.watch(thoughtReasoningEffortProvider);

    void choose(String effort) {
      ref
          .read(thoughtReasoningEffortProvider.notifier)
          .set(effort == active ? null : effort);
    }

    return Tooltip(
      message: active == null
          ? 'thoughtReasoningDefault'.tr()
          : 'thoughtReasoningActive'.tr(
              namedArgs: {
                'level': _levels
                    .firstWhere(
                      (level) => level.$1 == active,
                      orElse: () => (active, active),
                    )
                    .$2
                    .tr(),
              },
            ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh.withValues(
            alpha: glass ? 0.45 : 0.75,
          ),
          borderRadius: BorderRadius.circular(SolRadius.pill),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: SolSpace.xs),
                child: Icon(
                  Symbols.psychology_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              for (final level in _levels)
                _ReasoningSegment(
                  label: level.$2.tr(),
                  selected: level.$1 == active,
                  onTap: () => choose(level.$1),
                ),
              const Gap(SolSpace.xs),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasoningSegment extends StatelessWidget {
  const _ReasoningSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final glass = GlassEffects.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SolRadius.pill),
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: SolSpace.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer.withValues(alpha: glass ? 0.85 : 1.0)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(SolRadius.pill),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// A token count short enough for a one-line footer: `512`, `12.4k`, `1.2M`.
String formatThoughtTokens(int value) {
  String scaled(double amount, String suffix) {
    final text = amount.toStringAsFixed(amount < 100 ? 1 : 0);
    final trimmed = text.endsWith('.0')
        ? text.substring(0, text.length - 2)
        : text;
    return '$trimmed$suffix';
  }

  if (value < 1000) return '$value';
  if (value < 1000000) return scaled(value / 1000, 'k');
  return scaled(value / 1000000, 'M');
}

/// The readout beside the reasoning pill: the conversation's running total.
String thoughtTokensSpent(int value) =>
    'thoughtTokensSpent'.tr(namedArgs: {'count': formatThoughtTokens(value)});

/// The full sentence behind the token readout, for the tooltip.
String _usageTooltip(SnConversationUsage usage) {
  final parts = <String>[thoughtTokensSpent(usage.totalTokens)];
  final used = usage.peakContextUsedTokens;
  final window = usage.contextWindowTokens;
  if (used != null && window != null && window > 0) {
    parts.add(
      'thoughtContextPeak'.tr(
        namedArgs: {
          'used': formatThoughtTokens(used),
          'window': formatThoughtTokens(window),
        },
      ),
    );
  }
  parts.add('thoughtRuns'.tr(namedArgs: {'count': '${usage.runs}'}));
  return parts.join('\n');
}

class _PendingAttachment extends StatelessWidget {
  const _PendingAttachment({
    required this.attachment,
    this.onRemove,
    this.onRetry,
  });

  static const double _size = 60;

  final ThoughtAttachment attachment;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final failed = attachment.hasFailed;
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Tooltip(
              message: failed
                  ? attachment.error ?? 'thoughtUploadFailed'.tr()
                  : attachment.name,
              child: Material(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(SolRadius.sm),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: failed ? onRetry : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _AttachmentPicture(attachment: attachment),
                      if (attachment.isUploading)
                        _UploadOverlay(progress: attachment.progress),
                      if (failed)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.55),
                          ),
                          child: Center(
                            child: Icon(
                              Symbols.refresh_rounded,
                              size: 20,
                              color: scheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'delete'.tr(),
              iconSize: 12,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: scheme.surfaceContainerHighest,
                minimumSize: const Size(20, 20),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onRemove,
              icon: const Icon(Symbols.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadOverlay extends StatelessWidget {
  const _UploadOverlay({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (progress != null)
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          const Gap(SolSpace.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SolSpace.sm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// An image attachment's picture: the file on this device while it is still
/// there, and the drive's copy otherwise.
class _AttachmentPicture extends StatelessWidget {
  const _AttachmentPicture({required this.attachment});

  final ThoughtAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final path = attachment.localPath;
    final fileId = attachment.fileId ?? '';
    if (path != null && path.isNotEmpty && !kIsWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          final ratio = MediaQuery.devicePixelRatioOf(context);
          return Image.file(
            File(path),
            fit: BoxFit.cover,
            cacheWidth: side.isFinite ? (side * ratio).round() : null,
            errorBuilder: (_, _, _) => _DriveAttachmentPicture(fileId: fileId),
          );
        },
      );
    }
    return _DriveAttachmentPicture(fileId: fileId);
  }
}

class _DriveAttachmentPicture extends HookConsumerWidget {
  const _DriveAttachmentPicture({required this.fileId});

  final String fileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(tokenProvider);
    final serverUrl = ref.watch(serverUrlProvider);
    final scheme = Theme.of(context).colorScheme;
    if (fileId.isEmpty || token == null) {
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Symbols.image_rounded,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final ratio = MediaQuery.devicePixelRatioOf(context);
        return Image.network(
          cloudFileUrl(serverUrl: serverUrl, id: fileId),
          headers: {'Authorization': 'Bearer ${token.token}'},
          fit: BoxFit.cover,
          cacheWidth: side.isFinite ? (side * ratio).round() : null,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      },
    );
  }
}

/// The account's threads: newest first, the open one highlighted.
class _ThreadList extends ConsumerWidget {
  const _ThreadList({required this.activeId, required this.onSelect});

  final String? activeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final conversationsAsync = ref.watch(personalityConversationsProvider);
    final conversations =
        conversationsAsync.value ?? const <SnPersonalityConversation>[];

    if (conversationsAsync.isLoading && conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (conversationsAsync.hasError && conversations.isEmpty) {
      return EmptyState(
        icon: Symbols.error_outline,
        title: 'failedToLoad'.tr(),
        description: personalityErrorMessage(conversationsAsync.error!),
        action: TextButton(
          onPressed: () => ref.invalidate(personalityConversationsProvider),
          child: Text('retry'.tr()),
        ),
        compact: true,
      );
    }
    if (conversations.isEmpty) {
      return EmptyState(
        icon: Symbols.forum_rounded,
        title: 'thoughtsNoConversations'.tr(),
        compact: true,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: SolSpace.sm),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final selected = conversation.id == activeId;
        return ListTile(
          selected: selected,
          leading: Icon(
            Symbols.chat_bubble_outline_rounded,
            fill: selected ? 1 : null,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
          title: Text(
            conversation.title.trim().isEmpty
                ? 'thoughts'.tr()
                : conversation.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: conversation.lastMessageAt == null
              ? null
              : Text(conversation.lastMessageAt!.formatRelative(context)),
          trailing: IconButton(
            tooltip: 'delete'.tr(),
            icon: const Icon(Symbols.delete_outline_rounded, size: 20),
            onPressed: () => deleteThoughtConversation(ref, conversation.id),
          ),
          onTap: () => onSelect(conversation.id),
        );
      },
    );
  }
}

/// The drive's own files, picked by id: what the attach button offers beyond a
/// fresh upload.
class _CloudFilePickerSheet extends HookConsumerWidget {
  const _CloudFilePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(_driveImagesProvider);
    return SheetScaffold(
      titleText: 'linkAttachment'.tr(),
      child: files.when(
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Symbols.folder_off_rounded,
                title: 'thoughtsNoCloudFiles'.tr(),
                compact: true,
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final file = items[index];
                  return ListTile(
                    leading: SizedBox.square(
                      dimension: 44,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(SolRadius.xs),
                        child: _DriveAttachmentPicture(fileId: file.id),
                      ),
                    ),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(context).pop(file),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Symbols.error_outline,
          title: 'failedToLoad'.tr(),
          description: personalityErrorMessage(error),
          action: TextButton(
            onPressed: () => ref.invalidate(_driveImagesProvider),
            child: Text('retry'.tr()),
          ),
          compact: true,
        ),
      ),
    );
  }
}

/// The account's own drive images, newest first: the files a run can hand the
/// model.
///
/// The listing is every file the account owns — the server's own filters are
/// narrower than the drive's contents — and the images are picked out here.
final _driveImagesProvider = FutureProvider.autoDispose<List<SnCloudFile>>((
  ref,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  final result = await client.drive.listMyFiles(take: 60, orderDesc: true);
  return [
    for (final file in result.items)
      if (!file.isFolder && file.mimeType.startsWith('image/')) file,
  ].take(40).toList();
});
