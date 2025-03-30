import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/experience.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class AccountProgramScreen extends StatefulWidget {
  const AccountProgramScreen({super.key});

  @override
  State<AccountProgramScreen> createState() => _AccountProgramScreenState();
}

class _AccountProgramScreenState extends State<AccountProgramScreen> {
  bool _isBusy = false;
  final List<SnProgram> _programs = List.empty(growable: true);
  final List<SnProgramMember> _programMembers = List.empty(growable: true);

  Future<void> _fetchPrograms() async {
    _programs.clear();
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/programs');
      _programs.addAll(
        resp.data.map((ele) => SnProgram.fromJson(ele)).cast<SnProgram>(),
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _fetchProgramMembers() async {
    _programMembers.clear();
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/programs/members');
      _programMembers.addAll(
        resp.data
            .map((ele) => SnProgramMember.fromJson(ele))
            .cast<SnProgramMember>(),
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
    _fetchPrograms();
    _fetchProgramMembers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
        title: Text('accountProgram').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _programs.length,
              itemBuilder: (context, idx) {
                final ele = _programs[idx];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => _ProgramJoinPopup(
                          program: ele,
                          isJoined:
                              _programMembers.any((e) => e.programId == ele.id),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _fetchProgramMembers();
                        }
                      });
                    },
                    child: Column(
                      children: [
                        if (ele.appearance['banner'] != null)
                          AspectRatio(
                            aspectRatio: 16 / 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                child: Image.network(
                                  ele.appearance['banner'],
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ele.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ).bold(),
                                    Text(
                                      ele.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_programMembers
                                        .any((e) => e.programId == ele.id))
                                      Text('accountProgramAlreadyJoined'.tr())
                                          .opacity(0.75),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).padding(horizontal: 8);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramJoinPopup extends StatefulWidget {
  final SnProgram program;
  final bool isJoined;
  const _ProgramJoinPopup({required this.program, required this.isJoined});

  @override
  State<_ProgramJoinPopup> createState() => _ProgramJoinPopupState();
}

class _ProgramJoinPopupState extends State<_ProgramJoinPopup> {
  bool _isBusy = false;

  Future<void> _joinProgram() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/id/programs/${widget.program.id}');
      if (!mounted) return;
      Navigator.pop(context, true);
      context.showSnackbar('accountProgramJoined'.tr());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _leaveProgram() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete('/cgi/id/programs/${widget.program.id}');
      if (!mounted) return;
      Navigator.pop(context, true);
      context.showSnackbar('accountProgramLeft'.tr());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Symbols.add, size: 24),
                const Gap(16),
                Text(
                  'accountProgramJoin',
                  style: Theme.of(context).textTheme.titleLarge,
                ).tr(),
              ],
            ).padding(horizontal: 20, top: 16, bottom: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.program.appearance['banner'] != null)
                  AspectRatio(
                    aspectRatio: 16 / 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Image.network(
                          widget.program.appearance['banner'],
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ).padding(bottom: 12),
                Text(
                  widget.program.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ).bold(),
                MarkdownTextContent(content: widget.program.description),
                const Gap(8),
                Text(
                  'accountProgramJoinRequirements',
                  style: Theme.of(context).textTheme.titleMedium,
                ).tr().bold(),
                Text('≥EXP ${widget.program.expRequirement}'),
                Text('≥Lv${getLevelFromExp(widget.program.expRequirement)}'),
                const Gap(8),
                Text(
                  'accountProgramJoinPricing',
                  style: Theme.of(context).textTheme.titleMedium,
                ).tr().bold(),
                Text('walletCurrency${widget.program.price['currency'].toString().capitalize().replaceFirst('Normal', '')}')
                    .plural(widget.program.price['amount'].toDouble()),
                Text('accountProgramJoinPricingHint').tr().opacity(0.75),
                const Gap(8),
                if (widget.isJoined)
                  Text('accountProgramLeaveHint')
                      .tr()
                      .opacity(0.75)
                      .padding(bottom: 8),
                if (!widget.isJoined)
                  ElevatedButton(
                    onPressed: _isBusy ? null : _joinProgram,
                    child: Text('join').tr(),
                  )
                else
                  ElevatedButton(
                    onPressed: _isBusy ? null : _leaveProgram,
                    child: Text('leave').tr(),
                  ),
              ],
            ).padding(horizontal: 24),
            Gap(MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
