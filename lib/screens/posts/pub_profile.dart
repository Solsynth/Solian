import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/color.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:palette_generator/palette_generator.dart';
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
  if (pub.type != 0 || pub.account == null) return [];
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/accounts/${pub.account!.name}/badges");
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

@riverpod
Future<Color?> publisherAppbarForcegroundColor(Ref ref, String pubName) async {
  final publisher = await ref.watch(publisherProvider(pubName).future);
  if (publisher.background == null) return null;
  final palette = await PaletteGenerator.fromImageProvider(
    CloudImageWidget.provider(
      fileId: publisher.background!.id,
      serverUrl: ref.watch(serverUrlProvider),
    ),
  );
  final dominantColor = palette.dominantColor?.color;
  if (dominantColor == null) return null;
  return dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
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
    final appbarColor = ref.watch(
      publisherAppbarForcegroundColorProvider(name),
    );

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

    final appbarShadow = Shadow(
      color: appbarColor.value?.invert ?? Colors.transparent,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return publisher.when(
      data:
          (data) => AppScaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  foregroundColor: appbarColor.value,
                  expandedHeight: 180,
                  pinned: true,
                  leading: PageBackButton(
                    color: appbarColor.value,
                    shadows: [appbarShadow],
                  ),
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            data.background?.id != null
                                ? CloudImageWidget(file: data.background)
                                : Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).appBarTheme.backgroundColor,
                                ),
                      ),
                      FlexibleSpaceBar(
                        title: Text(
                          data.nick,
                          style: TextStyle(
                            color:
                                appbarColor.value ??
                                Theme.of(context).appBarTheme.foregroundColor,
                            shadows: [appbarShadow],
                          ),
                        ),
                        background:
                            Container(), // Empty container since background is handled by Stack
                      ),
                    ],
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
                              shadows: [appbarShadow],
                            ),
                          ),
                      error: (_, _) => const SizedBox(),
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
                      ProfilePictureWidget(file: data.picture, radius: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Text(data.nick).fontSize(20),
                                if (data.verification != null)
                                  VerificationMark(mark: data.verification!),
                                Text(
                                  '@${data.name}',
                                ).fontSize(14).opacity(0.85),
                              ],
                            ),
                            if (data.type == 0 && data.account != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 6,
                                children: [
                                  Icon(
                                    data.type == 0
                                        ? Symbols.person
                                        : Symbols.workspaces,
                                    fill: 1,
                                    size: 17,
                                  ),
                                  Text(
                                    'publisherBelongsTo'.tr(
                                      args: ['@${data.account!.name}'],
                                    ),
                                  ).fontSize(14),
                                ],
                              ).opacity(0.85).padding(bottom: 6),
                            if (data.type == 0 && data.account != null)
                              AccountStatusWidget(
                                uname: data.account!.name,
                                padding: EdgeInsets.zero,
                              ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.router.pushPath(
                                  '/account/${data.name}',
                                );
                              },
                              icon: const Icon(Symbols.launch),
                              label: Text('accountProfileView').tr(),
                              style: ButtonStyle(
                                visualDensity: VisualDensity(vertical: -2),
                              ),
                            ).padding(top: 8),
                          ],
                        ),
                      ),
                    ],
                  ).padding(horizontal: 24, top: 24),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (badges.value?.isNotEmpty ?? false)
                        BadgeList(badges: badges.value!).padding(top: 16),
                      if (data.verification != null)
                        VerificationStatusCard(
                          mark: data.verification!,
                        ).padding(top: 16),
                    ],
                  ).padding(horizontal: 24),
                ),
                SliverToBoxAdapter(
                  child: const Divider(height: 1).padding(vertical: 24),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('bio').tr().bold(),
                      Text(
                        data.bio.isEmpty ? 'descriptionNone'.tr() : data.bio,
                      ),
                    ],
                  ).padding(horizontal: 24),
                ),
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
