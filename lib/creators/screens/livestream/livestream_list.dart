import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:island/creators/screens/livestream/livestream_detail.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

final creatorLivestreamListProvider = FutureProvider.family
    .autoDispose<List<SnLiveStream>, String>((ref, publisherId) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get(
        '/sphere/livestreams/publisher/$publisherId',
        queryParameters: {'limit': 50, 'offset': 0},
      );

      return (response.data as List)
          .whereType<Map>()
          .map((e) => SnLiveStream.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });

Map<String, dynamic>? _tryParseJsonObject(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  try {
    final dynamic decoded = const JsonDecoder().convert(trimmed);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}
  return null;
}

String? _extractCloudFileId(dynamic pickerResult) {
  if (pickerResult is SnCloudFile) return pickerResult.id;
  if (pickerResult is List && pickerResult.isNotEmpty) {
    final first = pickerResult.first;
    if (first is SnCloudFile) return first.id;
  }
  return null;
}

@RoutePage()
class CreatorLivestreamListScreen extends ConsumerWidget {
  final String pubName;

  const CreatorLivestreamListScreen({super.key, required this.pubName});

  Future<void> _createLivestream(
    BuildContext context,
    WidgetRef ref,
    String publisherId,
    String publisherName,
  ) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateLivestreamSheet(
        publisherId: publisherId,
        publisherName: publisherName,
      ),
    );

    if (created == true) {
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisherAsync = ref.watch(publisherNullableProvider(pubName));

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: const Text('livestreams').tr(),
      ),
      floatingActionButton: publisherAsync.when(
        data: (publisher) => publisher == null
            ? null
            : FloatingActionButton(
                onPressed: () => _createLivestream(
                  context,
                  ref,
                  publisher.id,
                  publisher.name,
                ),
                child: const Icon(Symbols.add),
              ),
        loading: () => null,
        error: (_, _) => null,
      ),
      body: publisherAsync.when(
        data: (data) {
          if (data == null) {
            return const EmptyState(
              icon: Symbols.error,
              title: 'publisherNotFound',
              description: 'publisherNotFoundDescription',
            );
          }

          final streamsAsync = ref.watch(
            creatorLivestreamListProvider(data.id),
          );

          return streamsAsync.when(
            data: (streams) {
              if (streams.isEmpty) {
                return const EmptyState(
                  icon: Symbols.live_tv,
                  title: 'noLivestreams',
                  description: 'noLivestreamsDescription',
                );
              }

              return ExtendedRefreshIndicator(
                onRefresh: () =>
                    ref.refresh(creatorLivestreamListProvider(data.id).future),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: streams.length,
                  itemBuilder: (context, index) {
                    final stream = streams[index];
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: _CreatorLivestreamItem(
                        publisherId: data.id,
                        stream: stream,
                      ),
                    ).center();
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('errorGeneric').tr(args: ['$error'])),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('errorGeneric').tr(args: ['$error'])),
      ),
    );
  }
}

class _CreatorLivestreamItem extends ConsumerWidget {
  final String publisherId;
  final SnLiveStream stream;

  const _CreatorLivestreamItem({
    required this.publisherId,
    required this.stream,
  });

  String get _id => stream.id;

