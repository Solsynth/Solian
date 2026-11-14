import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/pods/draft_box.dart';
import 'package:island/posts/screens/compose_post.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';

const double _draftBoxMaxWidth = 640.0;

enum _DraftFilter { all, drafts, scheduled, localOnly }

/// The authoring box: cloud drafts, posts waiting for their publish time and
/// the drafts that only exist on this device, in one list.
@RoutePage()
class DraftBoxScreen extends HookConsumerWidget {
  const DraftBoxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = draftBoxProvider;
    final draftState = ref.watch(provider);
    final isActionBusy = useState(false);
    final filter = useState(_DraftFilter.all);
    final fade = useValueNotifier(0.0);

    final isLoading =
        draftState.isLoading ||
        draftState.value?.isLoading == true ||
        isActionBusy.value;
    final totalCount = draftState.asData?.value.items.length ?? 0;
    final statusTop = MediaQuery.paddingOf(context).top;

    return AppScaffold(
      appBarOverContent: true,
      appBar: PillAppBar(
        fade: fade,
        statusTop: statusTop,
        loading: isLoading,
        child: Row(
          children: [
            const AutoLeadingButton(),
            const Gap(SolSpace.xs),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  totalCount > 0 ? '${'draftBox'.tr()} ($totalCount)' : 'draftBox'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),
            IconButton(
              tooltip: 'refresh'.tr(),
              icon: const Icon(Symbols.refresh),
              onPressed: isLoading
                  ? null
                  : () => ref.read(provider.notifier).refresh(),
            ),
          ],
        ),
      ),
      // The pill floats over the body; its band is reserved by the list
      // itself, so drafts scroll under the glass.
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) => updatePillFade(notification, fade),
        child: PaginationWidget<DraftBoxEntry>(
          provider: provider,
          notifier: provider.notifier,
          contentBuilder: (items, footer) {
            if (items.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: statusTop + kPillAppBarHeight),
                child: EmptyState(
                  icon: Symbols.drafts,
                  title: 'draftBoxEmpty'.tr(),
                ),
              );
            }

            final filtered = switch (filter.value) {
              _DraftFilter.all => items,
              _DraftFilter.drafts =>
                items.where((e) => !e.isScheduled).toList(),
              _DraftFilter.scheduled =>
                items.where((e) => e.isScheduled).toList(),
              _DraftFilter.localOnly =>
                items.where((e) => e.isLocalOnly).toList(),
            };

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                SolSpace.md,
                statusTop + kPillAppBarHeight + SolSpace.sm,
                SolSpace.md,
                24,
              ),
              itemCount: filtered.length + 2,
              separatorBuilder: (_, index) => Gap(index == 0 ? SolSpace.sm : 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _draftBoxMaxWidth,
                      ),
                      child: _DraftFilterBar(
                        selected: filter.value,
                        items: items,
                        onSelected: (next) => filter.value = next,
                      ),
                    ),
                  );
                }
                if (index == filtered.length + 1) {
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: EmptyState(
                        icon: Symbols.filter_list_off,
                        title: 'draftBoxEmpty'.tr(),
                      ),
                    );
                  }
                  return footer;
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _draftBoxMaxWidth,
                    ),
                    child: DraftBoxTile(
                      entry: filtered[index - 1],
                      onBusyChanged: (busy) {
                        if (context.mounted && isActionBusy.value != busy) {
                          isActionBusy.value = busy;
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DraftFilterBar extends StatelessWidget {
  final _DraftFilter selected;
  final List<DraftBoxEntry> items;
  final ValueChanged<_DraftFilter> onSelected;

  const _DraftFilterBar({
    required this.selected,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final draftCount = items.where((e) => !e.isScheduled).length;
    final scheduledCount = items.where((e) => e.isScheduled).length;
    final localCount = items.where((e) => e.isLocalOnly).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            selected: selected == _DraftFilter.all,
            label: Text('${'all'.tr()} (${items.length})'),
            onSelected: (_) => onSelected(_DraftFilter.all),
          ),
          const Gap(SolSpace.xs),
          FilterChip(
            selected: selected == _DraftFilter.drafts,
            avatar: const Icon(Symbols.draft, size: 16),
            label: Text('${'draft'.tr()} ($draftCount)'),
            onSelected: (_) => onSelected(_DraftFilter.drafts),
          ),
          if (scheduledCount > 0) ...[
            const Gap(SolSpace.xs),
            FilterChip(
              selected: selected == _DraftFilter.scheduled,
              avatar: const Icon(Symbols.event_available, size: 16),
              label: Text('${'scheduled'.tr()} ($scheduledCount)'),
              onSelected: (_) => onSelected(_DraftFilter.scheduled),
            ),
          ],
          if (localCount > 0) ...[
            const Gap(SolSpace.xs),
            FilterChip(
              selected: selected == _DraftFilter.localOnly,
              avatar: const Icon(Symbols.cloud_off, size: 16),
              label: Text('${'draftLocalOnly'.tr()} ($localCount)'),
              onSelected: (_) => onSelected(_DraftFilter.localOnly),
            ),
          ],
        ],
      ),
    );
  }
}

