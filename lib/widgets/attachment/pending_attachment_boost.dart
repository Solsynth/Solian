import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/dialog.dart';

class PendingAttachmentBoostDialog extends StatefulWidget {
  final PostWriteMedia media;

  const PendingAttachmentBoostDialog({super.key, required this.media});

  @override
  State<PendingAttachmentBoostDialog> createState() =>
      _PendingAttachmentBoostDialogState();
}

class _PendingAttachmentBoostDialogState
    extends State<PendingAttachmentBoostDialog> {
  List<SnAttachmentDestination>? _regions;
  SnAttachmentDestination? _selectedRegion;

  Future<void> _fetchRegions() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/uc/destinations');
      setState(() {
        _regions = List<SnAttachmentDestination>.from(
          resp.data?.map((e) => SnAttachmentDestination.fromJson(e)) ?? [],
        ).cast<SnAttachmentDestination>().where((ele) => ele.isBoost).toList();
      });
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  bool _isBusy = false;

  Future<void> _performAction() async {
    if (_isBusy) return;
    if (_selectedRegion == null) return;

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.post('/cgi/uc/boosts', data: {
        'attachment': widget.media.attachment!.id,
        'destination': _selectedRegion!.id,
      });
      if (!mounted) return;
      Navigator.pop(context, SnAttachmentBoost.fromJson(resp.data));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('attachmentBoost').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('attachmentBoostHint').tr(),
          const Gap(16),
          Text('attachmentDestinationRegion').tr().fontSize(18),
          const Gap(8),
          Card(
            child: _regions == null
                ? const CircularProgressIndicator().center().padding(all: 16)
                : Column(
                    children: _regions!.map(
                      (ele) {
                        return RadioListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          title: Text(ele.label).tr(),
                          subtitle: Text(
                            'attachmentDestinationRegion${ele.region}'.trExists()
                                ? 'attachmentDestinationRegion${ele.region}'
                                    .tr()
                                : ele.region,
                          ),
                          selected: _selectedRegion == ele,
                          value: ele,
                          groupValue: _selectedRegion,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRegion = value);
                            }
                          },
                        );
                      },
                    ).toList(),
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: Text('dialogDismiss'.tr()),
        ),
        TextButton(
          onPressed: _isBusy ? null : () => _performAction(),
          child: Text('dialogConfirm'.tr()),
        ),
      ],
    );
  }
}