  String _statusText(SnLiveStreamStatus status) {
    return switch (status) {
      SnLiveStreamStatus.pending => 'livestreamStatusPending'.tr(),
      SnLiveStreamStatus.active => 'livestreamStatusActive'.tr(),
      SnLiveStreamStatus.ended => 'livestreamStatusEnded'.tr(),
      SnLiveStreamStatus.error => 'livestreamStatusError'.tr(),
    };
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'ended':
        return Theme.of(context).colorScheme.outline;
      case 'error':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _startStream(BuildContext context, WidgetRef ref) async {
    final options = await showModalBottomSheet<_StartStreamOptions>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _StartStreamOptionsSheet(),
    );
    if (options == null) return;

    try {
      final client = ref.read(apiClientProvider);
      final payload = <String, dynamic>{
        'no_ingress': options.mode == _StartStreamMode.inApp,
      };
      if (options.mode == _StartStreamMode.whip) {
        payload['use_whip'] = true;
      }
      if (options.mode != _StartStreamMode.inApp) {
        payload['enable_transcoding'] = options.enableTranscoding;
      }
      final response = await client.post(
        '/sphere/livestreams/$_id/start',
        data: payload,
      );
      final data = Map<String, dynamic>.from(response.data);
      final streamKey = data['stream_key'];
      final roomName = data['room_name'];
      final url = data['url'];
      final isRtmpMode = options.mode == _StartStreamMode.rtmp;
      final isWhipMode = options.mode == _StartStreamMode.whip;
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            isRtmpMode
                ? 'rtmpSettings'.tr()
                : isWhipMode
                ? 'WHIP Settings'
                : 'In-app Streaming Ready',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRtmpMode) ...[
                if (url.isNotEmpty) ...[
                  _CopyField(label: 'rtmpUrl'.tr(), value: url),
                ] else ...[
                  const Text('RTMP URL is missing in the response.'),
                ],
                if (streamKey.isNotEmpty) ...[
                  const Gap(12),
                  _CopyField(label: 'streamKey'.tr(), value: streamKey),
                ],
              ] else if (isWhipMode) ...[
                if (url.isNotEmpty) ...[
                  _CopyField(label: 'WHIP URL', value: url),
                ] else ...[
                  const Text('WHIP URL is missing in the response.'),
                ],
                if (streamKey.isNotEmpty) ...[
                  const Gap(12),
                  _CopyField(label: 'Bearer Token', value: streamKey),
                ],
              ] else ...[
                const Text(
                  'Ingress is disabled for this start request. Use in-app studio to stream.',
                ),
              ],
              if (roomName.isNotEmpty) ...[
                const Gap(12),
                _CopyField(label: 'roomName'.tr(), value: roomName),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ok').tr(),
            ),
          ],
        ),
      );

      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _endStream(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'endLivestreamConfirm'.tr(),
      'endLivestream'.tr(),
      isDanger: true,
    );
    if (confirmed != true) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/end');
      showSnackBar('livestreamEnded'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _editStream(BuildContext context, WidgetRef ref) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditLivestreamSheet(stream: stream),
    );
    if (updated == true) {
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    }
  }

  Future<void> _updateThumbnail(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          const CloudFilePicker(allowedTypes: {UniversalFileType.image}),
    );
    final fileId = _extractCloudFileId(picked);
    if (fileId == null) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.patch(
        '/sphere/livestreams/$_id/thumbnail',
        data: {'thumbnail_id': fileId},
      );
      showSnackBar('thumbnailUpdated'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _clearThumbnail(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.patch(
        '/sphere/livestreams/$_id/thumbnail',
        data: {'thumbnail_id': null},
      );
      showSnackBar('thumbnailRemoved'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _startRtmpEgress(BuildContext context, WidgetRef ref) async {
    final submitted = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _RtmpEgressSheet(),
    );
    if (submitted == null) return;
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/egress', data: submitted);
      showSnackBar('rtmpEgressStarted'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _stopRtmpEgress(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/egress/stop');
      showSnackBar('rtmpEgressStopped'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _startHlsEgress(BuildContext context, WidgetRef ref) async {
    final submitted = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _HlsEgressSheet(),
    );
    if (submitted == null) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/hls', data: submitted);
      showSnackBar('hlsEgressStarted'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _stopHlsEgress(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/hls/stop');
      showSnackBar('hlsEgressStopped'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _deleteStream(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'deleteLivestreamConfirm',
      'deleteLivestream',
      isDanger: true,
    );
    if (confirmed != true) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.delete('/sphere/livestreams/$_id');
      showSnackBar('livestreamDeleted'.tr());
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _statusText(stream.status);
    final statusColor = _statusColor(context, status);
    final title = stream.title ?? 'untitledLivestream'.tr();
    final description = stream.description;

    final thumbnailWidget = stream.thumbnail?.id != null
        ? CloudImageWidget(fileId: stream.thumbnail!.id, fit: BoxFit.cover)
        : ColoredBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Center(
              child: Icon(Symbols.live_tv, color: statusColor, size: 28),
            ),
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreatorLivestreamDetailScreen(livestreamId: _id),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumbnailWidget,
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.fiber_manual_record,
                        size: 12,
                        color: statusColor,
                      ),
                      const Gap(4),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.surface,
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Symbols.more_vert, color: Colors.white),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Symbols.edit),
                          const Gap(12),
                          const Text('edit').tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'thumbnail',
                      child: Row(
                        children: [
                          const Icon(Symbols.image),
                          const Gap(12),
                          const Text('updateThumbnail').tr(),
                        ],
                      ),
                    ),
                    if (stream.thumbnail != null)
                      PopupMenuItem(
                        value: 'thumbnail-clear',
                        child: Row(
                          children: [
                            const Icon(Symbols.hide_image),
                            const Gap(12),
                            const Text('removeThumbnail').tr(),
                          ],
                        ),
                      ),
                    if (status.toLowerCase() != 'active')
                      PopupMenuItem(
                        value: 'start',
                        child: Row(
                          children: [
                            const Icon(Symbols.play_arrow),
                            const Gap(12),
                            const Text('startStream').tr(),
                          ],
                        ),
                      ),
                    if (status.toLowerCase() == 'active')
                      PopupMenuItem(
                        value: 'end',
                        child: Row(
                          children: [
                            const Icon(Symbols.stop, color: Colors.red),
                            const Gap(12),
                            const Text('endStream').tr().textColor(Colors.red),
                          ],
                        ),
                      ),
                    // PopupMenuItem(
                    //   value: 'egress-start',
                    //   child: Row(
                    //     children: [
                    //       const Icon(Symbols.outbound),
                    //       const Gap(12),
                    //       const Text('startRtmpEgress').tr(),
                    //     ],
                    //   ),
                    // ),
                    // PopupMenuItem(
                    //   value: 'egress-stop',
                    //   child: Row(
                    //     children: [
                    //       const Icon(Symbols.outbound),
                    //       const Gap(12),
                    //       const Text('stopRtmpEgress').tr(),
                    //     ],
                    //   ),
                    // ),
                    // PopupMenuItem(
                    //   value: 'hls-start',
                    //   child: Row(
                    //     children: [
                    //       const Icon(Symbols.play_circle),
                    //       const Gap(12),
                    //       const Text('enableHlsEgress').tr(),
                    //     ],
                    //   ),
                    // ),
                    // PopupMenuItem(
                    //   value: 'hls-stop',
                    //   child: Row(
                    //     children: [
                    //       const Icon(Symbols.stop_circle),
                    //       const Gap(12),
                    //       const Text('disableHlsEgress').tr(),
                    //     ],
                    //   ),
                    // ),
                    // if (stream.hlsPlaylistUrl != null &&
                    //     stream.hlsPlaylistUrl!.trim().isNotEmpty)
                    //   PopupMenuItem(
                    //     value: 'hls-copy',
                    //     child: Row(
                    //       children: [
                    //         const Icon(Symbols.content_copy),
                    //         const Gap(12),
                    //         const Text('copyHlsUrl').tr(),
                    //       ],
                    //     ),
                    //   ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Symbols.delete, color: Colors.red),
                          const Gap(12),
                          const Text('delete').tr().textColor(Colors.red),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'start') {
                      await _startStream(context, ref);
                    } else if (value == 'end') {
                      await _endStream(context, ref);
                    } else if (value == 'edit') {
                      await _editStream(context, ref);
                    } else if (value == 'thumbnail') {
                      await _updateThumbnail(context, ref);
                    } else if (value == 'thumbnail-clear') {
                      await _clearThumbnail(context, ref);
                    } else if (value == 'egress-start') {
                      await _startRtmpEgress(context, ref);
                    } else if (value == 'egress-stop') {
                      await _stopRtmpEgress(context, ref);
                    } else if (value == 'hls-start') {
                      await _startHlsEgress(context, ref);
                    } else if (value == 'hls-stop') {
                      await _stopHlsEgress(context, ref);
                    } else if (value == 'hls-copy') {
                      await Clipboard.setData(
                        ClipboardData(text: stream.hlsPlaylistUrl ?? ''),
                      );
                      showSnackBar('hlsUrlCopied'.tr());
                    } else if (value == 'delete') {
                      await _deleteStream(context, ref);
                    }
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description case final desc?
                          when desc.isNotEmpty) ...[
                        const Gap(2),
                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StartStreamMode { inApp, rtmp, whip }

class _StartStreamOptions {
  final _StartStreamMode mode;
  final bool enableTranscoding;

  const _StartStreamOptions({
    required this.mode,
    required this.enableTranscoding,
  });
}

class _StartStreamOptionsSheet extends HookWidget {
  const _StartStreamOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final mode = useState(_StartStreamMode.inApp);
    final enableTranscoding = useState(true);

    return SheetScaffold(
      titleText: 'Start Stream',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<_StartStreamMode>(
            value: _StartStreamMode.inApp,
            groupValue: mode.value,
            title: const Text('In-app Studio'),
            subtitle: const Text('No ingress, stream directly in app'),
            onChanged: (value) {
              if (value != null) mode.value = value;
            },
          ),
          RadioListTile<_StartStreamMode>(
            value: _StartStreamMode.rtmp,
            groupValue: mode.value,
            title: const Text('External (RTMP)'),
            subtitle: const Text('Create RTMP ingress'),
            onChanged: (value) {
              if (value != null) mode.value = value;
            },
          ),
          RadioListTile<_StartStreamMode>(
            value: _StartStreamMode.whip,
            groupValue: mode.value,
            title: const Text('External (WHIP)'),
            subtitle: const Text('Create WHIP ingress'),
            onChanged: (value) {
              if (value != null) mode.value = value;
            },
          ),
          SwitchListTile(
            value: enableTranscoding.value,
            onChanged: mode.value == _StartStreamMode.inApp
                ? null
                : (value) => enableTranscoding.value = value,
            title: const Text('Enable transcoding'),
            subtitle: const Text('Applies to external ingress modes'),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('cancel').tr(),
              ),
              const Gap(8),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    _StartStreamOptions(
                      mode: mode.value,
                      enableTranscoding: enableTranscoding.value,
                    ),
                  );
                },
                child: const Text('startStream').tr(),
              ),
            ],
          ),
          Gap(MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _CreateLivestreamSheet extends HookConsumerWidget {
  final String publisherId;
  final String publisherName;

  const _CreateLivestreamSheet({
    required this.publisherId,
    required this.publisherName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final slugController = useTextEditingController();
    final metadataController = useTextEditingController();
    final type = useState(0); // 0: Regular, 1: Interactive
    final visibility = useState(0); // 0: Public, 1: Unlisted, 2: Private
    final thumbnailId = useState<String?>(null);
    final isSubmitting = useState(false);

    Future<void> submit() async {
      if (isSubmitting.value) return;
      if (formKey.currentState?.validate() != true) return;
      final metadata = _tryParseJsonObject(metadataController.text);
      if (metadataController.text.trim().isNotEmpty && metadata == null) {
        showSnackBar('metadataMustBeValidJson'.tr());
        return;
      }

      isSubmitting.value = true;
      try {
        final client = ref.read(apiClientProvider);
        final payload = <String, dynamic>{
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'slug': slugController.text.trim(),
          'type': type.value,
          'visibility': visibility.value,
          'publisher_id': publisherId,
        };
        if (thumbnailId.value != null) {
          payload['thumbnail_id'] = thumbnailId.value;
        }
        if (metadata != null) {
          payload['metadata'] = metadata;
        }
        await client.post(
          '/sphere/livestreams',
          queryParameters: {'pub': publisherName},
          data: payload,
        );

        if (!context.mounted) return;
        showSnackBar('livestreamCreated'.tr());
        Navigator.of(context).pop(true);
      } catch (e) {
        showErrorAlert(e);
        isSubmitting.value = false;
      }
    }

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      );
    }

    return SheetScaffold(
      titleText: 'newLivestream',
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          children: [
            TextFormField(
              controller: titleController,
              decoration: inputDecoration('title'.tr()),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'pleaseEnterTitle'.tr();
                }
                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: inputDecoration('description'.tr()),
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            TextFormField(
              controller: slugController,
              decoration: inputDecoration('slug'.tr()),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'pleaseEnterSlug'.tr();
                }
                return null;
              },
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: type.value,
                    decoration: inputDecoration('type'.tr()),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('typeRegular'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('typeInteractive'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      type.value = value;
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: visibility.value,
                    decoration: inputDecoration('visibility'.tr()),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('visibilityPublic'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('visibilityUnlisted'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('visibilityPrivate'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      visibility.value = value;
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              leading: thumbnailId.value == null
                  ? const Icon(Symbols.image)
                  : SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CloudImageWidget(fileId: thumbnailId.value!),
                      ),
                    ),
              title: Text(
                thumbnailId.value == null
                    ? 'pickThumbnail'.tr()
                    : 'thumbnailSelected'.tr(),
              ),
              subtitle: thumbnailId.value == null
                  ? Text('optional'.tr())
                  : Text(thumbnailId.value!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      final picked = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => const CloudFilePicker(
                          allowedTypes: {UniversalFileType.image},
                        ),
                      );
                      final fileId = _extractCloudFileId(picked);
                      if (fileId != null) {
                        thumbnailId.value = fileId;
                      }
                    },
                    icon: const Icon(Symbols.cloud_upload),
                  ),
                  if (thumbnailId.value != null)
                    IconButton(
                      onPressed: () => thumbnailId.value = null,
                      icon: const Icon(Symbols.delete),
                    ),
                ],
              ),
            ),
            TextFormField(
              controller: metadataController,
              decoration: inputDecoration('metadataJson'.tr()),
              minLines: 2,
              maxLines: 5,
            ),
            FilledButton.icon(
              onPressed: isSubmitting.value ? null : submit,
              icon: isSubmitting.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Symbols.check),
              label: Text(isSubmitting.value ? 'creating'.tr() : 'create'.tr()),
            ),
          ],
        ),
      ).padding(vertical: 20, horizontal: 16),
    );
  }
}