class DraftBoxTile extends ConsumerWidget {
  final DraftBoxEntry entry;
  final ValueChanged<bool>? onBusyChanged;

  const DraftBoxTile({super.key, required this.entry, this.onBusyChanged});

  IconData get _typeIcon {
    if (entry.scheduledAt != null) return Symbols.event_available;
    return switch (entry.post.type) {
      1 => Symbols.article,
      2 => Symbols.language,
      _ => Symbols.edit_note,
    };
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(composeStorageProvider);
    await ref.read(draftBoxProvider.notifier).refresh();
  }

  /// A locally saved draft stores only the ids of the post it replies to,
  /// forwards or chains; resolve them so the composer keeps that context.
  Future<(SnPost?, SnPost?, SnPost?)> _resolveTargets(WidgetRef ref) async {
    final client = ref.read(solarNetworkClientProvider);
    Future<SnPost?> load(String? id) async {
      if (id == null || id.isEmpty) return null;
      try {
        return await client.sphere.getPost(id);
      } catch (_) {
        return null;
      }
    }

    return (
      await load(entry.post.repliedPostId),
      await load(entry.post.forwardedPostId),
      await load(entry.post.chainedPostId),
    );
  }

  Future<void> _openComposer(BuildContext context, WidgetRef ref) async {
    final post = entry.post;
    if (!entry.isLocalOnly) {
      await PostComposeScreen.show(context, originalPost: post);
      return;
    }

    // A draft the server has never seen cannot go through an edit route that
    // fetches it by id; open the composer seeded with the local copy instead.
    switch (post.type) {
      case 1:
        await context.router.push(ArticleComposeRoute(originalPost: post));
      case 2:
        await context.router.push(BlogComposeRoute(originalPost: post));
      default:
        final (repliedPost, forwardedPost, chainedPost) = await _resolveTargets(
          ref,
        );
        if (!context.mounted) return;
        await PostComposeScreen.show(
          context,
          originalPost: post,
          replyingTo: repliedPost,
          forwardingTo: forwardedPost,
          chainingTo: chainedPost,
        );
    }
  }

