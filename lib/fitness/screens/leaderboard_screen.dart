import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.daily;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  LeaderboardType get _currentType {
    switch (_tabController.index) {
      case 0:
        return LeaderboardType.calories;
      case 1:
        return LeaderboardType.workouts;
      case 2:
        return LeaderboardType.goals;
      default:
        return LeaderboardType.calories;
    }
  }

  String _getPeriodLabel(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.daily:
        return 'Today';
      case LeaderboardPeriod.weekly:
        return 'This Week';
      case LeaderboardPeriod.monthly:
        return 'This Month';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }

  Widget _buildPeriodSelector() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SegmentedButton<LeaderboardPeriod>(
          segments: LeaderboardPeriod.values
              .map(
                (period) => ButtonSegment(
                  value: period,
                  label: Text(_getPeriodLabel(period)),
                ),
              )
              .toList(),
          selected: {_selectedPeriod},
          onSelectionChanged: (selection) {
            setState(() => _selectedPeriod = selection.first);
          },
        ),
      ),
    ).padding(bottom: 12);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'Leaderboard',
      onClose: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Calories'),
                Tab(text: 'Workouts'),
                Tab(text: 'Goals'),
              ],
            ),
          ),
          _buildPeriodSelector(),
          Expanded(
            child: _LeaderboardList(
              type: _currentType,
              period: _selectedPeriod,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  final LeaderboardType type;
  final LeaderboardPeriod period;

  const _LeaderboardList({required this.type, required this.period});

  String _getUnit() {
    switch (type) {
      case LeaderboardType.calories:
        return 'cal';
      case LeaderboardType.workouts:
        return 'workouts';
      case LeaderboardType.goals:
        return 'goals';
    }
  }

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
      leaderboardProvider((type: type, period: period, skip: 0, take: 20)),
    );

    return leaderboardAsync.when(
      data: (response) {
        if (response.entries.isEmpty && response.userEntry == null) {
          return const Center(child: Text('No entries yet'));
        }

        final userEntry = response.userEntry;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: response.entries.length,
                itemBuilder: (context, index) {
                  final entry = response.entries[index];
                  return _buildEntry(context, entry, index + 1);
                },
              ),
            ),
            if (userEntry != null) _buildUserEntryPinned(context, userEntry),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEntry(BuildContext context, LeaderboardEntry entry, int rank) {
    final Color? rankColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        break;
      default:
        rankColor = null;
    }

    final account = entry.account;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Badge(
            backgroundColor: rankColor,
            textColor: rankColor != null
                ? Colors.black
                : Theme.of(context).colorScheme.onSurface,
            label: Text(_getOrdinal(rank)),
            offset: const Offset(8, 28),
            child: account != null
                ? ProfilePictureWidget(file: account.profile.picture)
                : CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Text(rank.toString()),
                  ),
          ),
        ),
        title: account != null
            ? AccountName(account: account)
            : Text(entry.accountId.substring(0, 8)),
        subtitle: account != null ? Text('@${account.name}') : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              entry.value.toInt().toString(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              _getUnit(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEntryPinned(BuildContext context, LeaderboardEntry entry) {
    final account = entry.account;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Badge(
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
            label: Text(_getOrdinal(entry.rank)),
            offset: const Offset(8, 28),
            child: account != null
                ? ProfilePictureWidget(
                    file: account.profile.picture,
                    radius: 18,
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      entry.rank.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Rank',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (account != null)
                  AccountName(
                    account: account,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                else
                  Text(
                    entry.accountId.substring(0, 8),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                entry.value.toInt().toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _getUnit(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