class _EditLivestreamSheet extends HookConsumerWidget {
  final SnLiveStream stream;

  const _EditLivestreamSheet({required this.stream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController(text: stream.title ?? '');
    final descriptionController = useTextEditingController(
      text: stream.description ?? '',
    );
    final slugController = useTextEditingController(text: stream.slug ?? '');
    final metadataController = useTextEditingController(
      text: stream.metadata == null
          ? ''
          : const JsonEncoder.withIndent('  ').convert(stream.metadata),
    );
    final type = useState(stream.type.index);
    final visibility = useState(stream.visibility.index);
    final isSubmitting = useState(false);

    Future<void> submit() async {
      if (isSubmitting.value) return;
      if (formKey.currentState?.validate() != true) return;
      final metadata = _tryParseJsonObject(metadataController.text);
      if (metadataController.text.trim().isNotEmpty && metadata == null) {
        showSnackBar('metadataMustBeValidJson'.tr());
        return;
      }

      isSubmitting.value = true;
      try {
        final client = ref.read(apiClientProvider);
        final payload = <String, dynamic>{
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'slug': slugController.text.trim(),
          'type': type.value,
          'visibility': visibility.value,
        };
        if (metadata != null) {
          payload['metadata'] = metadata;
        }
        await client.patch('/sphere/livestreams/${stream.id}', data: payload);
        if (!context.mounted) return;
        showSnackBar('livestreamUpdated'.tr());
        Navigator.of(context).pop(true);
      } catch (e) {
        showErrorAlert(e);
        isSubmitting.value = false;
      }
    }

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );
    }

