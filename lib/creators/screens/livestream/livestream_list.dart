import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
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
  ) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateLivestreamSheet(publisherId: publisherId),
    );

    if (created == true) {
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisherAsync = ref.watch(publisherNullableProvider(pubName));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: const Text('Livestreams'),
      ),
      floatingActionButton: publisherAsync.when(
        data: (publisher) => publisher == null
            ? null
            : FloatingActionButton(
                onPressed: () => _createLivestream(context, ref, publisher.id),
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
              title: 'Publisher Not Found',
              description: 'Unable to resolve publisher for livestreams.',
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
                  title: 'No Livestreams',
                  description: 'Create a livestream to start broadcasting.',
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
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
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
      SnLiveStreamStatus.pending => 'Pending',
      SnLiveStreamStatus.active => 'Active',
      SnLiveStreamStatus.ended => 'Ended',
      SnLiveStreamStatus.error => 'Error',
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
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/sphere/livestreams/$_id/start',
        data: <String, dynamic>{},
      );
      final data = Map<String, dynamic>.from(response.data);
      final rtmpUrl =
          data['rtmp_url'] ??
          data['rtmpUrl'] ??
          data['RtmpUrl'] ??
          data['url'] ??
          '';
      final streamKey =
          data['stream_key'] ?? data['streamKey'] ?? data['StreamKey'] ?? '';
      final roomName =
          data['room_name'] ?? data['roomName'] ?? data['RoomName'] ?? '';
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('RTMP Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CopyField(label: 'RTMP URL', value: rtmpUrl.toString()),
              const Gap(12),
              _CopyField(label: 'Stream Key', value: streamKey.toString()),
              if (roomName.toString().isNotEmpty) ...[
                const Gap(12),
                _CopyField(label: 'Room Name', value: roomName.toString()),
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
      'Are you sure you want to end this livestream?',
      'End Livestream',
      isDanger: true,
    );
    if (confirmed != true) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/end');
      showSnackBar('Livestream ended.');
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
      showSnackBar('Thumbnail updated.');
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
      showSnackBar('Thumbnail removed.');
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
      showSnackBar('RTMP egress started.');
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _stopRtmpEgress(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/egress/stop');
      showSnackBar('RTMP egress stopped.');
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
      showSnackBar('HLS egress started.');
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _stopHlsEgress(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/livestreams/$_id/hls/stop');
      showSnackBar('HLS egress stopped.');
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _deleteStream(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'Delete this livestream permanently?',
      'Delete Livestream',
      isDanger: true,
    );
    if (confirmed != true) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.delete('/sphere/livestreams/$_id');
      showSnackBar('Livestream deleted.');
      ref.invalidate(creatorLivestreamListProvider(publisherId));
    } catch (e) {
      showErrorAlert(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _statusText(stream.status);
    final statusColor = _statusColor(context, status);
    final title = stream.title ?? 'Untitled Livestream';
    final description = stream.description;
    final viewerCount = stream.viewerCount.toString();
    final createdAt = stream.createdAt;
    final hasHls = stream.hlsPlaylistUrl != null && stream.hlsPlaylistUrl != '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: stream.thumbnail?.id != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CloudImageWidget(fileId: stream.thumbnail!.id),
                ),
              )
            : Icon(Symbols.live_tv, color: statusColor),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null && description.isNotEmpty)
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Gap(4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(status),
                  side: BorderSide.none,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('Viewers: $viewerCount'),
                  side: BorderSide.none,
                ),
                if (hasHls)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('HLS Enabled'),
                    side: BorderSide.none,
                  ),
                if (createdAt != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      DateFormat.yMd().add_jm().format(createdAt.toLocal()),
                    ),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Symbols.edit),
                  const Gap(12),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'thumbnail',
              child: Row(
                children: [
                  const Icon(Symbols.image),
                  const Gap(12),
                  const Text('Update Thumbnail'),
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
                    const Text('Remove Thumbnail'),
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
                    const Text('Start Stream'),
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
                    const Text('End Stream').textColor(Colors.red),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'egress-start',
              child: Row(
                children: [
                  const Icon(Symbols.outbound),
                  const Gap(12),
                  const Text('Start RTMP Egress'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'egress-stop',
              child: Row(
                children: [
                  const Icon(Symbols.outbound),
                  const Gap(12),
                  const Text('Stop RTMP Egress'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'hls-start',
              child: Row(
                children: [
                  const Icon(Symbols.play_circle),
                  const Gap(12),
                  const Text('Enable HLS Egress'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'hls-stop',
              child: Row(
                children: [
                  const Icon(Symbols.stop_circle),
                  const Gap(12),
                  const Text('Disable HLS Egress'),
                ],
              ),
            ),
            if (stream.hlsPlaylistUrl != null &&
                stream.hlsPlaylistUrl!.trim().isNotEmpty)
              PopupMenuItem(
                value: 'hls-copy',
                child: Row(
                  children: [
                    const Icon(Symbols.content_copy),
                    const Gap(12),
                    const Text('Copy HLS URL'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Symbols.delete, color: Colors.red),
                  const Gap(12),
                  const Text('Delete').textColor(Colors.red),
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
              showSnackBar('HLS URL copied.');
            } else if (value == 'delete') {
              await _deleteStream(context, ref);
            }
          },
        ),
      ),
    );
  }
}

class _CreateLivestreamSheet extends HookConsumerWidget {
  final String publisherId;

  const _CreateLivestreamSheet({required this.publisherId});

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
        showSnackBar('Metadata must be a valid JSON object.');
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
        await client.post('/sphere/livestreams', data: payload);

        if (!context.mounted) return;
        showSnackBar('Livestream created.');
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
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return SheetScaffold(
      titleText: 'New Livestream',
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          children: [
            TextFormField(
              controller: titleController,
              decoration: inputDecoration('Title'),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: inputDecoration('Description'),
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            TextFormField(
              controller: slugController,
              decoration: inputDecoration('Slug'),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a slug';
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
                    decoration: inputDecoration('Type'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Regular')),
                      DropdownMenuItem(value: 1, child: Text('Interactive')),
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
                    decoration: inputDecoration('Visibility'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Public')),
                      DropdownMenuItem(value: 1, child: Text('Unlisted')),
                      DropdownMenuItem(value: 2, child: Text('Private')),
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
                    ? 'Pick Thumbnail'
                    : 'Thumbnail Selected',
              ),
              subtitle: thumbnailId.value == null
                  ? const Text('Optional')
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
              decoration: inputDecoration('Metadata JSON'),
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
              label: Text(isSubmitting.value ? 'creating'.tr() : 'create').tr(),
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
        showSnackBar('Metadata must be a valid JSON object.');
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
        showSnackBar('Livestream updated.');
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
      titleText: 'Edit Livestream',
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          children: [
            TextFormField(
              controller: titleController,
              decoration: inputDecoration('Title'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Title is required'
                  : null,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: inputDecoration('Description'),
              minLines: 2,
              maxLines: 4,
            ),
            TextFormField(
              controller: slugController,
              decoration: inputDecoration('Slug'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Slug is required'
                  : null,
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: type.value,
                    decoration: inputDecoration('Type'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Regular')),
                      DropdownMenuItem(value: 1, child: Text('Interactive')),
                    ],
                    onChanged: (value) {
                      if (value != null) type.value = value;
                    },
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: visibility.value,
                    decoration: inputDecoration('Visibility'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Public')),
                      DropdownMenuItem(value: 1, child: Text('Unlisted')),
                      DropdownMenuItem(value: 2, child: Text('Private')),
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
              decoration: inputDecoration('Metadata JSON'),
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
              label: const Text('Save'),
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
      titleText: 'Start RTMP Egress',
      child: Column(
        spacing: 12,
        children: [
          TextField(
            controller: urlsController,
            decoration: const InputDecoration(
              labelText: 'RTMP URLs (one per line)',
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
              labelText: 'Recording file path (optional)',
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
            label: const Text('Start'),
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
      titleText: 'Enable HLS Egress',
      child: Column(
        spacing: 12,
        children: [
          TextField(
            controller: playlistController,
            decoration: const InputDecoration(
              labelText: 'Playlist name',
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
                    labelText: 'Segment duration',
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
                    labelText: 'Segment count',
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
              labelText: 'Layout (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          TextField(
            controller: hlsBaseUrlController,
            decoration: const InputDecoration(
              labelText: 'HLS Base URL (optional)',
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
            label: const Text('Enable'),
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
                      showSnackBar('Copied');
                    },
            ),
          ],
        ),
      ],
    );
  }
}
