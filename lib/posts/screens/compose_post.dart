import 'package:auto_route/auto_route.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/core/database.dart';
import 'package:island/core/theme.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/compose_card.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A request to author a post somewhere other than the composer route.
///
/// Wide pages host the composer in a pane beside their content;
/// [ComposePaneHost] carries that pane's opener down to every reply, forward,
/// chain and edit affordance in the page, so those keep calling
/// [PostComposeScreen.show] exactly as they always have.
typedef ComposePaneRequest =
    Future<bool?> Function({
      SnPost? originalPost,
      PostComposeInitialState? initialState,
      SnPost? replyingTo,
      SnPost? forwardingTo,
      SnPost? chainingTo,
    });

/// Routes [PostComposeScreen.show] into the enclosing page's own pane.
///
/// Subtrees without a host keep pushing the composer route, so only pages that
/// opt in change where authoring happens.
class ComposePaneHost extends InheritedWidget {
  final ComposePaneRequest show;

  const ComposePaneHost({super.key, required this.show, required super.child});

  static ComposePaneHost? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ComposePaneHost>();

  @override
  bool updateShouldNotify(ComposePaneHost oldWidget) => show != oldWidget.show;
}

/// Where a [PostComposePane] draws its own chrome.
enum PostComposeChrome {
  /// The composer route: a scaffold app bar over the page's own surface.
  page,

  /// A pane inside another page: a pill header over the content, inside the
  /// card the host draws around the pane.
  pane,
}