    return SheetScaffold(
      titleText: 'editLivestream',
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          children: [
            TextFormField(
              controller: titleController,
              decoration: inputDecoration('title'.tr()),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'titleRequired'.tr()
                  : null,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: inputDecoration('description'.tr()),
              minLines: 2,
              maxLines: 4,
            ),
            TextFormField(
              controller: slugController,
              decoration: inputDecoration('slug'.tr()),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'slugRequired'.tr()
                  : null,
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: type.value,
                    decoration: inputDecoration('type'.tr()),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('typeRegular'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('typeInteractive'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) type.value = value;
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: visibility.value,
                    decoration: inputDecoration('visibility'.tr()),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('visibilityPublic'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('visibilityUnlisted'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('visibilityPrivate'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) visibility.value = value;
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: metadataController,
              decoration: inputDecoration('metadataJson'.tr()),
              minLines: 2,
              maxLines: 5,
            ),
            FilledButton.icon(
              onPressed: isSubmitting.value ? null : submit,
              icon: isSubmitting.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Symbols.check),
              label: const Text('save').tr(),
            ),
          ],
        ),
      ).padding(vertical: 20, horizontal: 16),
    );
  }
}

class _RtmpEgressSheet extends HookWidget {
  const _RtmpEgressSheet();

  @override
  Widget build(BuildContext context) {
    final urlsController = useTextEditingController();
    final filePathController = useTextEditingController();

    return SheetScaffold(
      titleText: 'startRtmpEgressTitle',
      child: Column(
        spacing: 12,
        children: [
          TextField(
            controller: urlsController,
            decoration: const InputDecoration(
              labelText: 'rtmpUrlsOnePerLine',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            minLines: 3,
            maxLines: 6,
          ),
          TextField(
            controller: filePathController,
            decoration: const InputDecoration(
              labelText: 'recordingFilePathOptional',
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

class _HlsEgressSheet extends HookWidget {
  const _HlsEgressSheet();

  @override
  Widget build(BuildContext context) {
    final playlistController = useTextEditingController(text: 'playlist.m3u8');
    final segmentDurationController = useTextEditingController(text: '6');
    final segmentCountController = useTextEditingController(text: '0');
    final layoutController = useTextEditingController();
    final hlsBaseUrlController = useTextEditingController();

    return SheetScaffold(
      titleText: 'enableHlsEgressTitle',
      child: Column(
        spacing: 12,
        children: [
          TextField(
            controller: playlistController,
            decoration: const InputDecoration(
              labelText: 'playlistName',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: TextField(
                  controller: segmentDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'segmentDuration',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: segmentCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'segmentCount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextField(
            controller: layoutController,
            decoration: const InputDecoration(
              labelText: 'layoutOptional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          TextField(
            controller: hlsBaseUrlController,
            decoration: const InputDecoration(
              labelText: 'hlsBaseUrlOptional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop({
                'playlist_name': playlistController.text.trim(),
                'segment_duration':
                    int.tryParse(segmentDurationController.text.trim()) ?? 6,
                'segment_count':
                    int.tryParse(segmentCountController.text.trim()) ?? 0,
                if (layoutController.text.trim().isNotEmpty)
                  'layout': layoutController.text.trim(),
                if (hlsBaseUrlController.text.trim().isNotEmpty)
                  'hls_base_url': hlsBaseUrlController.text.trim(),
              });
            },
            icon: const Icon(Symbols.play_arrow),
            label: const Text('enable').tr(),
          ),
        ],
      ).padding(horizontal: 16, vertical: 20),
    );
  }
}

class _CopyField extends StatelessWidget {
  final String label;
  final String value;

  const _CopyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const Gap(4),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Symbols.content_copy),
              onPressed: value.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      showSnackBar('copied'.tr());
                    },
            ),
          ],
        ),
      ],
    );
  }
}
