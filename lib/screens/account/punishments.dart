import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

const kPunishmentIcons = [
  Symbols.warning,
  Symbols.emergency_home,
  Symbols.dangerous,
];

class PunishmentsScreen extends StatefulWidget {
  const PunishmentsScreen({super.key});

  @override
  State<PunishmentsScreen> createState() => _PunishmentsScreenState();
}

class _PunishmentsScreenState extends State<PunishmentsScreen> {
  bool _isBusy = false;
  List<SnPunishment>? _punishments;

  Future<void> _fetchPunishments() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/punishments');
      if (!mounted) return;
      _punishments = List.from(
        resp.data.map((ele) => SnPunishment.fromJson(ele)),
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPunishments();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        title: Text('accountPunishments').tr(),
        leading: PageBackButton(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          Card(
            margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Symbols.visibility, size: 20),
                    const Gap(6),
                    Expanded(
                      child: Text('punishmentOverall').tr().fontSize(16).bold(),
                    ),
                  ],
                ),
                Builder(
                  builder: (context) {
                    if (_punishments == null) return Text('loading').tr();
                    if (_punishments!.any((ele) => ele.type == 2)) {
                      return Text('punishmentStatusBanned').tr();
                    }
                    if (_punishments!.any(
                      (ele) => ele.type == 1 && ele.permNodes.isEmpty,
                    )) {
                      return Text('punishmentStatusLimitedFully').tr();
                    } else if (_punishments!.any((ele) => ele.type == 1)) {
                      return Text('punishmentStatusLimited').tr();
                    }
                    if (_punishments!.any((ele) => ele.type == 0)) {
                      return Text('punishmentStatusWarned').tr();
                    }
                    return Text('punishmentStatusNormal').tr();
                  },
                ),
              ],
            ).padding(horizontal: 24, vertical: 16),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchPunishments,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _punishments?.length ?? 0,
                itemBuilder: (context, index) {
                  final ele = _punishments![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(kPunishmentIcons[ele.type], size: 20),
                            const Gap(6),
                            Expanded(
                              child: Text('punishmentType${ele.type}')
                                  .tr()
                                  .fontSize(16)
                                  .bold(),
                            ),
                          ],
                        ),
                        Text(ele.reason),
                        const Gap(4),
                        Text(
                          'punishmentCreatedAt'.tr(args: [
                            DateFormat().format(
                              ele.createdAt.toLocal(),
                            )
                          ]),
                        ).opacity(0.8),
                        Text(
                          ele.expiredAt == null
                              ? 'punishmentExpiredNever'.tr()
                              : 'punishmentExpiredAt'.tr(args: [
                                  DateFormat().format(
                                    ele.expiredAt!.toLocal(),
                                  )
                                ]),
                        ).opacity(0.8),
                        const Gap(8),
                        if (ele.moderator != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('punishmentModerator').tr().opacity(0.75),
                              InkWell(
                                child: Row(
                                  children: [
                                    AccountImage(
                                      content: ele.moderator!.avatar,
                                      radius: 8,
                                    ),
                                    const Gap(4),
                                    Text(ele.moderator?.nick ?? 'unknown'),
                                  ],
                                ),
                                onTap: () {
                                  GoRouter.of(context).pushNamed(
                                    'accountProfilePage',
                                    pathParameters: {
                                      'name': ele.moderator!.name,
                                    },
                                  );
                                },
                              ),
                            ],
                          )
                        else
                          Text('punishmentMadeBySystem').tr().opacity(0.75),
                      ],
                    ).padding(horizontal: 24, vertical: 16),
                  );
                },
                separatorBuilder: (_, __) => const Gap(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