/// The post composer, as a page.
///
/// Authoring a post is a place you go, not a modal that interrupts the feed:
/// the composer owns the whole viewport, the keyboard and the window's own
/// back/close affordances, and a draft survives leaving it. [show] keeps the
/// push-and-await-result shape its callers already use.
@RoutePage()
class PostComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  /// Reply, forward and chain targets that the caller resolved itself, used
  /// when [originalPost] carries only their ids — a draft saved on this device
  /// has no server payload to read them from.
  final SnPost? replyingTo;
  final SnPost? forwardingTo;
  final SnPost? chainingTo;

  const PostComposeScreen({
    super.key,
    this.originalPost,
    this.initialState,
    this.replyingTo,
    this.forwardingTo,
    this.chainingTo,
  });

  /// Opens the composer and resolves to `true` once a post was submitted.
  ///
  /// Editing an article or a blog is a different authoring surface entirely, so
  /// those two types are routed to their own pages instead.
  static Future<bool?> show(
    BuildContext context, {
    SnPost? originalPost,
    PostComposeInitialState? initialState,
    SnPost? replyingTo,
    SnPost? forwardingTo,
    SnPost? chainingTo,
  }) async {
    if (originalPost != null && originalPost.type == 1) {
      await context.router.push(ArticleEditRoute(id: originalPost.id));
      return true;
    }
    if (originalPost != null && originalPost.type == 2) {
      await context.router.push(BlogComposeRoute(originalPost: originalPost));
      return true;
    }

    final host = ComposePaneHost.maybeOf(context);
    if (host != null) {
      return host.show(
        originalPost: originalPost,
        initialState: initialState,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
        chainingTo: chainingTo,
      );
    }

    return context.router.push<bool?>(
      PostComposeRoute(
        originalPost: originalPost,
        initialState: initialState,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
        chainingTo: chainingTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostComposePane(
      originalPost: originalPost,
      initialState: initialState,
      replyingTo: replyingTo,
      forwardingTo: forwardingTo,
      chainingTo: chainingTo,
      chrome: PostComposeChrome.page,
      onFinished: (submitted) {
        if (submitted && context.mounted) context.router.maybePop(true);
      },
    );
  }
}

/// The composer itself — draft lifecycle, form, preview and submit — with the
/// chrome left to whoever hosts it.
///
/// The route page wraps it in a scaffold; a wide page's pane wraps it in its
/// own floating card. Either way the host decides when the form goes away, and
/// leaving it always saves the draft.
class PostComposePane extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;
  final SnPost? replyingTo;
  final SnPost? forwardingTo;
  final SnPost? chainingTo;
  final PostComposeChrome chrome;

  /// Told when the host's own dismiss affordance was used. `true` reports a
  /// submission; `false` a plain close.
  final ValueChanged<bool> onFinished;

  const PostComposePane({
    super.key,
    this.originalPost,
    this.initialState,
    this.replyingTo,
    this.forwardingTo,
    this.chainingTo,
    this.chrome = PostComposeChrome.page,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(composeStorageProvider);
    final prompted = useState(false);
    final showPreview = useState(false);
    final isDragging = useState(false);

    final fullPostData =
        originalPost != null &&
            ComposeLogic.serverBackedPostId(originalPost!) != null
        ? ref.watch(postProvider(originalPost!.id))
        : const AsyncValue.data(null);

    final effectiveOriginalPost = fullPostData.when(
      data: (fullPost) => fullPost ?? originalPost,
      loading: () => originalPost,
      error: (_, _) => originalPost,
    );

    final repliedPost =
        replyingTo ??
        initialState?.replyingTo ??
        effectiveOriginalPost?.repliedPost;
    final forwardedPost =
        forwardingTo ??
        initialState?.forwardingTo ??
        effectiveOriginalPost?.forwardedPost;
    final chainedPost =
        chainingTo ??
        initialState?.chainingTo ??
        effectiveOriginalPost?.chainedPost;

    final ComposeState state = useMemoized(
      () => ComposeLogic.createState(
        originalPost: effectiveOriginalPost,
        forwardedPost: forwardedPost,
        repliedPost: repliedPost,
        cloudDraftId: initialState?.cloudDraftId,
        postType: 0,
      ),
      [
        effectiveOriginalPost,
        forwardedPost,
        repliedPost,
        initialState?.cloudDraftId,
      ],
    );

    final stateNotifier = useMemoized(
      () => Listenable.merge([
        state.titleController,
        state.descriptionController,
        state.contentController,
        state.visibility,
        state.attachments,
        state.attachmentProgress,
        state.currentPublisher,
        state.submitting,
      ]),
      [state],
    );
    useListenable(stateNotifier);

    ComposeStateUtils.usePublisherInitialization(
      ref,
      state,
      preferredPublisher: chainedPost?.publisher,
    );
    ComposeStateUtils.useInitialStateLoader(state, initialState);
    ComposeStateUtils.useEditorBootstrap(state);

    // A composer page never traps the user: leaving saves the draft, whether
    // they pop the route or a submit dismisses it.
    useEffect(() {
      final database = ref.read(databaseProvider);
      return () {
        state.stopAutoSave();
        ComposeLogic.saveDraftWithoutUploadWithDatabase(database, state);
        ComposeLogic.dispose(state);
      };
    }, [state]);

    useEffect(() {
      final database = ref.read(databaseProvider);
      final isNewPost =
          effectiveOriginalPost == null &&
          repliedPost == null &&
          forwardedPost == null;
      if (isNewPost) {
        state.startAutoSave(
          (composeState) => ComposeLogic.saveDraftWithoutUploadWithDatabase(
            database,
            composeState,
          ),
        );
      }
      return null;
    }, [state, effectiveOriginalPost, repliedPost, forwardedPost]);

    useEffect(
      () {
        if (!prompted.value &&
            originalPost == null &&
            initialState?.replyingTo == null &&
            initialState?.forwardingTo == null) {
          final latestDraft = ref
              .read(composeStorageProvider.notifier)
              .getLatestDraftByType(0);
          if (latestDraft == null) return null;
          prompted.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRestoreDialog(ref, state, latestDraft);
          });
        }
        return null;
      },
      [
        prompted.value,
        originalPost,
        initialState?.replyingTo,
        initialState?.forwardingTo,
      ],
    );

    Future<void> performSubmit() async {
      await ComposeLogic.submitInBackground(
        ref,
        state,
        originalPost: effectiveOriginalPost,
        repliedPost: repliedPost,
        forwardedPost: forwardedPost,
        chainedPost: chainedPost,
        autoChain: state.chainWithPrevious.value,
        onSubmitted: () {
          if (context.mounted) onFinished(true);
        },
      );
    }

    final title = effectiveOriginalPost != null
        ? 'postEditing'.tr()
        : 'postCompose'.tr();

    final previewToggle = IconButton(
      icon: Icon(showPreview.value ? Symbols.preview_off : Symbols.preview),
      onPressed: () => showPreview.value = !showPreview.value,
      tooltip: 'togglePreview'.tr(),
    );
    final settingsButton = IconButton(
      icon: const Icon(Symbols.settings),
      onPressed: () => showComposeSettingsSheet(context, state),
      tooltip: 'postSettings'.tr(),
    );
    final submitButton = ValueListenableBuilder<bool>(
      valueListenable: state.submitting,
      builder: (context, submitting, _) {
        return IconButton(
          onPressed: (submitting || state.currentPublisher.value == null)
              ? null
              : performSubmit,
          icon: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  effectiveOriginalPost != null
                      ? Symbols.edit
                      : Symbols.upload,
                ),
          tooltip: effectiveOriginalPost != null
              ? 'postUpdate'.tr()
              : 'postPublish'.tr(),
        );
      },
    );
    final closeButton = IconButton(
      icon: const Icon(Symbols.close),
      onPressed: () => onFinished(false),
      tooltip: 'close'.tr(),
    );

    final form = Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showPreview.value
                ? _ComposePreviewPane(
                    key: const ValueKey('preview'),
                    state: state,
                  )
                : PostComposeForm(
                    key: const ValueKey('compose'),
                    originalPost: effectiveOriginalPost,
                    initialState: initialState,
                    providedState: state,
                    onSubmitRequest: performSubmit,
                  ),
          ),
        ),
      ],
    );

    return PopScope(
      child: DropTarget(
        onDragEntered: (_) => isDragging.value = true,
        onDragExited: (_) => isDragging.value = false,
        onDragDone: (details) {
          isDragging.value = false;
          ComposeLogic.addDroppedFiles(ref, state, details.files);
        },
        child: Stack(
          children: [
            switch (chrome) {
              PostComposeChrome.page => AppScaffold(
                // Solid page ground like every other content screen: the wide
                // default paints the scaffold transparent, which washes the
                // window backdrop's radial orbs through as a gradient.
                isNoBackground: false,
                appBar: AppBar(
                  leading: const AutoLeadingButton(),
                  title: Text(title),
                  actions: [
                    previewToggle,
                    settingsButton,
                    submitButton,
                  ],
                ),
                body: form,
              ),
              // A pane's host draws the card; the composer floats the same
              // glass pill the rest of the page uses, with its close, settings
              // and publish actions in it. The form starts one pill below so
              // its first field never hides under the header.
              PostComposeChrome.pane => Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: kPillAppBarHeight),
                    child: form,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PillAppBar(
                      statusTop: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).appBarTheme.titleTextStyle,
                            ),
                          ),
                          previewToggle,
                          settingsButton,
                          submitButton,
                          closeButton,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            },
            if (isDragging.value)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.9),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.upload_file,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Gap(SolSpace.lg),
                          Text(
                            'dropFilesHere'.tr(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRestoreDialog(
    WidgetRef ref,
    ComposeState state,
    SnPost latestDraft,
  ) async {
    final restore = await showDialog<bool>(
      context: ref.context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 520),
        title: Text('restoreDraftTitle'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('restoreDraftMessage'.tr()),
            const Gap(SolSpace.lg),
            _buildCompactDraftPreview(context, latestDraft),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('yes'.tr()),
          ),
        ],
      ),
    );
    if (restore == true) {
      ComposeLogic.applyDraftToState(state, latestDraft);
    }
  }

  Widget _buildCompactDraftPreview(BuildContext context, SnPost draft) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SolSpace.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: SolRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.description,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const Gap(SolSpace.sm),
              Text(
                'draft'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(SolSpace.sm),
          if (draft.title?.isNotEmpty ?? false)
            Text(
              draft.title!,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (draft.content?.isNotEmpty ?? false)
            Text(
              draft.content!,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (draft.attachments.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.attach_file,
                  size: 12,
                  color: theme.colorScheme.secondary,
                ),
                const Gap(SolSpace.xs),
                Text(
                  'postHasAttachments',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ).plural(draft.attachments.length),
              ],
            ),
        ],
      ),
    );
  }
}

/// Renders the post exactly as the feed would, on the composer's own surface.
class _ComposePreviewPane extends HookWidget {
  final ComposeState state;

  const _ComposePreviewPane({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = useValueListenable(state.contentController);
    final attachments = useValueListenable(state.attachments);

    if (content.text.isEmpty && attachments.isEmpty) {
      return EmptyState(
        icon: Symbols.edit_note,
        title: 'previewEmpty'.tr(),
        compact: true,
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(SolSpace.lg),
            child: MarkdownTextContent(
              content: content.text,
              textStyle: theme.textTheme.bodyMedium,
              attachments: attachments
                  .where((e) => e.isOnCloud)
                  .map((e) => e.data as IDisplayableCloudFile)
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
