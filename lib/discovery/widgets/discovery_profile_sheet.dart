import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

final discoveryProfileProvider = FutureProvider.autoDispose<SnDiscoveryProfile>(
  (ref) async {
    final client = ref.watch(apiClientProvider);
    final response = await client.get('/sphere/timeline/discovery/profile');
    return SnDiscoveryProfile.fromJson(response.data as Map<String, dynamic>);
  },
);

final discoveryProfileResetProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  final client = ref.watch(apiClientProvider);
  await client.post('/sphere/timeline/discovery/reset');
  return true;
});

void showDiscoveryProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (sheetContext) {
      return SheetScaffold(
        titleText: 'Discovery Profile',
        heightFactor: 0.7,
        child: const _DiscoveryProfileContent(),
      );
    },
  );
}

class _DiscoveryProfileContent extends ConsumerStatefulWidget {
  const _DiscoveryProfileContent();

  @override
  ConsumerState<_DiscoveryProfileContent> createState() =>
      _DiscoveryProfileContentState();
}

class _DiscoveryProfileContentState
    extends ConsumerState<_DiscoveryProfileContent> {
  bool _isResetting = false;

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rebuild Profile'),
        content: const Text(
          'This will reset your discovery profile. '
          'New recommendations will be generated based on your future activity.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Rebuild'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isResetting = true);
    try {
      await ref.read(discoveryProfileResetProvider.future);
      ref.invalidate(discoveryProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discovery profile reset successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to reset: $e')));
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(discoveryProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(error: error),
      data: (profile) => _ProfileView(
        profile: profile,
        isResetting: _isResetting,
        onReset: _handleReset,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const Gap(12),
            Text(
              'Failed to load discovery profile',
              style: theme.textTheme.bodyLarge,
            ),
            const Gap(4),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final SnDiscoveryProfile profile;
  final bool isResetting;
  final VoidCallback onReset;

  const _ProfileView({
    required this.profile,
    required this.isResetting,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final interests = profile.interests;
    final publishers = profile.suggestedPublishers;
    final accounts = profile.suggestedAccounts;
    final realms = profile.suggestedRealms;
    final suppressed = profile.suppressed;
    final hasAnyData =
        interests.isNotEmpty ||
        publishers.isNotEmpty ||
        accounts.isNotEmpty ||
        realms.isNotEmpty ||
        suppressed.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Header row: timestamp + reset button
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Symbols.schedule,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const Gap(6),
                  Flexible(
                    child: Text(
                      DateFormat.yMMMd().add_Hms().format(profile.generatedAt),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Tooltip(
              message: 'Rebuild your discovery profile from scratch',
              child: FilledButton.tonalIcon(
                onPressed: isResetting ? null : onReset,
                icon: isResetting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Symbols.refresh, size: 18),
                label: const Text('Rebuild'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: theme.textTheme.labelMedium,
                ),
              ),
            ),
          ],
        ),
        const Gap(20),

        if (!hasAnyData)
          _EmptyState()
        else ...[
          if (interests.isNotEmpty) ...[
            _SectionHeader(
              icon: Symbols.interests,
              title: 'Interests',
              count: interests.length,
            ),
            const Gap(8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: interests
                      .map((interest) => _InterestTile(interest: interest))
                      .toList(),
                ),
              ),
            ),
            const Gap(16),
          ],
          if (publishers.isNotEmpty) ...[
            _SectionHeader(
              icon: Symbols.account_circle,
              title: 'Suggested Publishers',
              count: publishers.length,
            ),
            const Gap(8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: publishers
                      .map(
                        (item) => _SuggestionTile(
                          label: item.label,
                          score: item.score,
                          reasons: item.reasons,
                          subtitle: item.data['nick'] ?? '',
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Gap(16),
          ],
          if (accounts.isNotEmpty) ...[
            _SectionHeader(
              icon: Symbols.person,
              title: 'Suggested Accounts',
              count: accounts.length,
            ),
            const Gap(8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: accounts
                      .map(
                        (item) => _SuggestionTile(
                          label: item.label,
                          score: item.score,
                          reasons: item.reasons,
                          subtitle: '@${item.data['name'] ?? ''}',
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Gap(16),
          ],
          if (realms.isNotEmpty) ...[
            _SectionHeader(
              icon: Symbols.public,
              title: 'Suggested Realms',
              count: realms.length,
            ),
            const Gap(8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: realms
                      .map(
                        (item) => _SuggestionTile(
                          label: item.label,
                          score: item.score,
                          reasons: item.reasons,
                          subtitle: item.data['name'] ?? '',
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Gap(16),
          ],
          if (suppressed.isNotEmpty) ...[
            _SectionHeader(
              icon: Symbols.block,
              title: 'Suppressed',
              count: suppressed.length,
            ),
            const Gap(8),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${suppressed.length} item(s) suppressed from your timeline.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Symbols.psychology,
            size: 40,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const Gap(12),
          Text(
            'No profile data yet',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(4),
          Text(
            'Interact with posts, publishers, and realms to build your profile.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const Gap(8),
        Text(title, style: theme.textTheme.titleSmall),
        const Gap(6),
        Text(
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ).padding(horizontal: 6);
  }
}

class _InterestTile extends StatelessWidget {
  final SnDiscoveryInterest interest;
  const _InterestTile({required this.interest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scorePercent = (interest.score * 100)
        .clamp(0, 100)
        .toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(interest.label, style: theme.textTheme.bodyMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: interest.score.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
              const Gap(6),
              Text(
                '$scorePercent% · ${interest.interactionCount} interactions · ${interest.lastSignalType}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String label;
  final double score;
  final List<String> reasons;
  final String subtitle;

  const _SuggestionTile({
    required this.label,
    required this.score,
    required this.reasons,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scorePercent = (score * 100).clamp(0, 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(label, style: theme.textTheme.bodyMedium),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: reasons.isNotEmpty
            ? Tooltip(
                message: reasons.join(', '),
                child: Text(
                  '$scorePercent%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
