import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/widgets/dialog.dart';

class PendingAttachmentAltDialog extends StatefulWidget {
  final PostWriteMedia media;
  const PendingAttachmentAltDialog({super.key, required this.media});

  @override
  State<PendingAttachmentAltDialog> createState() =>
      _PendingAttachmentAltDialogState();
}

class _PendingAttachmentAltDialogState
    extends State<PendingAttachmentAltDialog> {
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.media.attachment!.alt;
  }

  bool _isBusy = false;

  Future<void> _performAction() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      final attach = context.read<SnAttachmentProvider>();
      final result = await attach.updateOne(
        widget.media.attachment!,
        alt: _contentController.text,
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
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('attachmentSetAlt').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'fieldAttachmentAlt'.tr(),
              border: const OutlineInputBorder(),
            ),
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
