import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ActionEventScreen extends StatefulWidget {
  const ActionEventScreen({super.key});

  @override
  State<ActionEventScreen> createState() => _ActionEventScreenState();
}

class _ActionEventScreenState extends State<ActionEventScreen> {
  bool _isBusy = false;
  int? _totalCount;
  final List<SnActionEvent> _actionEvents = List.empty(growable: true);

  Future<void> _fetchActionEvents() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/id/users/me/events',
        queryParameters: {
          'take': 10,
          'offset': _actionEvents.length,
        },
      );
      _totalCount = resp.data['count'];
      _actionEvents.addAll(
        (resp.data['data'] as List<dynamic>)
            .map((e) => SnActionEvent.fromJson(e)),
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
    _fetchActionEvents();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('accountActionEvent').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                _totalCount = null;
                return _fetchActionEvents();
              },
              child: InfiniteList(
                padding: EdgeInsets.only(left: 20, right: 8),
                itemCount: _actionEvents.length,
                isLoading: _isBusy,
                hasReachedMax:
                    _totalCount != null && _actionEvents.length >= _totalCount!,
                onFetchData: _fetchActionEvents,
                itemBuilder: (context, idx) {
                  final event = _actionEvents[idx];
                  return TimelineTile(
                    nodeAlign: TimelineNodeAlign.start,
                    contents: Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.type,
                                  maxLines: 1,
                                  style: GoogleFonts.robotoMono(),
                                ),
                                if (event.ipAddress.isNotEmpty)
                                  Text(
                                    event.ipAddress,
                                    style: TextStyle(fontSize: 13),
                                  ),
                                if (event.location?.isNotEmpty ?? false)
                                  Text(event.location!),
                                Row(
                                  children: [
                                    Text(DateFormat()
                                            .format(event.createdAt.toLocal()))
                                        .fontSize(12),
                                    Text(' · ')
                                        .fontSize(12)
                                        .padding(horizontal: 4),
                                    Text(RelativeTime(context)
                                            .format(event.createdAt.toLocal()))
                                        .fontSize(12),
                                  ],
                                ).opacity(0.75).padding(top: 4),
                              ],
                            ),
                          ),
                          if (event.metadata != null)
                            ExpansionTile(
                              minTileHeight: 40,
                              tilePadding: EdgeInsets.symmetric(horizontal: 16),
                              title: Text('eventMetadata').tr(),
                              expandedAlignment: Alignment.topLeft,
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  JsonEncoder.withIndent('\t')
                                      .convert(event.metadata),
                                  style: GoogleFonts.robotoMono(),
                                ).padding(vertical: 8, horizontal: 16),
                              ],
                            ).padding(bottom: 6),
                        ],
                      ),
                    ),
                    node: TimelineNode(
                      indicator: DotIndicator(),
                      startConnector: SolidLineConnector(),
                      endConnector: SolidLineConnector(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
