import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/widgets/compose/compose_attachments.dart';
import 'package:island/posts/widgets/compose/compose_form_fields.dart';
import 'package:island/posts/widgets/compose/compose_info_banner.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/posts/widgets/compose/compose_toolbar.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

/// The post authoring form: publisher, info banners, body fields, attachments
/// and the formatting toolbar, without any chrome of its own.
///
/// The surface it renders on belongs to the host — the composer page puts it
/// straight on the page background — so this widget only lays the fields out.
/// The [ComposeState] is owned and disposed by that host too, which is why
/// [providedState] is required.
class PostComposeForm extends HookConsumerWidget {
  final SnPost? originalPost;
  final PostComposeInitialState? initialState;

  /// Runs the submit flow; the host owns publishing, dismissal and drafts.
  final Future<void> Function()? onSubmitRequest;

  /// Receives the live state once, so a host can render side panels (preview,
  /// schedule, settings) against the same controllers.
  final Function(ComposeState)? onStateChanged;
  final ComposeState? providedState;

  const PostComposeForm({
    super.key,
    this.originalPost,
    this.initialState,
    this.onSubmitRequest,
    this.onStateChanged,
    this.providedState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final composeState = providedState!;

    final repliedPost = initialState?.replyingTo ?? originalPost?.repliedPost;
    final forwardedPost =
        initialState?.forwardingTo ?? originalPost?.forwardedPost;
    final chainedPost = initialState?.chainingTo ?? originalPost?.chainedPost;

    // Matches server Posts:AutoChainWindowMinutes default (5 minutes).
    const autoChainWindow = Duration(minutes: 5);

    // The compose state is created, driven and disposed by the host.

    // Add a listener to the entire state to trigger rebuilds
    final stateNotifier = useMemoized(
      () => Listenable.merge([
        composeState.titleController,
        composeState.descriptionController,
        composeState.contentController,
        composeState.visibility,
        composeState.attachments,
        composeState.attachmentProgress,
        composeState.currentPublisher,
        composeState.submitting,
        composeState.lastOwnPostPublishedAt,
        composeState.chainWithPrevious,
      ]),
      [composeState],
    );
    useListenable(stateNotifier);

    // Notify parent of state changes
    useEffect(() {
      onStateChanged?.call(composeState);
      return null;
    }, [composeState]);
    // Use shared state management utilities
    ComposeStateUtils.usePublisherInitialization(
      ref,
      composeState,
      preferredPublisher: chainedPost?.publisher,
    );

    ComposeStateUtils.useEditorBootstrap(composeState);
    // Track the publisher's most recent post so the auto-chain banner can
    // reflect server-side auto-chaining (Posts:AutoChainWindowMinutes).
    final currentPublisherName = composeState.currentPublisher.value?.name;
    useEffect(() {
      if (currentPublisherName == null || currentPublisherName.isEmpty) {
        composeState.lastOwnPostPublishedAt.value = null;
        return null;
      }
      var cancelled = false;
      final client = ref.read(solarNetworkClientProvider);
      client.dio
          .get(
            '/sphere/posts',
            queryParameters: {'pub': currentPublisherName, 'take': 1},
          )
          .then((response) {
            if (cancelled) return;
            final data = response.data;
            if (data is List && data.isNotEmpty) {
              composeState.lastOwnPostPublishedAt.value = SnPost.fromJson(
                data.first as Map<String, dynamic>,
              ).publishedAt;
            } else {
              composeState.lastOwnPostPublishedAt.value = null;
            }
          })
          .catchError((_) {
            if (!cancelled) composeState.lastOwnPostPublishedAt.value = null;
          });
      return () => cancelled = true;
    }, [currentPublisherName]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner (reply/forward/chain)
        ComposeInfoBanner(
          originalPost: originalPost,
          replyingTo: repliedPost,
          forwardingTo: forwardedPost,
          chainingTo: chainedPost,
          onReferencePostTap: (context, post) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => SheetScaffold(
                titleText: 'Post Preview',
                child: SingleChildScrollView(child: PostItem(item: post)),
              ),
            );
          },
        ),

        // Auto-chain banner (new root post within the server window)
        if (originalPost == null &&
            repliedPost == null &&
            forwardedPost == null &&
            chainedPost == null &&
            composeState.chainWithPrevious.value &&
            composeState.lastOwnPostPublishedAt.value != null &&
            DateTime.now().difference(
                  composeState.lastOwnPostPublishedAt.value!,
                ) <=
                autoChainWindow)
          _AutoChainBanner(
            onCancel: () => composeState.chainWithPrevious.value = false,
          ),

        // Main content area
        Expanded(
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is! KeyDownEvent) {
                return;
              }

              final isModifierPressed =
                  HardwareKeyboard.instance.isMetaPressed ||
                  HardwareKeyboard.instance.isControlPressed;
              final isSubmit = event.logicalKey == LogicalKeyboardKey.enter;

              if (isSubmit &&
                  isModifierPressed &&
                  !composeState.submitting.value) {
                onSubmitRequest?.call();
                return;
              }

              ComposeLogic.handleKeyPress(
                event,
                composeState,
                ref,
                context,
                originalPost: originalPost,
                repliedPost: repliedPost,
                forwardedPost: forwardedPost,
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher profile picture
                  GestureDetector(
                    child: ProfilePictureWidget(
                      file: composeState.currentPublisher.value?.picture,
                      fallbackName: composeState.currentPublisher.value?.nick,
                      radius: 20,
                      borderRadius:
                          composeState.currentPublisher.value?.type == 0
                          ? null
                          : 12,
                      fallbackIcon: composeState.currentPublisher.value == null
                          ? Symbols.question_mark
                          : null,
                    ),
                    onTap: () {
                      if (composeState.currentPublisher.value == null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (context) => const NewPublisherScreen(),
                        ).then((value) {
                          if (value != null) {
                            composeState.currentPublisher.value =
                                value as SnPublisher;
                            ref.invalidate(publishersManagedProvider);
                          }
                        });
                      } else {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          useRootNavigator: true,
                          context: context,
                          builder: (context) => const PublisherModal(),
                        ).then((value) {
                          if (value != null) {
                            composeState.currentPublisher.value = value;
                          }
                        });
                      }
                    },
                  ).padding(top: 8),

