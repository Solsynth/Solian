import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/meet_service.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

final composeMeetsProvider = FutureProvider.autoDispose<List<SnMeet>>(
  (ref) async {
    final service = ref.watch(meetServiceProvider);
    return service.listMeets(hostOnly: false, offset: 0, take: 50);
  },
);

class ComposeMeetSheet extends ConsumerWidget {
  const ComposeMeetSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetsAsync = ref.watch(composeMeetsProvider);

    return SheetScaffold(
      titleText: 'selectMeet'.tr(),
      heightFactor: 0.75,
      child: meetsAsync.when(
        data: (meets) {
          if (meets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.groups,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noMeets'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: meets.length,
            itemBuilder: (context, index) {
              final meet = meets[index];
              return _MeetListItem(
                meet: meet,
                onTap: () => Navigator.pop(context, meet.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('errorGeneric'.tr(args: [e.toString()])),
        ),
      ),
    );
  }
}

class _MeetListItem extends StatelessWidget {
  final SnMeet meet;
  final VoidCallback onTap;

  const _MeetListItem({required this.meet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Symbols.groups,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            meet.notes ?? 'untitledMeet'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MeetStatusBadge(status: meet.status),
                      ],
                    ),
                    if (meet.host != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        meet.host!.nick,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (meet.locationName != null ||
                        meet.locationAddress != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Symbols.location_on,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meet.locationName ?? meet.locationAddress!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (meet.participants.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Symbols.person,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meet.participants.length} ${'participants'.tr()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeetStatusBadge extends StatelessWidget {
  final SnMeetStatus status;

  const _MeetStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg, String label) = switch (status) {
      SnMeetStatus.active => (Colors.green.withOpacity(0.15), Colors.green, 'active'.tr()),
      SnMeetStatus.completed => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer, 'completed'.tr()),
      SnMeetStatus.expired => (colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant, 'expired'.tr()),
      SnMeetStatus.cancelled => (colorScheme.errorContainer, colorScheme.onErrorContainer, 'cancelled'.tr()),
      SnMeetStatus.unknown => (colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant, 'unknown'.tr()),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