  Future<void> _runBusy(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    onBusyChanged?.call(true);
    if (context.mounted) showLoadingModal(context);
    try {
      await action();
    } catch (err) {
      showErrorAlert(err);
    } finally {
      onBusyChanged?.call(false);
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _upload(WidgetRef ref, BuildContext context) =>
      _runBusy(context, () async {
        await ref
            .read(composeStorageProvider.notifier)
            .uploadDraftToCloud(entry.post.id);
        await _refresh(ref);
        if (context.mounted) showSnackBar('draftUploadedToCloud'.tr());
      });

  Future<void> _publishNow(WidgetRef ref, BuildContext context) =>
      _runBusy(context, () async {
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.batchUpdatePostVisibility(
          postIds: [entry.post.id],
          publishedAt: DateTime.now(),
        );
        await _refresh(ref);
        if (context.mounted) showSnackBar('draftPublishNowDone'.tr());
      });

  Future<void> _unschedule(WidgetRef ref, BuildContext context) =>
      _runBusy(context, () async {
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.batchUpdatePostVisibility(
          postIds: [entry.post.id],
          draftedAt: DateTime.now(),
        );
        await _refresh(ref);
        if (context.mounted) showSnackBar('draftUnscheduleDone'.tr());
      });

  Future<void> _delete(WidgetRef ref, BuildContext context) async {
    final confirmed = await showConfirmAlert(
      'deleteDraftConfirmHint'.tr(),
      'deleteDraft'.tr(),
      isDanger: true,
    );
    if (confirmed != true || !context.mounted) return;

    await _runBusy(context, () async {
      if (entry.isLocalOnly) {
        await ref
            .read(composeStorageProvider.notifier)
            .deleteLocalDraft(entry.post.id);
      } else {
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.batchDeletePosts([entry.post.id]);
      }
      await _refresh(ref);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scheduledAt = entry.scheduledAt;
    final publisher = entry.post.publisher;
    final title = entry.post.title?.trim();
    final content = entry.post.content?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final hasContent = content != null && content.isNotEmpty;
    final updatedAt = (entry.post.updatedAt ?? entry.post.createdAt)?.toLocal();
    final attachmentCount = entry.post.attachments.length;

    final badgeBg = scheduledAt != null
        ? colorScheme.primaryContainer
        : (entry.isLocalOnly
              ? colorScheme.tertiaryContainer
              : colorScheme.surfaceContainerHigh);
    final badgeFg = scheduledAt != null
        ? colorScheme.onPrimaryContainer
        : (entry.isLocalOnly
              ? colorScheme.onTertiaryContainer
              : colorScheme.onSurfaceVariant);

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: SolRadius.cardRadius,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openComposer(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(SolRadius.sm),
                ),
                child: Icon(_typeIcon, size: 18, color: badgeFg),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasTitle) ...[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasContent) ...[
                        const Gap(2),
                        Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ] else
                      Text(
                        hasContent ? content : 'postPlaceholder'.tr(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hasContent
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontStyle: hasContent
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    const Gap(8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _DraftChip(
                          icon: scheduledAt != null
                              ? Symbols.event_available
                              : Symbols.draft,
                          label: scheduledAt != null
                              ? 'postScheduledFor'.tr(
                                  namedArgs: {
                                    'time': scheduledAt.formatSystem(),
                                  },
                                )
                              : 'draft'.tr(),
                          backgroundColor: scheduledAt != null
                              ? colorScheme.primaryContainer
                              : null,
                          foregroundColor: scheduledAt != null
                              ? colorScheme.onPrimaryContainer
                              : null,
                        ),
                        if (entry.isLocalOnly)
                          _DraftChip(
                            icon: Symbols.cloud_off,
                            label: 'draftLocalOnly'.tr(),
                            backgroundColor: colorScheme.tertiaryContainer,
                            foregroundColor: colorScheme.onTertiaryContainer,
                          ),
                        if (attachmentCount > 0)
                          _DraftChip(
                            icon: Symbols.attach_file,
                            label: '$attachmentCount',
                          ),
                        if (publisher != null)
                          _DraftChip(
                            icon: Symbols.person,
                            label: publisher.nick.isNotEmpty
                                ? publisher.nick
                                : publisher.name,
                          ),
                        if (updatedAt != null)
                          _DraftChip(
                            icon: Symbols.schedule,
                            label: updatedAt.formatSystem(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.isLocalOnly)
                    IconButton(
                      tooltip: 'draftUploadToCloud'.tr(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Symbols.cloud_upload, size: 20),
                      onPressed: () => _upload(ref, context),
                    ),
                  PopupMenuButton<_DraftAction>(
                    tooltip: 'more'.tr(),
                    icon: const Icon(Symbols.more_vert),
                    onSelected: (action) async {
                      switch (action) {
                        case _DraftAction.edit:
                          await _openComposer(context, ref);
                        case _DraftAction.upload:
                          await _upload(ref, context);
                        case _DraftAction.publishNow:
                          await _publishNow(ref, context);
                        case _DraftAction.unschedule:
                          await _unschedule(ref, context);
                        case _DraftAction.delete:
                          await _delete(ref, context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _DraftAction.edit,
                        child: _DraftMenuRow(
                          icon: Symbols.edit,
                          label: 'edit'.tr(),
                        ),
                      ),
                      if (entry.isLocalOnly)
                        PopupMenuItem(
                          value: _DraftAction.upload,
                          child: _DraftMenuRow(
                            icon: Symbols.cloud_upload,
                            label: 'draftUploadToCloud'.tr(),
                          ),
                        ),
                      if (entry.isScheduled)
                        PopupMenuItem(
                          value: _DraftAction.publishNow,
                          child: _DraftMenuRow(
                            icon: Symbols.send,
                            label: 'postPublishNow'.tr(),
                          ),
                        ),
                      if (entry.isScheduled)
                        PopupMenuItem(
                          value: _DraftAction.unschedule,
                          child: _DraftMenuRow(
                            icon: Symbols.event_busy,
                            label: 'draftUnschedule'.tr(),
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: _DraftAction.delete,
                        child: _DraftMenuRow(
                          icon: Symbols.delete,
                          label: 'deleteDraft'.tr(),
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DraftAction { edit, upload, publishNow, unschedule, delete }

class _DraftMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DraftMenuRow({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const Gap(10),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: color != null ? TextStyle(color: color) : null,
          ),
        ),
      ],
    );
  }
}

class _DraftChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _DraftChip({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = foregroundColor ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const Gap(4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
