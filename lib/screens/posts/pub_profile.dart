import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/publisher.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/color.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/badge.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'pub_profile.g.dart';

class _PublisherBasisWidget extends StatelessWidget {
  final SnPublisher data;
  final AsyncValue<SnSubscriptionStatus> subStatus;
  final ValueNotifier<bool> subscribing;
  final VoidCallback subscribe;
  final VoidCallback unsubscribe;

  const _PublisherBasisWidget({
    required this.data,
    required this.subStatus,
    required this.subscribing,
    required this.subscribe,
    required this.unsubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        GestureDetector(
          child: Badge(
            isLabelVisible: data.type == 0,
            padding: EdgeInsets.all(4),
            label: Icon(
              Symbols.launch,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            offset: Offset(0, 48),
            child: ProfilePictureWidget(
              file: data.picture,
              radius: 32,
              borderRadius: data.type == 0 ? null : 12,
            ),
          ),
          onTap: () {
            Navigator.pop(context, true);
            if (data.account?.name != null) {
              context.pushNamed(
                'accountProfile',
                pathParameters: {'name': data.account!.name},
              );
            }
          },
        ),
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
                  Expanded(
                    child: Text(
                      '@${data.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).fontSize(14).opacity(0.85),
                  ),
                ],
              ),
              if (data.type == 0 && data.account != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 6,
                  children: [
                    Icon(
                      data.type == 0 ? Symbols.person : Symbols.workspaces,
                      fill: 1,
                      size: 17,
                    ),
                    Text(
                      'publisherBelongsTo'.tr(args: ['@${data.account!.name}']),
                    ).fontSize(14),
                  ],
                ).opacity(0.85),
              const Gap(4),
              if (data.type == 0 && data.account != null)
                AccountStatusWidget(
                  uname: data.account!.name,
                  padding: EdgeInsets.zero,
                ),
              subStatus
                  .when(
                    data:
                        (status) => FilledButton.icon(
                          onPressed:
                              subscribing.value
                                  ? null
                                  : (status.isSubscribed
                                      ? unsubscribe
                                      : subscribe),
                          icon: Icon(
                            status.isSubscribed
                                ? Symbols.remove_circle
                                : Symbols.add_circle,
                          ),
                          label:
                              Text(
                                status.isSubscribed
                                    ? 'unsubscribe'
                                    : 'subscribe',
                              ).tr(),
                          style: ButtonStyle(
                            visualDensity: VisualDensity(vertical: -2),
                          ),
                        ),
                    error: (_, _) => const SizedBox(),
                    loading:
                        () => const SizedBox(
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                  )
                  .padding(top: 8),
            ],
          ),
        ),
      ],
    ).padding(horizontal: 24, top: 24);
  }
}

class _PublisherBadgesWidget extends StatelessWidget {
  final SnPublisher data;
  final AsyncValue<List<SnAccountBadge>> badges;

  const _PublisherBadgesWidget({required this.data, required this.badges});

  @override
  Widget build(BuildContext context) {
    return (badges.value?.isNotEmpty ?? false)
        ? Card(
          child: BadgeList(
            badges: badges.value!,
          ).padding(horizontal: 26, vertical: 20),
        ).padding(horizontal: 4)
        : const SizedBox.shrink();
  }
}

class _PublisherVerificationWidget extends StatelessWidget {
  final SnPublisher data;

  const _PublisherVerificationWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return (data.verification != null)
        ? Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: VerificationStatusCard(mark: data.verification!),
        )
        : const SizedBox.shrink();
  }
}

class _PublisherBioWidget extends StatelessWidget {
  final SnPublisher data;

  const _PublisherBioWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('bio').tr().bold().fontSize(15).padding(bottom: 8),
          if (data.bio.isEmpty)
            Text('descriptionNone').tr().italic()
          else
            MarkdownTextContent(
              content: data.bio,
              linesMargin: EdgeInsets.zero,
            ),
        ],
      ).padding(horizontal: 20, vertical: 16),
    );
  }
}

class _PublisherCategoryTabWidget extends StatelessWidget {
  final TabController categoryTabController;

  const _PublisherCategoryTabWidget({required this.categoryTabController});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TabBar(
        controller: categoryTabController,
        dividerColor: Colors.transparent,
        splashBorderRadius: const BorderRadius.all(Radius.circular(8)),
        tabs: [
          Tab(text: 'all'.tr()),
          Tab(text: 'postTypePost'.tr()),
          Tab(text: 'postArticle'.tr()),
        ],
      ),
    );
  }
}

