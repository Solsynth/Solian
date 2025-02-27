import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/logger.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:video_compress/video_compress.dart';

class PendingVideoCompressDialog extends StatefulWidget {
  final PostWriteMedia media;

  const PendingVideoCompressDialog({super.key, required this.media});

  @override
  State<PendingVideoCompressDialog> createState() =>
      _PendingVideoCompressDialogState();
}

class _PendingVideoCompressDialogState
    extends State<PendingVideoCompressDialog> {
  VideoQuality _quality = VideoQuality.DefaultQuality;

  bool _isBusy = false;
  double? _progress;
  MediaInfo? _mediaInfo;

  Subscription? _progressSubscription;

  Future<void> _startCompress() async {
    _mediaInfo = await VideoCompress.compressVideo(
      widget.media.file!.path,
      quality: _quality,
      deleteOrigin: false,
      frameRate: switch (_quality) {
        VideoQuality.HighestQuality => 60,
        VideoQuality.DefaultQuality => 60,
        _ => 30,
      },
    );
    if (_mediaInfo == null) return;
    setState(() => _isBusy = true);
    if (!mounted || _mediaInfo == null) return;
    Navigator.pop(context, PostWriteMedia.fromFile(XFile(_mediaInfo!.path!)));
  }

  @override
  void initState() {
    super.initState();
    _progressSubscription = VideoCompress.compressProgress$.subscribe((event) {
      logging.debug('[Paperclip.VideoCompress] Progress: $event');
      setState(() {
        _progress = event / 100;
        _isBusy = event < 100;
      });
    });
  }

  @override
  void dispose() {
    _progressSubscription?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('attachmentCompressVideo').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: widget.media.file?.length(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return Text(
                snapshot.data!.formatBytes(),
                style: GoogleFonts.robotoMono(fontSize: 13),
              );
            },
          ),
          Text('attachmentCompressQuality').tr(),
          const Gap(8),
          Card(
            child: Column(
              children: [
                RadioListTile(
                  title: Text('attachmentCompressQualityHighest').tr(),
                  value: VideoQuality.HighestQuality,
                  groupValue: _quality,
                  selected: _quality == VideoQuality.HighestQuality,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _quality = val);
                    }
                  },
                ),
                RadioListTile(
                  title: Text('attachmentCompressQualityDefault').tr(),
                  value: VideoQuality.DefaultQuality,
                  groupValue: _quality,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _quality = val);
                    }
                  },
                ),
                RadioListTile(
                  title: Text('attachmentCompressQualityMedium').tr(),
                  value: VideoQuality.MediumQuality,
                  groupValue: _quality,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _quality = val);
                    }
                  },
                ),
                RadioListTile(
                  title: Text('attachmentCompressQualityLow').tr(),
                  value: VideoQuality.LowQuality,
                  groupValue: _quality,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _quality = val);
                    }
                  },
                ),
              ],
            ),
          ),
          const Gap(8),
          Text('attachmentCompressQualityHint',
                  style: Theme.of(context).textTheme.bodySmall!)
              .tr(),
          if (_isBusy)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress ?? 0),
              duration: Duration(milliseconds: 100),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ).padding(top: 16),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: Text('dialogDismiss').tr(),
        ),
        TextButton(
          onPressed: _isBusy ? null : _startCompress,
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}
