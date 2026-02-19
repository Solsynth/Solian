import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/core/network.dart';
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
      builder: (context) =>
          _CreateLivestreamSheet(pubName: pubName, publisherId: publisherId),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _statusText(stream.status);
    final statusColor = _statusColor(context, status);
    final title = stream.title ?? 'Untitled Livestream';
    final description = stream.description;
    final viewerCount = stream.viewerCount.toString();
    final createdAt = stream.createdAt;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(Symbols.live_tv, color: statusColor),
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
          ],
          onSelected: (value) async {
            if (value == 'start') {
              await _startStream(context, ref);
            } else if (value == 'end') {
              await _endStream(context, ref);
            }
          },
        ),
      ),
    );
  }
}

class _CreateLivestreamSheet extends HookConsumerWidget {
  final String pubName;
  final String publisherId;

  const _CreateLivestreamSheet({
    required this.pubName,
    required this.publisherId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final slugController = useTextEditingController();
    final type = useState(0); // 0: Regular, 1: Interactive
    final visibility = useState(0); // 0: Public, 1: Unlisted, 2: Private
    final isSubmitting = useState(false);

    Future<void> submit() async {
      if (isSubmitting.value) return;
      if (formKey.currentState?.validate() != true) return;

      isSubmitting.value = true;
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/sphere/livestreams',
          data: {
            'title': titleController.text.trim(),
            'description': descriptionController.text.trim(),
            'slug': slugController.text.trim(),
            'type': type.value,
            'visibility': visibility.value,
            'publisher_id': publisherId,
          },
        );

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
