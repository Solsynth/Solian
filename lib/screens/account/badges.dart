import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/screens/account/profile_page.dart' show kBadgesMeta;
import 'package:surface/theme.dart';
import 'package:surface/types/account.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class AccountBadgesScreen extends StatefulWidget {
  const AccountBadgesScreen({super.key});

  @override
  State<AccountBadgesScreen> createState() => _AccountBadgesScreenState();
}

class _AccountBadgesScreenState extends State<AccountBadgesScreen> {
  bool _isBusy = false;
  List<SnAccountBadge>? _badges;

  Future<void> _fetchBadges() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/badges/me');
      if (!mounted) return;
      setState(
        () => _badges = List<SnAccountBadge>.from(
          resp.data?.map((e) => SnAccountBadge.fromJson(e)) ?? [],
        ),
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  bool _isActivating = false;

  Future<void> _activateBadge(SnAccountBadge badge) async {
    try {
      setState(() => _isActivating = true);
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/id/badges/${badge.id}/active');
      if (!mounted) return;
      context.showSnackbar('badgeActivated'
          .tr(args: [(kBadgesMeta[badge.type]?.$1 ?? 'unknown').tr()]));
      await _fetchBadges();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isActivating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('screenAccountBadges').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          if (_badges != null)
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: RefreshIndicator(
                  onRefresh: _fetchBadges,
                  child: ListView.builder(
                    itemCount: _badges!.length,
                    itemBuilder: (context, idx) {
                      final badge = _badges![idx];
                      return ListTile(
                        title: Text(
                          kBadgesMeta[badge.type]?.$1 ?? 'unknown',
                        ).tr(),
                        contentPadding: const EdgeInsets.only(
                          left: 24,
                          right: 16,
                          top: 4,
                          bottom: 4,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (badge.metadata['title'] != null)
                              Text(badge.metadata['title']).fontSize(14).bold()
                            else
                              Text(
                                '#${badge.id.toString().padLeft(8, '0')}',
                                style: GoogleFonts.robotoMono(),
                              ).fontSize(14).bold(),
                            Text(
                              DateFormat('y/M/d').format(badge.createdAt),
                            )
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Symbols.check),
                          onPressed: (badge.isActive || _isActivating)
                              ? null
                              : () {
                                  _activateBadge(badge);
                                },
                        ),
                        leading: Icon(
                          kBadgesMeta[badge.type]?.$2 ?? Symbols.question_mark,
                          color: badge.metadata['color'] != null
                              ? HexColor.fromHex(badge.metadata['color']!)
                              : kBadgesMeta[badge.type]?.$3,
                          fill: 1,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
