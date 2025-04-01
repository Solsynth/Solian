import 'dart:math' as math;
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/experience.dart';
import 'package:surface/providers/relationship.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/screens/abuse_report.dart';
import 'package:surface/screens/account/punishments.dart';
import 'package:surface/types/account.dart';
import 'package:surface/types/check_in.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/badge.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:surface/theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

final Map<String, (String, IconData, Color)> kBadgesMeta = {
  'company.staff': (
    'badgeCompanyStaff',
    Symbols.tools_wrench,
    Colors.teal,
  ),
  'site.migration': (
    'badgeSiteMigration',
    Symbols.flag,
    Colors.orange,
  ),
  'site.anniversary': (
    'badgeSiteAnniversary',
    Symbols.celebration,
    Colors.orangeAccent,
  ),
  'user.birthday': (
    'badgeUserBirthday',
    Symbols.cake,
    Colors.red[400]!,
  ),
  'community.survey': (
    'badgeCommunitySurvey',
    Symbols.star,
    Colors.yellow[700]!,
  ),
  'community.verified': (
    'badgeCommunityVerified',
    Symbols.verified,
    Colors.blue,
  ),
  'community.contributor': (
    'badgeCommunityContributor',
    Symbols.thumb_up,
    Colors.lightGreen,
  ),
  'programs.developers': (
    'badgeProgramDeveloper',
    Symbols.code,
    Colors.blue,
  ),
  'programs.stellar': (
    'badgeProgramStellar',
    Symbols.family_star,
    Colors.orange,
  ),
  'programs.moderator': (
    'badgeProgramModerator',
    Symbols.sword_rose,
    Colors.blue,
  ),
};

class UserScreen extends StatefulWidget {
  final String name;

  const UserScreen({super.key, required this.name});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();

  SnAccount? _account;

