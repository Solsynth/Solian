import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kLivestreamActionStartRtmpEgress = 'egress-start';
const kLivestreamActionStopRtmpEgress = 'egress-stop';
const kLivestreamActionStartHlsEgress = 'hls-start';
const kLivestreamActionStopHlsEgress = 'hls-stop';
const kLivestreamActionCopyHlsUrl = 'hls-copy';

List<PopupMenuEntry<String>> buildLivestreamEgressMenuEntries({
  required bool hasHlsUrl,
}) {
  return [
    PopupMenuItem(
      value: kLivestreamActionStartRtmpEgress,
      child: Row(
        children: [
          const Icon(Symbols.outbound),
          const Gap(12),
          const Text('startRtmpEgress').tr(),
        ],
      ),
    ),
    PopupMenuItem(
      value: kLivestreamActionStopRtmpEgress,
      child: Row(
        children: [
          const Icon(Symbols.outbound),
          const Gap(12),
          const Text('stopRtmpEgress').tr(),
        ],
      ),
    ),
    PopupMenuItem(
      value: kLivestreamActionStartHlsEgress,
      child: Row(
        children: [
          const Icon(Symbols.play_circle),
          const Gap(12),
          const Text('启用录制回放'),
        ],
      ),
    ),
    PopupMenuItem(
      value: kLivestreamActionStopHlsEgress,
      child: Row(
        children: [
          const Icon(Symbols.stop_circle),
          const Gap(12),
          const Text('禁用录制回放'),
        ],
      ),
    ),
    if (hasHlsUrl)
      PopupMenuItem(
        value: kLivestreamActionCopyHlsUrl,
        child: Row(
          children: [
            const Icon(Symbols.content_copy),
            const Gap(12),
            const Text('复制回放播放地址'),
          ],
        ),
      ),
  ];
}

Future<bool> handleLivestreamEgressMenuAction(
  BuildContext context,
  WidgetRef ref, {
  required String action,
  required String livestreamId,
  required String? hlsUrl,
  VoidCallback? onSuccess,
}) async {
  switch (action) {
    case kLivestreamActionStartRtmpEgress:
      await _startRtmpEgress(context, ref, livestreamId, onSuccess: onSuccess);
      return true;
    case kLivestreamActionStopRtmpEgress:
      await _stopRtmpEgress(context, ref, livestreamId, onSuccess: onSuccess);
      return true;
    case kLivestreamActionStartHlsEgress:
      await _startHlsEgress(context, ref, livestreamId, onSuccess: onSuccess);
      return true;
    case kLivestreamActionStopHlsEgress:
      await _stopHlsEgress(context, ref, livestreamId, onSuccess: onSuccess);
      return true;
    case kLivestreamActionCopyHlsUrl:
      await Clipboard.setData(ClipboardData(text: hlsUrl ?? ''));
      showSnackBar('hlsUrlCopied'.tr());
      return true;
  }
  return false;
}

Future<void> _startRtmpEgress(
  BuildContext context,
  WidgetRef ref,
  String livestreamId, {
  VoidCallback? onSuccess,
}) async {
  final submitted = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _RtmpEgressSheet(),
  );
  if (submitted == null) return;

  try {
    final client = ref.read(apiClientProvider);
    await client.post(
      '/sphere/livestreams/$livestreamId/egress',
      data: submitted,
    );
    showSnackBar('rtmpEgressStarted'.tr());
    onSuccess?.call();
  } catch (e) {
    showErrorAlert(e);
  }
}

Future<void> _stopRtmpEgress(
  BuildContext context,
  WidgetRef ref,
  String livestreamId, {
  VoidCallback? onSuccess,
}) async {
  try {
    final client = ref.read(apiClientProvider);
    await client.post('/sphere/livestreams/$livestreamId/egress/stop');
    showSnackBar('rtmpEgressStopped'.tr());
    onSuccess?.call();
  } catch (e) {
    showErrorAlert(e);
  }
}

Future<void> _startHlsEgress(
  BuildContext context,
  WidgetRef ref,
  String livestreamId, {
  VoidCallback? onSuccess,
}) async {
  final submitted = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _HlsEgressSheet(),
  );
  if (submitted == null) return;

  try {
    final client = ref.read(apiClientProvider);
    await client.post('/sphere/livestreams/$livestreamId/hls', data: submitted);
    showSnackBar('hlsEgressStarted'.tr());
    onSuccess?.call();
  } catch (e) {
    showErrorAlert(e);
  }
}

Future<void> _stopHlsEgress(
  BuildContext context,
  WidgetRef ref,
  String livestreamId, {
  VoidCallback? onSuccess,
}) async {
  try {
    final client = ref.read(apiClientProvider);
    await client.post('/sphere/livestreams/$livestreamId/hls/stop');
    showSnackBar('hlsEgressStopped'.tr());
    onSuccess?.call();
  } catch (e) {
    showErrorAlert(e);
  }
}

class _RtmpEgressSheet extends HookWidget {
  const _RtmpEgressSheet();

  @override
  Widget build(BuildContext context) {
    final urlsController = useTextEditingController();
    final filePathController = useTextEditingController();

    return SheetScaffold(
      titleText: 'startRtmpEgressTitle'.tr(),
      child: Column(
        spacing: 12,
        children: [
          TextField(
            controller: urlsController,
            decoration: const InputDecoration(
              labelText: 'rtmpUrlsOnePerLine'.tr(),
e             border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            minLines: 3,
            maxLines: 6,
          ),
          TextField(
            controller: filePathController,
            decoration: const InputDecoration(
              labelText: 'recordingFilePathOptional'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              final urls = urlsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              Navigator.of(context).pop({
                'rtmp_urls': urls,
                if (filePathController.text.trim().isNotEmpty)
                  'file_path': filePathController.text.trim(),
              });
            },
            icon: const Icon(Symbols.play_arrow),
            label: const Text('start').tr(),
          ),
        ],
      ).padding(horizontal: 16, vertical: 20),
    );
  }
}

class _HlsEgressSheet extends StatelessWidget {
  const _HlsEgressSheet();

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: '录制回放设置',
      child: FilledButton.icon(
        onPressed: () {
          Navigator.of(context).pop({
            'playlist_name': 'playlist.m3u8',
            'segment_duration': 6,
            'segment_count': 0,
          });
        },
        icon: const Icon(Symbols.play_arrow),
        label: const Text('启用'),
      ).padding(horizontal: 16, vertical: 20),
    );
  }
}
