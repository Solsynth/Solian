import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final tabController = useTabController(
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
      actions: [
        IconButton(
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
          TabBar(
            controller: tabController,
            tabs: [
              Tab(icon: const Icon(Symbols.star), text: 'award'.tr()),
              Tab(icon: const Icon(Symbols.trending_up), text: 'sponsor'.tr()),
            ],
            tabAlignment: TabAlignment.fill,
          ),
          const Divider(height: 1),
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

class _AwardHistoryBody extends StatelessWidget {
  final String postId;
  const _AwardHistoryBody({required this.postId});

  @override
  Widget build(BuildContext context) {
    final provider = postAwardListNotifierProvider(postId);
    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      itemBuilder: (context, index, award) => PostAwardItem(award: award),
      seperatorBuilder: (_, _, _) => const Divider(height: 1),
    );
  }
}

class _SponsorHistoryBody extends StatelessWidget {
  final String postId;
  const _SponsorHistoryBody({required this.postId});

  @override
  Widget build(BuildContext context) {
    final provider = postSponsorBidListNotifierProvider(postId);
    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      itemBuilder: (context, index, bid) => PostSponsorBidItem(bid: bid),
      seperatorBuilder: (_, _, _) => const Divider(height: 1),
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
    final color = _getAttitudeColor(award.attitude, context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(_getAttitudeIcon(award.attitude), color: color),
      ),
      title: Text(
        'awardPoints'.tr(args: [award.amount.toStringAsFixed(0)]),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getAttitudeText(award.attitude),
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          if (award.message != null && award.message!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(award.message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (award.createdAt != null) ...[
            const SizedBox(height: 2),
            Text(
              award.createdAt!.toLocal().toString().split('.')[0],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      isThreeLine: award.message != null && award.message!.isNotEmpty,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class PostSponsorBidItem extends StatelessWidget {
  final SnPostSponsorBid bid;

  const PostSponsorBidItem({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.tertiaryContainer,
        child: Icon(
          Symbols.trending_up,
          color: colorScheme.onTertiaryContainer,
        ),
      ),
      title: Text(
        'sponsorBidAmount'.tr(args: [bid.amount.toStringAsFixed(0)]),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bid.expiresAt != null)
            Text(
              'sponsorBidExpires'.tr(
                args: [bid.expiresAt!.toLocal().toString().split('.')[0]],
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (bid.createdAt != null) ...[
            const SizedBox(height: 2),
            Text(
              bid.createdAt!.toLocal().toString().split('.')[0],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
