import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/special_day.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/widget.dart';
import 'package:surface/types/check_in.dart';
import 'package:surface/types/news.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:surface/widgets/updater.dart';

class HomeScreenDashEntry {
  final String name;
  final Widget child;
  final int rows, cols;

  const HomeScreenDashEntry({
    required this.name,
    required this.child,
    this.rows = 1,
    this.cols = 1,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<HomeScreenDashEntry> kCards = [
    HomeScreenDashEntry(
      name: 'dashEntryRecommendation',
      child: _HomeDashRecommendationPostWidget(),
      rows: 2,
      cols: 2,
    ),
    HomeScreenDashEntry(
      name: 'dashEntryCheckIn',
      child: _HomeDashCheckInWidget(),
    ),
    HomeScreenDashEntry(
      name: 'dashEntryNotification',
      child: _HomeDashNotificationWidget(),
    ),
    HomeScreenDashEntry(
      name: 'dashEntryTodayNews',
      child: _HomeDashTodayNews(),
      cols: MediaQuery.of(context).size.width >= 640 ? 3 : 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: AutoAppBarLeading(),
        title: Text("screenHome").tr(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: constraints.maxWidth > 640
                ? Alignment.center
                : Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: constraints.maxWidth > 640
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    _HomeDashUpdateWidget(
                        padding: const EdgeInsets.only(
                            bottom: 8, left: 8, right: 8)),
                    _HomeDashSpecialDayWidget().padding(horizontal: 8),
                    StaggeredGrid.extent(
                      maxCrossAxisExtent: 280,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: kCards.map((card) {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: card.cols,
                          mainAxisCellCount: card.rows,
                          child: card.child,
                        );
                      }).toList(),
                    ).padding(horizontal: 8),
                  ],
                ).padding(vertical: 8),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeDashUpdateWidget extends StatelessWidget {
  final EdgeInsets? padding;

  const _HomeDashUpdateWidget({this.padding});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();

    return ListenableBuilder(
      listenable: config,
      builder: (context, _) {
        if (config.updatableVersion != null) {
          return Container(
            padding: padding,
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Symbols.update),
                title: Text('updateAvailable').tr(),
                subtitle: Text(config.updatableVersion!),
                trailing: IconButton(
                  icon: const Icon(Symbols.arrow_right_alt),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => VersionUpdatePopup(),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}

class _HomeDashSpecialDayWidget extends StatefulWidget {
  const _HomeDashSpecialDayWidget();

  @override
  State<_HomeDashSpecialDayWidget> createState() =>
      _HomeDashSpecialDayWidgetState();
}

class _HomeDashSpecialDayWidgetState extends State<_HomeDashSpecialDayWidget> {
  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();
    final dayz = context.watch<SpecialDayProvider>();

    final days = dayz.getSpecialDays();

    if (days.isNotEmpty) {
      return Column(
          children: days.map((ele) {
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Text(kSpecialDaysSymbol[ele] ?? '🎉').fontSize(24),
            title: Text('celebrate$ele').tr(args: [ua.user?.nick ?? 'user']),
            subtitle: Text(
              DateFormat('y/M/d').format(DateTime.now().copyWith(
                month: kSpecialDays[ele]?.$1,
                day: kSpecialDays[ele]?.$2,
              )),
            ),
          ),
        ).padding(bottom: 8);
      }).toList());
    }

    final nextOne = dayz.getNextSpecialDay();
    final lastOne = dayz.getLastSpecialDay();

    if (nextOne != null && lastOne != null) {
      var (name, date) = nextOne;
      date = date.add(Duration(days: 1));
      final progress = dayz.getSpecialDayProgress(lastOne.$2, date);
      final diff = nextOne.$2.difference(DateTime.now());
      return Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Text(kSpecialDaysSymbol[name] ?? '🎉').fontSize(24),
          title: Text('pending$name').tr(args: [
            RelativeTime(context).format(date).replaceFirst('in', '').trim()
          ]),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SlideCountdown(
                duration: diff,
                style: GoogleFonts.robotoMono(fontSize: 13),
                separatorStyle: GoogleFonts.robotoMono(fontSize: 13),
                separatorType: SeparatorType.symbol,
                decoration: BoxDecoration(),
                padding: EdgeInsets.zero,
                onDone: () {
                  setState(() {});
                },
              ),
              const Gap(12),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ).padding(bottom: 8);
    }

    return const SizedBox.shrink();
  }
}

class _HomeDashTodayNews extends StatefulWidget {
  const _HomeDashTodayNews();

  @override
  State<_HomeDashTodayNews> createState() => _HomeDashTodayNewsState();
}

class _HomeDashTodayNewsState extends State<_HomeDashTodayNews> {
  SnNewsArticle? _article;

  Future<void> _fetchArticle() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/re/news/today');
      _article = SnNewsArticle.fromJson(resp.data['data']);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      rethrow;
    } finally {
      setState(() {});
    }
  }

  @override
  initState() {
    super.initState();
    _fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.newspaper),
              const Gap(8),
              Text(
                'newsToday',
                style: Theme.of(context).textTheme.titleLarge,
              ).tr()
            ],
          ).padding(horizontal: 18, top: 12, bottom: 8),
          if (_article != null)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      _article!.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 18),
                      maxLines:
                          MediaQuery.of(context).size.width >= 640 ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      parse(_article!.description)
                          .children
                          .map((e) => e.text.trim())
                          .join(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Builder(builder: (context) {
                      final date = _article!.publishedAt ?? _article!.createdAt;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 2,
                        children: [
                          Text(DateFormat().format(date)).textStyle(
                              Theme.of(context).textTheme.bodySmall!),
                          Text(' · ')
                              .textStyle(Theme.of(context).textTheme.bodySmall!)
                              .bold(),
                          Text(RelativeTime(context).format(date)).textStyle(
                              Theme.of(context).textTheme.bodySmall!),
                        ],
                      ).opacity(0.75);
                    }),
                  ],
                ).padding(horizontal: 16),
                onTap: () {
                  GoRouter.of(context).pushNamed(
                    'newsDetail',
                    pathParameters: {'hash': _article!.hash},
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}

class _HomeDashCheckInWidget extends StatefulWidget {
  const _HomeDashCheckInWidget();

  @override
  State<_HomeDashCheckInWidget> createState() => _HomeDashCheckInWidgetState();
}

class _HomeDashCheckInWidgetState extends State<_HomeDashCheckInWidget> {
  bool _isBusy = false;

  SnCheckInRecord? _todayRecord;

  static const int kSuggestionPositiveHintCount = 6;
  static const int kSuggestionNegativeHintCount = 6;

  Future<void> _pullCheckIn() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final home = context.read<HomeWidgetProvider>();
      final resp = await sn.client.get('/cgi/id/check-in/today');
      _todayRecord = SnCheckInRecord.fromJson(resp.data);
      await home.saveWidgetData('pas_check_in_record', _todayRecord!.toJson());
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _doCheckIn() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final home = context.read<HomeWidgetProvider>();
      final resp = await sn.client.post('/cgi/id/check-in');
      _todayRecord = SnCheckInRecord.fromJson(resp.data);
      await home.saveWidgetData('pas_check_in_record', _todayRecord!.toJson());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Widget _buildDetailChunk(int index, bool positive) {
    final prefix =
        positive ? 'dailyCheckPositiveHint' : 'dailyCheckNegativeHint';
    final mod =
        positive ? kSuggestionPositiveHintCount : kSuggestionNegativeHintCount;
    final pos = math.max(1, _todayRecord!.resultModifiers[index] % mod);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prefix.tr(args: ['$prefix$pos'.tr()]),
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '$prefix${pos}Description',
          style: Theme.of(context).textTheme.bodyMedium,
        ).tr(),
      ],
    );
  }

  void _showCheckInDetail() {
    showDialog(
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('dailyCheckDetailTitle'.tr(args: [
            DateFormat('MM/dd').format(DateTime.now().toUtc()),
          ])),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_todayRecord?.resultTier != 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailChunk(0, true),
                    const Gap(8),
                    _buildDetailChunk(1, true),
                  ],
                )
              else
                Text(
                  'dailyCheckEverythingIsNegative',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ).tr(),
              const Gap(8),
              if (_todayRecord?.resultTier != 4)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailChunk(2, false),
                    const Gap(8),
                    _buildDetailChunk(3, false),
                  ],
                )
              else
                Text(
                  'dailyCheckEverythingIsPositive',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ).tr(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('dialogDismiss').tr(),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final ua = context.read<UserProvider>();
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!ua.isAuthorized) return;
      await _pullCheckIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedSwitcher(
              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: _todayRecord == null
                  ? Column(
                      key: Key('daily-check-in-overview-none'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'dailyCheckIn',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).tr(),
                        Text(
                          'dailyCheckInNone',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).tr(),
                      ],
                    )
                  : Column(
                      key: Key('daily-check-in-overview-has'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _todayRecord!.symbol,
                          style: GoogleFonts.notoSerifHk(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '+${_todayRecord!.resultExperience} EXP',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (_todayRecord!.resultCoin >= 0)
                          Text(
                            '+${_todayRecord!.resultCoin} ${'walletCurrencyShort'.tr()}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                      ],
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE\nMM/dd').format(DateTime.now().toUtc()),
              ).fontSize(13).opacity(0.75),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: AnimatedSwitcher(
                  switchInCurve: Curves.fastOutSlowIn,
                  switchOutCurve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 300),
                  child: _todayRecord == null
                      ? IconButton(
                          key: UniqueKey(),
                          tooltip: 'dailyCheckAction'.tr(),
                          icon: const Icon(Symbols.local_fire_department),
                          onPressed: _isBusy ? null : _doCheckIn,
                        )
                      : IconButton(
                          key: UniqueKey(),
                          tooltip: 'dailyCheckDetail'.tr(),
                          icon: const Icon(Symbols.help),
                          onPressed: _showCheckInDetail,
                        ),
                ),
              ),
            ],
          ),
        ],
      ).padding(all: 24),
    );
  }
}

