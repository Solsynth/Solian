import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/shared/hooks/material_hooks.dart' as material_hooks;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The kind of post support a user can give.
enum SupportMode { award, sponsor }

// ==========================================
// Awards
// ==========================================

final postAwardListNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  PostAwardListNotifier.new,
);

class PostAwardListNotifier extends AsyncNotifier<PaginationState<SnPostAward>>
    with AsyncPaginationController<SnPostAward> {
  static const int pageSize = 20;

  final String arg;
  PostAwardListNotifier(this.arg);

  @override
  Future<List<SnPostAward>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    // Note: PostsApi.getPostAwards doesn't support pagination parameters
    // We fall back to raw Dio call for pagination
    final queryParams = {'offset': fetchedCount, 'take': pageSize};

    final response = await client.dio.get(
      '/sphere/posts/$arg/awards',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnPostAward.fromJson(json)).toList();
  }
}

// ==========================================
// Sponsorship
// ==========================================

/// A single sponsorship bid placed on a post.
///
/// Mirrors `SnPostSponsorBid` from the Sphere service. Bid records are private:
/// only the bidder and the post's author can read them.
class SnPostSponsorBid {
  final String id;
  final String postId;
  final String accountId;
  final double amount;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const SnPostSponsorBid({
    required this.id,
    required this.postId,
    required this.accountId,
    required this.amount,
    this.expiresAt,
    this.createdAt,
  });

