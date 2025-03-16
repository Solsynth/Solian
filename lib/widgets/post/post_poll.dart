import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/poll.dart';
import 'package:surface/widgets/dialog.dart';

class PostPoll extends StatefulWidget {
  final SnPoll poll;

  const PostPoll({super.key, required this.poll});

  @override
  State<PostPoll> createState() => _PostPollState();
}

class _PostPollState extends State<PostPoll> {
  bool _isBusy = false;
  late SnPoll _poll;

  @override
  void initState() {
    _poll = widget.poll;
    _fetchAnswer();
    super.initState();
  }

  String? _answeredChoice;

  Future<void> _refreshPoll() async {
    final sn = context.read<SnNetworkProvider>();
    final resp = await sn.client.get('/cgi/co/polls/${widget.poll.id}');
    if (!mounted) return;
    setState(() => _poll = SnPoll.fromJson(resp.data!));
  }

  Future<void> _fetchAnswer() async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/co/polls/${widget.poll.id}/answer');
      _answeredChoice = resp.data?['answer'];
      if (!mounted) return;
      setState(() {});
    } catch (err) {
      if (!mounted) return;
      // ignore because it may not found
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _voteForOption(SnPollOption option) async {
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/co/polls/${widget.poll.id}/answer', data: {
        'answer': option.id,
      });
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _answeredChoice = option.id;
      _refreshPoll();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final option in _poll.options)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        height: 60,
                        width: constraints.maxWidth *
                            (_poll.metric.byOptionsPercentage[option.id] ?? 0)
                                .toDouble(),
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minTileHeight: 60,
                      leading: _answeredChoice == option.id
                          ? const Icon(Symbols.circle, fill: 1)
                          : const Icon(Symbols.circle),
                      title: Text(option.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'pollVotes'.plural(
                                    _poll.metric.byOptions[option.id] ?? 0),
                              ),
                              Text(' · ').padding(horizontal: 4),
                              Text(
                                '${((_poll.metric.byOptionsPercentage[option.id] ?? 0).toDouble() * 100).toStringAsFixed(2)}%',
                              ),
                            ],
                          ),
                          if (option.description.isNotEmpty)
                            Text(option.description),
                        ],
                      ),
                      onTap: _isBusy ? null : () => _voteForOption(option),
                    ),
                  ],
                )
            ],
          ),
        );
      },
    );
  }
}
