import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/auth.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

const Map<String, IconData> kAuthTicketIcon = {
  'ios': Symbols.ios,
  'android': Symbols.android,
  'macos': Symbols.computer,
  'windows nt': Symbols.laptop_windows,
  'linux': Symbols.laptop,
};

class AccountAuthTicket extends StatefulWidget {
  const AccountAuthTicket({super.key});

  @override
  State<AccountAuthTicket> createState() => _AccountAuthTicketState();
}

class _AccountAuthTicketState extends State<AccountAuthTicket> {
  bool _isBusy = false;
  int? _totalCount;
  final List<SnAuthTicket> _authTickets = List.empty(growable: true);

  Future<void> _fetchAuthTickets() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/id/users/me/tickets',
        queryParameters: {
          'take': 10,
          'offset': _authTickets.length,
        },
      );
      _totalCount = resp.data['count'];
      _authTickets.addAll(
        (resp.data['data'] as List<dynamic>)
            .map((e) => SnAuthTicket.fromJson(e)),
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteAuthTicket(SnAuthTicket ticket) async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete(
        '/cgi/id/users/me/tickets/${ticket.id}',
      );
      setState(() {
        _authTickets.remove(ticket);
      });
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  int? _currentTicketId;

  @override
  void initState() {
    super.initState();
    _fetchAuthTickets();

    final ua = context.read<UserProvider>();
    ua.atkClaims.then((value) {
      if (value == null) return;
      _currentTicketId = int.parse(value['sed']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('accountAuthTickets').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                _totalCount = null;
                return _fetchAuthTickets();
              },
              child: InfiniteList(
                padding: EdgeInsets.zero,
                onFetchData: _fetchAuthTickets,
                isLoading: _isBusy,
                hasReachedMax:
                    _totalCount != null && _authTickets.length >= _totalCount!,
                itemCount: _authTickets.length,
                itemBuilder: (context, idx) {
                  final ticket = _authTickets[idx];
                  final platform = RegExp(r'\(([^;]+);')
                      .firstMatch(ticket.userAgent)
                      ?.group(1);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        kAuthTicketIcon[platform!.toLowerCase()] ?? Symbols.web,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.ipAddress,
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(ticket.userAgent).opacity(0.8),
                            if (ticket.location?.isNotEmpty ?? false)
                              const Gap(4),
                            if (ticket.location?.isNotEmpty ?? false)
                              Text(ticket.location!).opacity(0.8),
                            const Gap(4),
                            Text('authTicketCreatedAt'.tr(args: [
                              (DateFormat().format(ticket.createdAt.toLocal()))
                            ])).fontSize(12).opacity(0.75),
                            if (ticket.expiredAt != null)
                              Text('authTicketExpiredAt'.tr(args: [
                                (DateFormat()
                                    .format(ticket.expiredAt!.toLocal()))
                              ])).fontSize(12).opacity(0.75),
                            if (ticket.lastGrantAt != null)
                              Text('authTicketLastGrantAt'.tr(args: [
                                (DateFormat()
                                    .format(ticket.lastGrantAt!.toLocal()))
                              ])).fontSize(12).opacity(0.75),
                            const Gap(4),
                            if (_currentTicketId == ticket.id)
                              Text('authTicketCurrent'.tr())
                                  .fontSize(11)
                                  .bold()
                                  .opacity(0.75),
                            Text('#${ticket.id}').fontSize(11).opacity(0.75),
                          ],
                        ),
                      ),
                      IconButton(
                        iconSize: 20,
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Symbols.logout),
                        onPressed: _currentTicketId == ticket.id
                            ? null
                            : () {
                                _deleteAuthTicket(ticket);
                              },
                      ),
                    ],
                  ).padding(horizontal: 16, vertical: 12);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