  factory SnPostSponsorBid.fromJson(Map<String, dynamic> json) {
    return SnPostSponsorBid(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      accountId: json['account_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

final postSponsorBidListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family(PostSponsorBidListNotifier.new);

class PostSponsorBidListNotifier
    extends AsyncNotifier<PaginationState<SnPostSponsorBid>>
    with AsyncPaginationController<SnPostSponsorBid> {
  static const int pageSize = 20;

  final String arg;
  PostSponsorBidListNotifier(this.arg);

  @override
  Future<List<SnPostSponsorBid>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final queryParams = {'offset': fetchedCount, 'take': pageSize};

    final response = await client.dio.get(
      '/sphere/posts/$arg/sponsor/history',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => SnPostSponsorBid.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Total active sponsorship amount for a post. Public endpoint.
final postSponsorTotalProvider = FutureProvider.autoDispose
    .family<double, String>((ref, postId) async {
      final client = ref.read(solarNetworkClientProvider);
      try {
        final response = await client.dio.get('/sphere/posts/$postId/sponsor');
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return (data['total_amount'] as num?)?.toDouble() ?? 0;
        }
        return 0;
      } catch (_) {
        return 0;
      }
    });

// ==========================================
// Unified history sheet
// ==========================================

class PostSupportHistorySheet extends HookConsumerWidget {
  final String postId;
  final SupportMode initialMode;

  const PostSupportHistorySheet({
    super.key,
    required this.postId,
    this.initialMode = SupportMode.award,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = material_hooks.useMaterialTabController(
      initialLength: 2,
      initialIndex: initialMode == SupportMode.sponsor ? 1 : 0,
    );
    final activeMode = useState<SupportMode>(initialMode);

    // Keep the refresh target in sync with the active tab.
    useEffect(() {
      void listener() {
        activeMode.value = tabController.index == 1
            ? SupportMode.sponsor
            : SupportMode.award;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return SheetScaffold(
      titleText: 'supportHistory'.tr(),
      heightFactor: 0.88,
      actions: [
        IconButton(
          tooltip: 'refresh'.tr(),
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            switch (activeMode.value) {
              case SupportMode.award:
                ref.invalidate(postAwardListNotifierProvider(postId));
              case SupportMode.sponsor:
                ref.invalidate(postSponsorBidListNotifierProvider(postId));
            }
          },
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: TabBar(
                controller: tabController,
                tabs: [
                  Tab(
                    icon: const Icon(Symbols.star, size: 19),
                    text: 'award'.tr(),
                  ),
                  Tab(
                    icon: const Icon(Symbols.trending_up, size: 19),
                    text: 'sponsor'.tr(),
                  ),
                ],
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
                splashBorderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _AwardHistoryBody(postId: postId),
                _SponsorHistoryBody(postId: postId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AwardHistoryBody extends HookConsumerWidget {
  final String postId;
  const _AwardHistoryBody({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postAwardListNotifierProvider(postId);
    final data = ref.watch(provider);
    final state = data.value;
    final count = state?.totalCount ?? state?.items.length ?? 0;

    return Column(
      children: [
        _HistoryOverview(
          icon: Symbols.star,
          accent: Theme.of(context).colorScheme.primary,
          stat: 'awardCount'.tr(args: ['$count']),
        ),
        Expanded(
          child:
              state != null &&
                  !data.isLoading &&
                  !data.hasError &&
                  state.items.isEmpty
              ? _HistoryEmptyState(
                  icon: Symbols.star_outline,
                  message: 'noAwardsYet'.tr(),
                )
              : PaginationList(
                  provider: provider,
                  notifier: provider.notifier,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  spacing: 10,
                  itemBuilder: (context, index, award) =>
                      PostAwardItem(award: award),
                ),
        ),
      ],
    );
  }
}

class _SponsorHistoryBody extends HookConsumerWidget {
  final String postId;
  const _SponsorHistoryBody({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postSponsorBidListNotifierProvider(postId);
    final data = ref.watch(provider);
    final total = ref.watch(postSponsorTotalProvider(postId));
    final state = data.value;
    final amount = total.maybeWhen(
      data: (value) => value.toStringAsFixed(0),
      orElse: () => '—',
    );

    return Column(
      children: [
        _HistoryOverview(
          icon: Symbols.trending_up,
          accent: Theme.of(context).colorScheme.tertiary,
          stat: 'sponsorBidAmount'.tr(args: [amount]),
        ),
        Expanded(
          child:
              state != null &&
                  !data.isLoading &&
                  !data.hasError &&
                  state.items.isEmpty
              ? _HistoryEmptyState(
                  icon: Symbols.trending_up,
                  message: 'sponsorHistoryEmpty'.tr(),
                )
              : PaginationList(
                  provider: provider,
                  notifier: provider.notifier,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  spacing: 10,
                  itemBuilder: (context, index, bid) =>
                      PostSponsorBidItem(bid: bid),
                ),
        ),
      ],
    );
  }
}

class _HistoryOverview extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String stat;

  const _HistoryOverview({
    required this.icon,
    required this.accent,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 2),
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const Gap(10),
          Text(
            stat,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            'supportHistory'.tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _HistoryEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
            ),
            const Gap(14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Item widgets
// ==========================================

class PostAwardItem extends StatelessWidget {
  final SnPostAward award;

  const PostAwardItem({super.key, required this.award});

  String _getAttitudeText(int attitude) {
    switch (attitude) {
      case 0:
        return 'awardAttitudePositive'.tr();
      case 2:
        return 'awardAttitudeNegative'.tr();
      default:
        return 'awardAttitudePositive'.tr();
    }
  }

  Color _getAttitudeColor(int attitude, BuildContext context) {
    switch (attitude) {
      case 0:
        return Theme.of(context).colorScheme.primary;
      case 2:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getAttitudeIcon(int attitude) {
    switch (attitude) {
      case 0:
        return Symbols.thumb_up;
      case 2:
        return Symbols.thumb_down;
      default:
        return Symbols.thumbs_up_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getAttitudeColor(award.attitude, context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getAttitudeIcon(award.attitude),
                    size: 17,
                    color: color,
                  ),
                ),
                const Gap(9),
                Expanded(
                  child: Text(
                    'awardPoints'.tr(args: [award.amount.toStringAsFixed(0)]),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _getAttitudeText(award.attitude),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (award.message != null && award.message!.isNotEmpty) ...[
              const Gap(10),
              Text(
                award.message!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
            if (award.createdAt != null) ...[
              const Gap(9),
              _HistoryDate(date: award.createdAt!),
            ],
          ],
        ),
      ),
    );
  }
}

class PostSponsorBidItem extends StatelessWidget {
  final SnPostSponsorBid bid;

  const PostSponsorBidItem({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.tertiary;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Symbols.trending_up, size: 18, color: color),
                ),
                const Gap(9),
                Expanded(
                  child: Text(
                    'sponsorBidAmount'.tr(
                      args: [bid.amount.toStringAsFixed(0)],
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (bid.expiresAt != null) ...[
              const Gap(9),
              Text(
                'sponsorBidExpires'.tr(
                  args: [bid.expiresAt!.toLocal().toString().split('.')[0]],
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (bid.createdAt != null) ...[
              const Gap(8),
              _HistoryDate(date: bid.createdAt!),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryDate extends StatelessWidget {
  final DateTime date;

  const _HistoryDate({required this.date});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Symbols.schedule, size: 14, color: color),
        const Gap(5),
        Text(
          date.toLocal().toString().split('.')[0],
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
