import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'pub_profile.g.dart';

@riverpod
Future<SnPublisher> publisher(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/publishers/$uname");
  return SnPublisher.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> publisherBadges(Ref ref, String pubName) async {
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.type != 0) return [];
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/accounts/${pub.name}/badges");
  return List<SnAccountBadge>.from(
    resp.data.map((x) => SnAccountBadge.fromJson(x)),
  );
}

@riverpod
Future<SnSubscriptionStatus> publisherSubscriptionStatus(
  Ref ref,
  String pubName,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/publishers/$pubName/subscription");
  return SnSubscriptionStatus.fromJson(resp.data);
}

@RoutePage()
class PublisherProfileScreen extends HookConsumerWidget {
  final String name;
  const PublisherProfileScreen({
    super.key,
    @PathParam("name") required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));
    final badges = ref.watch(publisherBadgesProvider(name));
    final subStatus = ref.watch(publisherSubscriptionStatusProvider(name));

    final subscribing = useState(false);

    Future<void> subscribe() async {
      final apiClient = ref.watch(apiClientProvider);
      subscribing.value = true;
      try {
        await apiClient.post("/publishers/$name/subscribe", data: {'tier': 0});
        ref.invalidate(publisherSubscriptionStatusProvider(name));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    Future<void> unsubscribe() async {
      final apiClient = ref.watch(apiClientProvider);
      subscribing.value = true;
      try {
        await apiClient.post("/publishers/$name/unsubscribe");
        ref.invalidate(publisherSubscriptionStatusProvider(name));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    final iconShadow = Shadow(
      color: Colors.black54,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return publisher.when(
      data:
          (data) => AppScaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  leading: PageBackButton(shadows: [iconShadow]),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        data.backgroundId != null
                            ? CloudImageWidget(fileId: data.backgroundId!)
                            : Container(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                    title: Text(
                      data.nick,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        shadows: [iconShadow],
                      ),
                    ),
                  ),
                  actions: [
                    subStatus.when(
                      data:
                          (status) => IconButton(
                            onPressed:
                                subscribing.value
                                    ? null
                                    : (status.isSubscribed
                                        ? unsubscribe
                                        : subscribe),
                            icon: Icon(
                              status.isSubscribed
                                  ? Icons.remove_circle
                                  : Icons.add_circle,
                              shadows: [iconShadow],
                            ),
                          ),
                      error: (_, __) => const SizedBox(),
                      loading:
                          () => const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                    ),
                    const Gap(8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      ProfilePictureWidget(fileId: data.pictureId!, radius: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Text(data.nick).fontSize(20),
                                Text(
                                  '@${data.name}',
                                ).fontSize(14).opacity(0.85),
                              ],
                            ),
                            if (data.type == 0)
                              AccountStatusWidget(
                                uname: name,
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ).padding(horizontal: 24, top: 24, bottom: 24),
                ),
                if (badges.value?.isNotEmpty ?? false)
                  SliverToBoxAdapter(
                    child: BadgeList(
                      badges: badges.value!,
                    ).padding(horizontal: 24, bottom: 24),
                  )
                else
                  const SliverGap(16),
                SliverToBoxAdapter(child: const Divider(height: 1)),
                if (data.bio.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [Text('bio').tr().bold(), Text(data.bio)],
                    ).padding(horizontal: 24, top: 24),
                  ),
                if (data.bio.isNotEmpty)
                  SliverToBoxAdapter(
                    child: const Divider(height: 1).padding(top: 24),
                  ),
                SliverPostList(pubName: name),
                SliverGap(MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
      error:
          (error, stackTrace) => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: Text(error.toString())),
          ),
      loading:
          () => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