@riverpod
Future<SnPublisher> publisher(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/sphere/publishers/$uname");
  return SnPublisher.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> publisherBadges(Ref ref, String pubName) async {
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.type != 0 || pub.account == null) return [];
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/id/accounts/${pub.account!.name}/badges");
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
  final resp = await apiClient.get("/sphere/publishers/$pubName/subscription");
  return SnSubscriptionStatus.fromJson(resp.data);
}

@riverpod
Future<Color?> publisherAppbarForcegroundColor(Ref ref, String pubName) async {
  try {
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
  } catch (_) {
    return null;
  }
}

class PublisherProfileScreen extends HookConsumerWidget {
  final String name;
  const PublisherProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));
    final badges = ref.watch(publisherBadgesProvider(name));
    final subStatus = ref.watch(publisherSubscriptionStatusProvider(name));
    final appbarColor = ref.watch(
      publisherAppbarForcegroundColorProvider(name),
    );

    final categoryTabController = useTabController(initialLength: 3);
    final categoryTab = useState(0);
    categoryTabController.addListener(() {
      categoryTab.value = categoryTabController.index;
    });

    final subscribing = useState(false);

    Future<void> subscribe() async {
      final apiClient = ref.watch(apiClientProvider);
      subscribing.value = true;
      try {
        await apiClient.post(
          "/sphere/publishers/$name/subscribe",
          data: {'tier': 0},
        );
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
        await apiClient.post("/sphere/publishers/$name/unsubscribe");
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
            isNoBackground: false,
            appBar:
                isWideScreen(context)
                    ? AppBar(
                      foregroundColor: appbarColor.value,
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
                                    Theme.of(
                                      context,
                                    ).appBarTheme.foregroundColor,
                                shadows: [appbarShadow],
                              ),
                            ),
                            background:
                                Container(), // Empty container since background is handled by Stack
                          ),
                        ],
                      ),
                    )
                    : null,
            body:
                isWideScreen(context)
                    ? Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: CustomScrollView(
                            slivers: [
                              SliverGap(16),
                              SliverPostList(pubName: name, pinned: true),
                              SliverToBoxAdapter(
                                child: _PublisherCategoryTabWidget(
                                  categoryTabController: categoryTabController,
                                ),
                              ),
                              SliverPostList(
                                key: ValueKey(categoryTab.value),
                                pubName: name,
                                pinned: false,
                                type: switch (categoryTab.value) {
                                  1 => 0,
                                  2 => 1,
                                  _ => null,
                                },
                              ),
                              SliverGap(
                                MediaQuery.of(context).padding.bottom + 16,
                              ),
                            ],
                          ).padding(left: 8),
                        ),
                        Flexible(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _PublisherBasisWidget(
                                    data: data,
                                    subStatus: subStatus,
                                    subscribing: subscribing,
                                    subscribe: subscribe,
                                    unsubscribe: unsubscribe,
                                  ).padding(bottom: 8),
                                  _PublisherBadgesWidget(
                                    data: data,
                                    badges: badges,
                                  ),
                                  _PublisherVerificationWidget(data: data),
                                  _PublisherBioWidget(data: data),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : CustomScrollView(
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
                                        ? CloudImageWidget(
                                          file: data.background,
                                        )
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
                                        Theme.of(
                                          context,
                                        ).appBarTheme.foregroundColor,
                                    shadows: [appbarShadow],
                                  ),
                                ),
                                background:
                                    Container(), // Empty container since background is handled by Stack
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _PublisherBasisWidget(
                            data: data,
                            subStatus: subStatus,
                            subscribing: subscribing,
                            subscribe: subscribe,
                            unsubscribe: unsubscribe,
                          ).padding(bottom: 8),
                        ),
                        SliverToBoxAdapter(
                          child: _PublisherBadgesWidget(
                            data: data,
                            badges: badges,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _PublisherVerificationWidget(data: data),
                        ),
                        SliverToBoxAdapter(
                          child: _PublisherBioWidget(data: data),
                        ),
                        SliverPostList(pubName: name, pinned: true),
                        SliverToBoxAdapter(
                          child: _PublisherCategoryTabWidget(
                            categoryTabController: categoryTabController,
                          ),
                        ),
                        SliverPostList(
                          key: ValueKey(categoryTab.value),
                          pubName: name,
                          pinned: false,
                          type: switch (categoryTab.value) {
                            1 => 0,
                            2 => 1,
                            _ => null,
                          },
                        ),
                        SliverGap(MediaQuery.of(context).padding.bottom + 16),
                      ],
                    ),
          ),
      error:
          (error, stackTrace) => AppScaffold(
            isNoBackground: false,
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: Text(error.toString())),
          ),
      loading:
          () => AppScaffold(
            isNoBackground: false,
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
