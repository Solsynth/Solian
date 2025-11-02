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
import 'package:island/models/heatmap.dart';
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
import 'package:island/widgets/activity_heatmap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/services/color_extraction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'publisher_profile.g.dart';

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
    return Card(
      child: Builder(
        builder: (context) {
          final hasBackground = data.background?.id != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWideScreen(context) && hasBackground)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: CloudImageWidget(
                          file: data.background,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -24,
                      left: 16,
                      child: ProfilePictureWidget(
                        file: data.picture,
                        radius: 32,
                        borderRadius: data.type == 0 ? null : 12,
                      ),
                    ),
                  ],
                ),
              Builder(
                builder: (context) {
                  final showBackground = isWideScreen(context) && hasBackground;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: showBackground ? 0 : 20,
                    children: [
                      if (!showBackground)
                        GestureDetector(
                          child: Badge(
                            isLabelVisible: data.type == 0,
                            padding: EdgeInsets.all(4),
                            label: Icon(
                              Symbols.launch,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            offset: Offset(0, 48),
                            child: ProfilePictureWidget(
                              file: data.picture,
                              radius: 32,
                              borderRadius: data.type == 0 ? null : 12,
                            ),
                          ),
                          onTap: () {
                            if (data.account?.name != null) {
                              Navigator.pop(context, true);
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
                                if (data.account != null && data.type == 0)
                                  AccountName(
                                    account: data.account!,
                                    textOverride: data.nick,
                                    hideVerificationMark: true,
                                    style: TextStyle(fontSize: 20),
                                  )
                                else
                                  Text(data.nick).fontSize(20),
                                if (data.verification != null)
                                  VerificationMark(mark: data.verification!),
                                if (isWideScreen(context))
                                  Expanded(
                                    child: Text(
                                      '@${data.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).fontSize(14).opacity(0.85),
                                  ),
                              ],
                            ),
                            if (!isWideScreen(context))
                              Text(
                                '@${data.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).fontSize(14).opacity(0.85).padding(bottom: 2.5),
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
                                          visualDensity: VisualDensity(
                                            vertical: -2,
                                          ),
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
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                )
                                .padding(vertical: 12),
                          ],
                        ),
                      ),
                    ],
                  ).padding(
                    left: 16,
                    right: 16,
                    top: 16 + (showBackground ? 16 : 0),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
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

class _PublisherHeatmapWidget extends StatelessWidget {
  final AsyncValue<SnHeatmap?> heatmap;
  final bool forceDense;

  const _PublisherHeatmapWidget({
    required this.heatmap,
    this.forceDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return heatmap.when(
      data:
          (data) =>
              data != null
                  ? ActivityHeatmapWidget(
                    heatmap: data,
                    forceDense: forceDense,
                  ).padding(horizontal: 8)
                  : const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PublisherCategoryTabWidget extends StatelessWidget {
  final TabController categoryTabController;
  final ValueNotifier<bool?> includeReplies;
  final ValueNotifier<bool> mediaOnly;
  final ValueNotifier<String?> queryTerm;
  final ValueNotifier<String?> order;
  final ValueNotifier<bool> orderDesc;
  final ValueNotifier<int?> periodStart;
  final ValueNotifier<int?> periodEnd;
  final ValueNotifier<bool> showAdvancedFilters;

  const _PublisherCategoryTabWidget({
    required this.categoryTabController,
    required this.includeReplies,
    required this.mediaOnly,
    required this.queryTerm,
    required this.order,
    required this.orderDesc,
    required this.periodStart,
    required this.periodEnd,
    required this.showAdvancedFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          TabBar(
            controller: categoryTabController,
            dividerColor: Colors.transparent,
            splashBorderRadius: const BorderRadius.all(Radius.circular(8)),
            tabs: [
              Tab(text: 'all'.tr()),
              Tab(text: 'postTypePost'.tr()),
              Tab(text: 'postArticle'.tr()),
            ],
          ),
          const Divider(height: 1),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('reply'.tr()),
                      value: includeReplies.value,
                      tristate: true,
                      onChanged: (value) {
                        // Cycle through: null -> false -> true -> null
                        if (includeReplies.value == null) {
                          includeReplies.value = false;
                        } else if (includeReplies.value == false) {
                          includeReplies.value = true;
                        } else {
                          includeReplies.value = null;
                        }
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: const Icon(Symbols.reply),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('attachments'.tr()),
                      value: mediaOnly.value,
                      onChanged: (value) {
                        if (value != null) {
                          mediaOnly.value = value;
                        }
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: const Icon(Symbols.attachment),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: Text('descendingOrder'.tr()),
                value: orderDesc.value,
                onChanged: (value) {
                  if (value != null) {
                    orderDesc.value = value;
                  }
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                secondary: const Icon(Symbols.sort),
              ),
            ],
          ),
          const Divider(height: 1),
          ListTile(
            title: Text('advancedFilters'.tr()),
            leading: const Icon(Symbols.filter_list),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(const Radius.circular(8)),
            ),
            trailing: Icon(
              showAdvancedFilters.value
                  ? Symbols.expand_less
                  : Symbols.expand_more,
            ),
            onTap: () {
              showAdvancedFilters.value = !showAdvancedFilters.value;
            },
          ),
          if (showAdvancedFilters.value) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'search'.tr(),
                      hintText: 'searchPosts'.tr(),
                      prefixIcon: const Icon(Symbols.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      queryTerm.value = value.isEmpty ? null : value;
                    },
                  ),
                  const Gap(12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'sortBy'.tr(),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: order.value,
                    items: [
                      DropdownMenuItem(value: 'date', child: Text('date'.tr())),
                      DropdownMenuItem(
                        value: 'popularity',
                        child: Text('popularity'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      order.value = value;
                    },
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  periodStart.value != null
                                      ? DateTime.fromMillisecondsSinceEpoch(
                                        periodStart.value! * 1000,
                                      )
                                      : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              periodStart.value =
                                  pickedDate.millisecondsSinceEpoch ~/ 1000;
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'fromDate'.tr(),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon: const Icon(Symbols.calendar_today),
                            ),
                            child: Text(
                              periodStart.value != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                    periodStart.value! * 1000,
                                  ).toString().split(' ')[0]
                                  : 'selectDate'.tr(),
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  periodEnd.value != null
                                      ? DateTime.fromMillisecondsSinceEpoch(
                                        periodEnd.value! * 1000,
                                      )
                                      : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              periodEnd.value =
                                  pickedDate.millisecondsSinceEpoch ~/ 1000;
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'toDate'.tr(),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon: const Icon(Symbols.calendar_today),
                            ),
                            child: Text(
                              periodEnd.value != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                    periodEnd.value! * 1000,
                                  ).toString().split(' ')[0]
                                  : 'selectDate'.tr(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
  final resp = await apiClient.get(
    "/pass/accounts/${pub.account!.name}/badges",
  );
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
    final colors = await ColorExtractionService.getColorsFromImage(
      CloudImageWidget.provider(
        fileId: publisher.background!.id,
        serverUrl: ref.watch(serverUrlProvider),
      ),
    );
    if (colors.isEmpty) return null;
    final dominantColor = colors.first;
    return dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  } catch (_) {
    return null;
  }
}

@riverpod
Future<SnHeatmap?> publisherHeatmap(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/publishers/$uname/heatmap');
  return SnHeatmap.fromJson(resp.data);
}

class PublisherProfileScreen extends HookConsumerWidget {
  final String name;
  const PublisherProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));
    final badges = ref.watch(publisherBadgesProvider(name));
    final subStatus = ref.watch(publisherSubscriptionStatusProvider(name));
    final heatmap = ref.watch(publisherHeatmapProvider(name));
    final appbarColor = ref.watch(
      publisherAppbarForcegroundColorProvider(name),
    );

    final categoryTabController = useTabController(initialLength: 3);
    final categoryTab = useState(0);
    categoryTabController.addListener(() {
      categoryTab.value = categoryTabController.index;
    });

    final includeReplies = useState<bool?>(null);
    final mediaOnly = useState(false);
    final queryTerm = useState<String?>(null);
    final order = useState<String?>('date'); // 'popularity' or 'date'
    final orderDesc = useState(
      true,
    ); // true for descending, false for ascending
    final periodStart = useState<int?>(null);
    final periodEnd = useState<int?>(null);
    final showAdvancedFilters = useState(false);
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
                      title: Text(
                        data.nick,
                        style: TextStyle(
                          color:
                              appbarColor.value ??
                              Theme.of(context).appBarTheme.foregroundColor,
                          shadows: [appbarShadow],
                        ),
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
                                  includeReplies: includeReplies,
                                  mediaOnly: mediaOnly,
                                  queryTerm: queryTerm,
                                  order: order,
                                  orderDesc: orderDesc,
                                  periodStart: periodStart,
                                  periodEnd: periodEnd,
                                  showAdvancedFilters: showAdvancedFilters,
                                ),
                              ),
                              SliverPostList(
                                key: ValueKey(
                                  '${categoryTab.value}-${includeReplies.value}-${mediaOnly.value}-${queryTerm.value}-${order.value}-${orderDesc.value}-${periodStart.value}-${periodEnd.value}',
                                ),
                                pubName: name,
                                pinned: false,
                                type:
                                    categoryTab.value == 1
                                        ? 0
                                        : (categoryTab.value == 2 ? 1 : null),
                                includeReplies: includeReplies.value,
                                mediaOnly: mediaOnly.value,
                                queryTerm: queryTerm.value,
                                order: order.value,
                                orderDesc: orderDesc.value,
                                periodStart: periodStart.value,
                                periodEnd: periodEnd.value,
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
                                  ).padding(horizontal: 4, top: 20),
                                  _PublisherBadgesWidget(
                                    data: data,
                                    badges: badges,
                                  ),
                                  _PublisherVerificationWidget(data: data),
                                  _PublisherBioWidget(data: data),
                                  _PublisherHeatmapWidget(
                                    heatmap: heatmap,
                                    forceDense: true,
                                  ).padding(vertical: 4),
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
                          ).padding(horizontal: 4, top: 8),
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
                        SliverToBoxAdapter(
                          child: _PublisherHeatmapWidget(
                            heatmap: heatmap,
                          ).padding(vertical: 4),
                        ),
                        SliverPostList(pubName: name, pinned: true),
                        SliverToBoxAdapter(
                          child: _PublisherCategoryTabWidget(
                            categoryTabController: categoryTabController,
                            includeReplies: includeReplies,
                            mediaOnly: mediaOnly,
                            queryTerm: queryTerm,
                            order: order,
                            orderDesc: orderDesc,
                            periodStart: periodStart,
                            periodEnd: periodEnd,
                            showAdvancedFilters: showAdvancedFilters,
                          ),
                        ),
                        SliverPostList(
                          key: ValueKey(
                            '${categoryTab.value}-${includeReplies.value}-${mediaOnly.value}-${queryTerm.value}-${order.value}-${orderDesc.value}-${periodStart.value}-${periodEnd.value}',
                          ),
                          pubName: name,
                          pinned: false,
                          type:
                              categoryTab.value == 1
                                  ? 0
                                  : (categoryTab.value == 2 ? 1 : null),
                          includeReplies: includeReplies.value,
                          mediaOnly: mediaOnly.value,
                          queryTerm: queryTerm.value,
                          order: order.value,
                          orderDesc: orderDesc.value,
                          periodStart: periodStart.value,
                          periodEnd: periodEnd.value,
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