class _HomeDashNotificationWidget extends StatefulWidget {
  const _HomeDashNotificationWidget();

  @override
  State<_HomeDashNotificationWidget> createState() =>
      _HomeDashNotificationWidgetState();
}

class _HomeDashNotificationWidgetState
    extends State<_HomeDashNotificationWidget> {
  int? _count;

  Future<void> _fetchNotificationCount() async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) {
      setState(() => _count = 0);
      return;
    }

    final sn = context.read<SnNetworkProvider>();
    final resp = await sn.client.get('/cgi/id/notifications/count');
    _count = resp.data['count'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'notification',
                  style: Theme.of(context).textTheme.titleLarge,
                ).tr(),
                Text(
                  _count == null
                      ? 'loading'.tr()
                      : 'notificationUnreadCount'.plural(_count ?? 0),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: IconButton(
                icon: const Icon(Symbols.arrow_right_alt),
                onPressed: () {
                  GoRouter.of(context).goNamed('notification');
                },
              ),
            ),
          )
        ],
      ).padding(all: 24),
    );
  }
}

class _HomeDashRecommendationPostWidget extends StatefulWidget {
  const _HomeDashRecommendationPostWidget();

  @override
  State<_HomeDashRecommendationPostWidget> createState() =>
      _HomeDashRecommendationPostWidgetState();
}

class _HomeDashRecommendationPostWidgetState
    extends State<_HomeDashRecommendationPostWidget> {
  bool _isBusy = false;
  List<SnPost>? _posts;

  Future<void> _fetchRecommendationPosts() async {
    setState(() => _isBusy = true);
    try {
      final pt = context.read<SnPostContentProvider>();
      _posts = await pt.listRecommendations();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchRecommendationPosts();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBusy) {
      return Card(
        margin: EdgeInsets.zero,
        child: CircularProgressIndicator().center(),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Symbols.star),
                  const Gap(8),
                  Text(
                    'postRecommendation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).tr(),
                ],
              ),
              Text('${_currentPage + 1}/${_posts?.length ?? 0}',
                  style: GoogleFonts.robotoMono())
            ],
          ).padding(horizontal: 18, top: 12, bottom: 8),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollBehavior:
                  ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              }),
              itemCount: _posts?.length ?? 0,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: GestureDetector(
                    child: PostItem(
                      data: _posts![index],
                      showMenu: false,
                    ).padding(bottom: 8),
                    onTap: () {
                      GoRouter.of(context)
                          .pushNamed('postDetail', pathParameters: {
                        'slug': _posts![index].id.toString(),
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
