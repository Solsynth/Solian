import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/widgets/dialog.dart';

class PendingAttachmentRateDialog extends StatefulWidget {
  final PostWriteMedia media;
  const PendingAttachmentRateDialog({super.key, required this.media});

  @override
  State<PendingAttachmentRateDialog> createState() =>
      _PendingAttachmentRateDialogState();
}

class _PendingAttachmentRateDialogState
    extends State<PendingAttachmentRateDialog> {
  final _ratingController = TextEditingController();
  final _qualityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _qualityController.text = widget.media.attachment!.qualityRating.toString();
    _ratingController.text = widget.media.attachment!.contentRating.toString();
  }

  bool _isBusy = false;

  Future<void> _performAction() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      final attach = context.read<SnAttachmentProvider>();
      final result = await attach.rateOne(
        widget.media.attachment!,
        quality: int.tryParse(_qualityController.text),
        content: int.tryParse(_ratingController.text),
      );
      if (!mounted) return;
      attach.putCache([result]);
      Navigator.pop(context, result);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _qualityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('attachmentRating').tr(),
      content: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ratingController,
            decoration: InputDecoration(
              labelText: 'fieldAttachmentRating'.tr(),
              border: const OutlineInputBorder(),
              isDense: true,
              helperText: '3 - 21',
            ),
            keyboardType: TextInputType.number,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          TextField(
            controller: _qualityController,
            decoration: InputDecoration(
              labelText: 'fieldAttachmentQuality'.tr(),
              border: const OutlineInputBorder(),
              isDense: true,
              helperText: '0 - 5',
            ),
            keyboardType: TextInputType.number,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
