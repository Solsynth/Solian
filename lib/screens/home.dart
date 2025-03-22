import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:surface/screens/captcha.dart';
import 'package:surface/types/check_in.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:surface/widgets/updater.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      child: _HomeDashServiceStatus(),
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
                        bottom: 8,
                        left: 8,
                        right: 8,
                      ),
                    ),
                    _HomeDashUnconfirmedWidget().padding(horizontal: 8),
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

class _HomeDashUnconfirmedWidget extends StatelessWidget {
  const _HomeDashUnconfirmedWidget();

  Future<void> _resendConfirmationEmail(BuildContext context) async {
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.patch('/cgi/id/users/me/confirm');
      if (!context.mounted) return;
      context.showSnackbar('accountUnconfirmedResendSuccessful'.tr());
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();
    if (ua.user == null || ua.user?.confirmedAt != null) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Symbols.shield),
        title: Text('accountUnconfirmedTitle').tr(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('accountUnconfirmedSubtitle').tr(),
            const Gap(4),
            Row(
              children: [
                Text('accountUnconfirmedUnreceived').tr(),
                const Gap(4),
                InkWell(
                  child: Text(
                    'accountUnconfirmedResend',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ).tr(),
                  onTap: () {
                    _resendConfirmationEmail(context);
                  },
                ),
              ],
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ).padding(bottom: 8);
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

class _HomeDashServiceStatus extends StatefulWidget {
  const _HomeDashServiceStatus();

  @override
  State<_HomeDashServiceStatus> createState() => _HomeDashServiceStatusState();
}

class _HomeDashServiceStatusState extends State<_HomeDashServiceStatus> {
  Map<String, dynamic>? _statuses;
  ServiceStatus? _serviceStatus;

  Future<void> _fetchStatuses() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/directory/status');
      _statuses = resp.data;
      if (_statuses!.values.contains(false)) {
        if (_statuses!.values.contains(true)) {
          _serviceStatus = ServiceStatus.downgraded;
        } else {
          _serviceStatus = ServiceStatus.failed;
        }
      } else {
        _serviceStatus = ServiceStatus.operational;
      }
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
    _fetchStatuses();
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
              const Icon(Symbols.flare),
              const Gap(8),
              Expanded(
                child: Text(
                  'serviceStatus',
                  style: Theme.of(context).textTheme.titleLarge,
                ).tr(),
              ),
              IconButton(
                icon: const Icon(Symbols.launch, size: 20),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  launchUrlString('https://status.solsynth.dev');
                },
              ),
            ],
          ).padding(horizontal: 18, top: 12, bottom: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            width: double.infinity,
            color: _serviceStatus == null
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : switch (_serviceStatus) {
                    ServiceStatus.operational => Colors.green[300],
                    ServiceStatus.failed => Colors.red[300],
                    _ => Colors.orange[300],
                  },
            child: _serviceStatus == null
                ? Row(
                    children: [
                      const Icon(
                        Symbols.more_horiz,
                        size: 20,
                      ),
                      const Gap(10),
                      Text('loading').tr(),
                    ],
                  )
                : switch (_serviceStatus) {
                    ServiceStatus.operational => Row(
                        children: [
                          const Icon(
                            Symbols.check,
                            size: 20,
                          ),
                          const Gap(10),
                          Text('serviceStatusOperational').tr(),
                        ],
                      ),
                    ServiceStatus.failed => Tooltip(
                        message: 'serviceStatusFailedDescription'.tr(),
                        child: Row(
                          children: [
                            const Icon(
                              Symbols.dangerous,
                              size: 20,
                            ),
                            const Gap(10),
                            Text('serviceStatusFailed').tr(),
                          ],
                        ),
                      ),
                    _ => Row(
                        children: [
                          const Icon(
                            Symbols.error,
                            size: 20,
                          ),
                          const Gap(10),
                          Text('serviceStatusDowngraded').tr(),
                        ],
                      ),
                  },
          ),
          if (_statuses != null)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _statuses!.entries)
                      Tooltip(
                        message: kServicesName[entry.key] != null
                            ? 'serviceName${kServicesName[entry.key]}'.tr()
                            : 'unknown'.tr(),
                        child: Chip(
                          visualDensity:
                              VisualDensity(horizontal: -4, vertical: -4),
                          avatar: entry.value
                              ? const Icon(
                                  Symbols.circle,
                                  color: Colors.green,
                                  fill: 1,
                                  size: 16,
                                )
                              : AnimateWidgetExtensions(const Icon(
                                  Symbols.error,
                                  color: Colors.red,
                                  fill: 1,
                                  size: 16,
                                ))
                                  .animate(onPlay: (e) => e.repeat())
                                  .fadeIn(
                                      duration: 500.ms, curve: Curves.easeOut)
                                  .then()
                                  .fadeOut(
                                    duration: 500.ms,
                                    delay: 1000.ms,
                                    curve: Curves.easeIn,
                                  ),
                          label: Text(kServicesName[entry.key] ?? entry.key),
                        ),
                      ),
                  ],
                ).padding(horizontal: 12),
              ),
            ),
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
    final captchaTk = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => TurnstileScreen(),
      ),
    );
    if (captchaTk == null) return;

    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final home = context.read<HomeWidgetProvider>();
      final resp = await sn.client.post('/cgi/id/check-in', data: {
        'captcha_token': captchaTk,
      });
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
                        if (_todayRecord!.resultCoin > 0)
                          Text(
                            '+${_todayRecord!.resultCoin} ${'walletCurrencyShort'.tr()}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        if (_todayRecord!.currentStreak > 0)
                          Row(
                            children: [
                              const Icon(
                                Symbols.local_fire_department,
                                size: 14,
                              ).padding(bottom: 2),
                              const Gap(4),
                              Text(
                                'checkInStreak'
                                    .plural(_todayRecord!.currentStreak),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ).padding(top: 4),
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
                  GoRouter.of(context).pushNamed('notification');
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
              Text(
                '${_currentPage + 1}/${_posts?.length ?? 0}',
                style: GoogleFonts.robotoMono(),
              )
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
                      showFullPost: true,
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