  Future<void> _fetchAccount() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/users/${widget.name}');
      if (!mounted) return;
      _account = SnAccount.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err).then((_) {
        if (mounted) Navigator.pop(context);
      });
    } finally {
      setState(() {});
    }
  }

  List<SnCheckInRecord>? _records;

  Future<void> _getCheckInRecords() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/id/users/${widget.name}/check-in?take=14');
      setState(() {
        _records = List.from(
          resp.data['data']?.map((x) => SnCheckInRecord.fromJson(x)) ?? [],
        );
      });
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
      rethrow;
    }
  }

  SnAccountStatusInfo? _status;

  Future<void> _fetchStatus() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/users/${widget.name}/status');
      if (!mounted) return;
      _status = SnAccountStatusInfo.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() {});
    }
  }

  List<SnPublisher>? _publishers;

  Future<void> _fetchPublishers() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/co/publishers?user=${widget.name}');
      _publishers = List<SnPublisher>.from(
        resp.data?.map((e) => SnPublisher.fromJson(e)) ?? [],
      );
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
      rethrow;
    } finally {
      setState(() {});
    }
  }

  bool _isBusy = false;
  SnRelationship? _accountRelationship;

  Future<void> _addFriend() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/id/users/me/relations/friend', data: {
        'related': _account!.name,
      });
      if (!mounted) return;
      context.showSnackbar('friendRequestSent'.tr());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _blockAccount() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/id/users/me/relations/block', data: {
        'related': _account!.name,
      });
      if (!mounted) return;
      context.showSnackbar(
          'userBlocked'.tr(args: ['@${_account?.name ?? 'unknown'}']));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _unblockAccount() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      final rel = context.read<SnRelationshipProvider>();
      await rel.updateRelationship(
          _account!.id, 1, _accountRelationship?.permNodes ?? {});
      if (!mounted) return;
      context.showSnackbar(
          'userUnblocked'.tr(args: ['@${_account?.name ?? 'unknown'}']));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _showAbuseReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AbuseReportDialog(
        resourceLocation: 'user:${_account?.name}',
      ),
    ).then((value) {
      if (value == true && mounted) {
        _fetchAccount();
        context.showSnackbar('abuseReportSubmitted'.tr());
      }
    });
  }

  double _appBarBlur = 0.0;

  late final _appBarWidth = MediaQuery.of(context).size.width;
  late final _appBarHeight =
      math.min((_appBarWidth * kBannerAspectRatio), 360).roundToDouble();

  void _updateAppBarBlur() {
    if (_scrollController.offset > _appBarHeight) return;
    setState(() {
      _appBarBlur =
          (_scrollController.offset / _appBarHeight * 10).clamp(0.0, 10.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAccount().then((_) async {
      if (!mounted) return;

      _fetchStatus();
      _fetchPublishers();
      _getCheckInRecords();

      try {
        final rel = context.read<SnRelationshipProvider>();
        _accountRelationship = await rel.getRelationship(_account!.id);
        if (mounted) setState(() {});
      } catch (_) {
        // ignore
      }
    });
    _scrollController.addListener(_updateAppBarBlur);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateAppBarBlur);
    _scrollController.dispose();
    super.dispose();
  }

  static const kBannerAspectRatio = 7 / 16;

  @override
  Widget build(BuildContext context) {
    final imageHeight = _appBarHeight + kToolbarHeight + 8;

    const labelShadows = <Shadow>[
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 5.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ];

    final sn = context.read<SnNetworkProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                    foregroundColor: Colors.white,
                  ),
            ),
            child: SliverAppBar(
              expandedHeight: _appBarHeight,
              title: _account == null
                  ? Text('loading').tr()
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: _account!.nick,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    shadows: labelShadows,
                                  ),
                        ),
                        const TextSpan(text: '\n'),
                        TextSpan(
                          text: '@${_account!.name}',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                    shadows: labelShadows,
                                  ),
                        ),
                      ]),
                    ),
              pinned: true,
              flexibleSpace: _account != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_account!.banner.isNotEmpty)
                          UniversalImage(
                            sn.getAttachmentUrl(_account!.banner),
                            fit: BoxFit.cover,
                            height: imageHeight,
                            width: _appBarWidth,
                            cacheHeight: imageHeight,
                            cacheWidth: _appBarWidth,
                          )
                        else
                          Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 56 + MediaQuery.of(context).padding.top,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: _appBarBlur,
                                sigmaY: _appBarBlur,
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(
                                  clampDouble(_appBarBlur * 0.1, 0, 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          if (_account != null)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AccountImage(
                        content: _account!.avatar,
                        radius: 28,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _account!.nick,
                              style: Theme.of(context).textTheme.titleMedium,
                            ).bold(),
                            Text('@${_account!.name}').fontSize(13),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        padding: EdgeInsets.zero,
                        style: ButtonStyle(
                          visualDensity:
                              VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: _showAbuseReportDialog,
                            child: Row(
                              children: [
                                const Icon(Symbols.flag),
                                const Gap(16),
                                Text('report').tr(),
                              ],
                            ),
                          ),
                          if (_accountRelationship == null)
                            PopupMenuItem(
                              onTap: _addFriend,
                              child: Row(
                                children: [
                                  const Icon(Symbols.person_add),
                                  const Gap(16),
                                  Text('friendNew').tr(),
                                ],
                              ),
                            ),
                          if (_accountRelationship?.status != 2)
                            PopupMenuItem(
                              onTap: _blockAccount,
                              child: Row(
                                children: [
                                  const Icon(Symbols.block),
                                  const Gap(16),
                                  Text('friendBlock').tr(),
                                ],
                              ),
                            )
                          else
                            PopupMenuItem(
                              onTap: _unblockAccount,
                              child: Row(
                                children: [
                                  const Icon(Symbols.block),
                                  const Gap(16),
                                  Text('friendUnblock').tr(),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ).padding(right: 8),
                  if (_account!.profile!.description.isNotEmpty)
                    const Gap(4)
                  else
                    const Gap(8),
                  if (_account!.profile!.description.isNotEmpty)
                    Text(_account!.profile!.description).padding(horizontal: 8),
                  const Gap(4),
                  Card(
                    child: Row(
                      children: [
                        Icon(
                          (_status?.isDisturbable ?? true)
                              ? Symbols.circle
                              : Symbols.do_not_disturb_on,
                          fill: (_status?.isOnline ?? false) ? 1 : 0,
                          size: 16,
                          color: (_status?.isOnline ?? false)
                              ? (_status?.isDisturbable ?? true)
                                  ? Colors.green
                                  : Colors.red
                              : Colors.grey,
                        ).padding(all: 4),
                        const Gap(8),
                        Text(
                          _status != null
                              ? (_status!.status?.label.isNotEmpty ?? false)
                                  ? _status!.status!.label
                                  : _status!.isOnline
                                      ? 'accountStatusOnline'.tr()
                                      : 'accountStatusOffline'.tr()
                              : 'loading'.tr(),
                        ),
                        if (_status != null &&
                            !_status!.isOnline &&
                            _status!.lastSeenAt != null)
                          Text(
                            'accountStatusLastSeen'.tr(args: [
                              _status!.lastSeenAt != null
                                  ? RelativeTime(context).format(
                                      _status!.lastSeenAt!.toLocal(),
                                    )
                                  : 'unknown',
                            ]),
                          ).padding(left: 6).opacity(0.75),
                      ],
                    ).padding(vertical: 8, horizontal: 12),
                  ),
                  if (_account!.badges.isNotEmpty) const Gap(8),
                  if (_account!.badges.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _account!.badges
                          .map((ele) => AccountBadge(badge: ele))
                          .toList(),
                    ).padding(horizontal: 8),
                  const Gap(8),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Symbols.calendar_add_on),
                          const Gap(8),
                          Text('publisherJoinedAt').tr(args: [
                            DateFormat('y/M/d').format(_account!.createdAt)
                          ]),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Symbols.cake),
                          const Gap(8),
                          Text('accountBirthday').tr(args: [
                            _account!.profile?.birthday == null
                                ? 'unknown'.tr()
                                : DateFormat('M/d').format(
                                    _account!.profile!.birthday!.toLocal(),
                                  )
                          ]),
                        ],
                      ),
                      if (_account!.profile!.gender.isNotEmpty ||
                          _account!.profile!.pronouns.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Symbols.wc),
                            const Gap(8),
                            Text(
                              _account!.profile!.gender.isNotEmpty
                                  ? _account!.profile!.gender
                                  : 'unknown'.tr(),
                            ),
                            Text(' · ').padding(horizontal: 4),
                            Text(
                              _account!.profile!.pronouns.isNotEmpty
                                  ? _account!.profile!.pronouns
                                  : 'unknown'.tr(),
                            ),
                          ],
                        ),
                      if (_account!.profile!.timeZone.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Symbols.schedule),
                            const Gap(8),
                            Text(_account!.profile!.timeZone),
                          ],
                        ),
                      if (_account!.profile!.location.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Symbols.location_on),
                            const Gap(8),
                            Text(_account!.profile!.location),
                          ],
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Symbols.identity_platform),
                          const Gap(8),
                          Text(
                            '#${_account!.id.toString().padLeft(8, '0')}',
                            style: GoogleFonts.robotoMono(),
                          ).opacity(0.8),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Symbols.star),
                          const Gap(8),
                          Text(
                              'Lv${getLevelFromExp(_account?.profile?.experience ?? 0)}'),
                          const Gap(8),
                          Text(calcLevelUpProgressLevel(
                                  _account?.profile?.experience ?? 0))
                              .fontSize(11)
                              .opacity(0.5),
                          const Gap(8),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: LinearProgressIndicator(
                              value: calcLevelUpProgress(
                                  _account?.profile?.experience ?? 0),
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                            ).alignment(Alignment.centerLeft),
                          ),
                        ],
                      ),
                    ],
                  ).padding(horizontal: 8),
                ],
              ).padding(all: 16),
            ),
          if (_account?.punishments.isNotEmpty ?? false)
            SliverToBoxAdapter(child: const Divider()),
          if (_account?.punishments.isNotEmpty ?? false)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  for (final ele in _account!.punishments)
                    PunishmentInfoCard(ele: ele),
                ],
              ),
            ),
          if (_account?.profile?.links.isNotEmpty ?? false)
            SliverToBoxAdapter(child: const Divider()),
          if (_account?.profile?.links.isNotEmpty ?? false)
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _account!.profile!.links.entries.map((ele) {
                  return ListTile(
                    leading: const Icon(Symbols.link),
                    title: Text(ele.key),
                    subtitle: Text(ele.value),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () {
                      launchUrlString(ele.value);
                    },
                  );
                }).toList(),
              ),
            ),
          SliverToBoxAdapter(child: const Divider()),
          const SliverGap(12),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                if (_records == null) return const SizedBox.shrink();
                if (_records!.length <= 1) {
                  return Text(
                    'accountCheckInNoRecords',
                    textAlign: TextAlign.center,
                  )
                      .tr()
                      .fontWeight(FontWeight.bold)
                      .center()
                      .padding(horizontal: 20, vertical: 8);
                }
                return SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: CheckInRecordChart(records: _records!),
                ).padding(
                  right: 24,
                  left: 16,
                  top: 12,
                );
              },
            ),
          ),
          const SliverGap(12),
          SliverToBoxAdapter(child: const Divider()),
          const SliverGap(12),
          if (_account?.badges.isNotEmpty ?? false)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('accountBadge')
                      .bold()
                      .fontSize(17)
                      .tr()
                      .padding(horizontal: 20, bottom: 4),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final badge in _account?.badges ?? [])
                          SizedBox(
                            width: 280,
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  kBadgesMeta[badge.type]?.$2 ??
                                      Symbols.question_mark,
                                  color: badge.metadata['color'] != null
                                      ? HexColor.fromHex(
                                          badge.metadata['color']!)
                                      : kBadgesMeta[badge.type]?.$3,
                                  fill: 1,
                                ),
                                title: Text(
                                  kBadgesMeta[badge.type]?.$1 ?? 'unknown',
                                ).tr(),
                                subtitle: badge.metadata['title'] != null
                                    ? Text(badge.metadata['title'])
                                    : Text(
                                        DateFormat('y/M/d')
                                            .format(badge.createdAt),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SliverGap(8),
          SliverToBoxAdapter(child: const Divider()),
          SliverList.builder(
            itemCount: _publishers?.length ?? 0,
            itemBuilder: (context, idx) {
              final ele = _publishers![idx];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: AccountImage(
                  content: ele.avatar,
                  fallbackWidget: const Icon(Symbols.group, size: 24),
                ),
                title: Text(ele.nick),
                subtitle: Text('@${ele.name}'),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () {
                  GoRouter.of(context).goNamed(
                    'postPublisher',
                    pathParameters: {'name': ele.name},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CheckInRecordChart extends StatelessWidget {
  const CheckInRecordChart({
    super.key,
    required this.records,
  });

  final List<SnCheckInRecord> records;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            color: Theme.of(context).colorScheme.primary,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: List.filled(
                  records.length,
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ).toList(),
              ),
            ),
            spots: records
                .map(
                  (x) => FlSpot(
                    x.createdAt
                        .copyWith(
                          hour: 0,
                          minute: 0,
                          second: 0,
                          millisecond: 0,
                          microsecond: 0,
                        )
                        .millisecondsSinceEpoch
                        .toDouble(),
                    x.resultTier.toDouble(),
                  ),
                )
                .toList(),
          )
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${kCheckInResultTierSymbols[spot.y.toInt()]}\n${DateFormat('MM/dd').format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()))}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
                .toList(),
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, _) => Align(
                alignment: Alignment.centerRight,
                child: Text(
                  kCheckInResultTierSymbols[value.toInt()],
                  textAlign: TextAlign.right,
                ).padding(right: 8),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 86400000,
              getTitlesWidget: (value, _) => Text(
                DateFormat('dd').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  ),
                ),
                textAlign: TextAlign.center,
              ).padding(top: 8),
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