                  // Post content form
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ComposeFormFields(
                          state: composeState,
                          showPublisherAvatar: false,
                          onPublisherTap: () {
                            if (composeState.currentPublisher.value == null) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useRootNavigator: true,
                                builder: (context) =>
                                    const NewPublisherScreen(),
                              ).then((value) {
                                if (value != null) {
                                  composeState.currentPublisher.value =
                                      value as SnPublisher;
                                  ref.invalidate(publishersManagedProvider);
                                }
                              });
                            } else {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                useRootNavigator: true,
                                context: context,
                                builder: (context) => const PublisherModal(),
                              ).then((value) {
                                if (value != null) {
                                  composeState.currentPublisher.value = value;
                                }
                              });
                            }
                          },
                        ),
                        const Gap(8),
                        ComposeAttachments(
                          state: composeState,
                          isCompact: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom toolbar
        ComposeToolbar(state: composeState, originalPost: originalPost),
      ],
    );
  }
}

/// Card shown above the compose content when the current post will be
/// auto-chained to the publisher's previous post. Tapping the cancel action
/// opts this submission out of auto-chaining.
///
/// It floats like the other compose indicators ([ComposeIndicatorCard])
/// rather than bleeding edge to edge, so the composer reads as one stack of
/// cards over the page ground.
class _AutoChainBanner extends StatelessWidget {
  final VoidCallback onCancel;

  const _AutoChainBanner({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ComposeIndicatorCard(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.xs,
          SolSpace.sm,
          SolSpace.xs,
        ),
        child: Row(
          children: [
            Icon(
              Symbols.link,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const Gap(SolSpace.sm),
            Expanded(
              child: Text(
                'postWillBeChained'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            TextButton(onPressed: onCancel, child: Text('cancel'.tr())),
          ],
        ),
      ),
    );
  }
}
