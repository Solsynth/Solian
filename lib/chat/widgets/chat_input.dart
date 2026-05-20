import "dart:async";
import "package:desktop_drop/desktop_drop.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:island/accounts/utils/account_status_utils.dart";
import "package:island/discovery/models/autocomplete_response.dart";
import "package:island/chat/e2ee_message_display.dart";
import "package:island/e2ee/e2ee.dart";
import "package:island/chat/messages_notifier.dart";
import "package:island/chat/pods/chat_online_count.dart";
import "package:island/posts/widgets/compose/compose_fund.dart";
import "package:island/posts/widgets/compose/compose_location_sheet.dart";
import "package:island/posts/widgets/compose/compose_meet_sheet.dart";
import "package:island/posts/widgets/compose/compose_poll.dart";
import "package:island/stickers/widgets/stickers/sticker_picker.dart";
import "package:island/stickers/models/sticker.dart";
import "package:island/core/config.dart";
import "package:island/accounts/account_pod.dart";
import "package:island/discovery/discovery_service.dart";
import "package:island/chat/pods/chat_room.dart";
import "package:island/core/services/responsive.dart";
import "package:island/core/widgets/content/attachment_preview.dart";
import "package:island/drive/drive_service.dart";
import "package:island/drive/widgets/cloud_files.dart";
import "package:island/posts/widgets/compose/compose_link_attachments.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:pasteboard/pasteboard.dart";
import "package:path_provider/path_provider.dart";
import "package:record/record.dart" as rec;
import "package:island/shared/widgets/alert.dart";
import "package:styled_widget/styled_widget.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:island/chat/pods/chat_subscribe.dart";
import "package:uuid/uuid.dart";
import 'package:solar_network_sdk/solar_network_sdk.dart';
import "package:waveform_flutter/waveform_flutter.dart";

void _insertPlaceholder(TextEditingController controller, String placeholder) {
  final text = controller.text;
  final selection = controller.selection;
  final start = selection.start >= 0 ? selection.start : text.length;
  final end = selection.end >= 0 ? selection.end : text.length;
  final newText = text.replaceRange(start, end, placeholder);
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: start + placeholder.length),
  );
}

/// Recursively converts all keys in a map to snake_case
/// This ensures compatibility with JSON parsers that expect snake_case keys
Map<String, dynamic> _convertKeysToSnakeCase(Map map) {
  final result = <String, dynamic>{};

  map.forEach((key, value) {
    // Convert camelCase/PascalCase to snake_case correctly
    // Handles:
    // - camelCase -> camel_case
    // - PascalCase -> pascal_case
    // - Id -> id
    // - accountId -> account_id
    // - HTTPRequest -> http_request
    String snakeKey = key
        .replaceAllMapped(
          RegExp(r'(?<!^)([A-Z])'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .toLowerCase();

    // Handle sequences of uppercase letters properly
    snakeKey = snakeKey.replaceAllMapped(
      RegExp(r'([A-Z]+)([A-Z][a-z])'),
      (match) =>
          '${match.group(1)!.toLowerCase()}_${match.group(2)!.toLowerCase()}',
    );

    // Recursively process nested maps
    if (value is Map) {
      result[snakeKey] = _convertKeysToSnakeCase(value);
    }
    // Recursively process lists that contain maps
    else if (value is List) {
      result[snakeKey] = value.map((item) {
        if (item is Map) {
          return _convertKeysToSnakeCase(item);
        }
        return item;
      }).toList();
    }
    // Directly assign primitive values
    else {
      result[snakeKey] = value;
    }
  });

  return result;
}

const kInputDrawerExpandedHeight = 280.0;

const kExpandedSectionTabHeight = 32.0;

class _DirectMessageStatusBanner extends ConsumerWidget {
  final SnChatRoom chatRoom;
  final List<SnChatMember> validMembers;

  const _DirectMessageStatusBanner({
    required this.chatRoom,
    required this.validMembers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chatRoom.type != 1) {
      return const SizedBox.shrink();
    }

    final dmMember = validMembers.firstOrNull;
    final onlineStatus = ref.watch(chatOnlineCountProvider(chatRoom.id));
    final status = onlineStatus.value?.directMessageStatus;

    final shouldShowHint =
        status != null &&
        (status.type == SnAccountStatusType.busy ||
            status.type == SnAccountStatusType.doNotDisturb);

    if (dmMember == null || !shouldShowHint) {
      return const SizedBox.shrink();
    }

    return Container(
      key: ValueKey('dm-status-${dmMember.accountId}-${status.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 4),
      child: Row(
        children: [
          Icon(
            getStatusIndicatorIcon(status),
            fill: getStatusIndicatorFill(status),
            size: 18,
            color: getStatusIndicatorColor(status),
          ),
          const Gap(8),
          Flexible(
            child: Text(
              'chatDirectMessageStatusHint'.tr(
                args: [getStatusDisplayLabel(context, status)],
              ),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTimeoutBanner extends StatelessWidget {
  final DateTime timeoutUntil;

  const _ChatTimeoutBanner({required this.timeoutUntil});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('chat-timeout-${timeoutUntil.toUtc().toIso8601String()}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 4),
      child: Row(
        children: [
          Icon(
            Symbols.timer_pause,
            size: 18,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              'You are timed out until ${DateFormat('yyyy-MM-dd HH:mm').format(timeoutUntil.toLocal())}. You cannot send messages right now.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicatorDots extends StatefulWidget {
  const _TypingIndicatorDots();

  @override
  State<_TypingIndicatorDots> createState() => _TypingIndicatorDotsState();
}

class _TypingIndicatorDotsState extends State<_TypingIndicatorDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotProgress(int index) {
    final offset = index * 0.18;
    final progress = (_controller.value - offset) % 1.0;
    if (progress < 0.5) {
      return Curves.easeOut.transform(progress / 0.5);
    }
    return 1 - Curves.easeIn.transform((progress - 0.5) / 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 32,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final progress = _dotProgress(index);
              final size = 4.0 + (progress * 3.0);

              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    baseColor.withOpacity(0.35),
                    baseColor,
                    progress,
                  ),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _ExpandedSection extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onPickAudio;
  final VoidCallback onPickGeneralFile;
  final List<UniversalFile> attachments;
  final Function(int, {String? encryptKey}) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;
  final Map<String, Map<int, double?>> attachmentProgress;
  final String? roomEncryptKey;
  final SnPoll? selectedPoll;
  final Function(SnPoll?) onPollSelected;
  final SnWalletFund? selectedFund;
  final Function(SnWalletFund?) onFundSelected;
  final String? selectedLocationName;
  final String? selectedLocationAddress;
  final String? selectedLocationWkt;
  final String? selectedMeetId;
  final Function({String? name, String? address, String? wkt})?
  onLocationSelected;
  final Function(String?)? onMeetSelected;
  final bool isE2eeRoom;
  final VoidCallback onEnableVoiceMode;

  const _ExpandedSection({
    required this.messageController,
    required this.onSendMessage,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onPickAudio,
    required this.onPickGeneralFile,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
    required this.attachmentProgress,
    required this.roomEncryptKey,
    this.selectedPoll,
    required this.onPollSelected,
    this.selectedFund,
    required this.onFundSelected,
    this.selectedLocationName,
    this.selectedLocationAddress,
    this.selectedLocationWkt,
    this.selectedMeetId,
    this.onLocationSelected,
    this.onMeetSelected,
    this.isE2eeRoom = false,
    required this.onEnableVoiceMode,
  });

  @override
  State<_ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<_ExpandedSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _lastReportedTabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      initialIndex: widget.selectedTabIndex.clamp(0, 2),
      vsync: this,
    );
    _lastReportedTabIndex = _tabController.index;
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == _lastReportedTabIndex) return;
    _lastReportedTabIndex = _tabController.index;
    widget.onTabChanged(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('expanded'),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      margin: const EdgeInsets.only(top: 8, bottom: 3),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(kExpandedSectionTabHeight),
              child: TabBar(
                controller: _tabController,
                splashBorderRadius: const BorderRadius.all(Radius.circular(40)),
                tabs: [
                  Tab(text: 'features'.tr(), height: kExpandedSectionTabHeight),
                  Tab(
                    height: kExpandedSectionTabHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('attachments'.tr()),
                        if (widget.attachments.isNotEmpty) ...[
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              widget.attachments.length.toString(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(text: 'stickers'.tr(), height: kExpandedSectionTabHeight),
                ],
              ),
            ),
            SizedBox(
              height: kInputDrawerExpandedHeight,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SizedBox(
                    height: kInputDrawerExpandedHeight,
                    child: GridView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 120,
                            childAspectRatio: 1, // 1:1 aspect ratio
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      children: [
                        InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          onTap: () async {
                            final poll = await showModalBottomSheet<SnPoll>(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => const ComposePollSheet(),
                            );
                            if (poll != null) {
                              widget.onPollSelected(poll);
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Symbols.poll),
                                const Gap(4),
                                Text(
                                  'Poll',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          onTap: widget.onEnableVoiceMode,
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Symbols.mic),
                                const Gap(4),
                                Text(
                                  'Voice',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          onTap: () async {
                            final fund =
                                await showModalBottomSheet<SnWalletFund>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      const ComposeFundSheet(),
                                );
                            if (fund != null) {
                              widget.onFundSelected(fund);
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Symbols.currency_exchange),
                                const Gap(4),
                                Text(
                                  'fund'.tr(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!widget.isE2eeRoom)
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            onTap: () async {
                              final location =
                                  await showModalBottomSheet<
                                    Map<String, String?>
                                  >(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        const ComposeLocationSheet(),
                                  );
                              if (location != null) {
                                widget.onLocationSelected?.call(
                                  name: location['name'],
                                  address: location['address'],
                                  wkt: location['wkt'],
                                );
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.location_on),
                                  const Gap(4),
                                  Text(
                                    'location'.tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!widget.isE2eeRoom)
                          InkWell(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            onTap: () async {
                              final meetId = await showModalBottomSheet<String>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => const ComposeMeetSheet(),
                              );
                              if (meetId != null) {
                                widget.onMeetSelected?.call(meetId);
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Symbols.groups),
                                  const Gap(4),
                                  Text(
                                    'meet'.tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _AttachmentsExpandedTab(
                    onPickPhoto: widget.onPickPhoto,
                    onPickVideo: widget.onPickVideo,
                    onPickAudio: widget.onPickAudio,
                    onPickGeneralFile: widget.onPickGeneralFile,
                    attachments: widget.attachments,
                    onUploadAttachment: widget.onUploadAttachment,
                    onDeleteAttachment: widget.onDeleteAttachment,
                    onMoveAttachment: widget.onMoveAttachment,
                    onAttachmentsChanged: widget.onAttachmentsChanged,
                    attachmentProgress: widget.attachmentProgress,
                    roomEncryptKey: widget.roomEncryptKey,
                  ),
                  StickerPickerEmbedded(
                    height: kInputDrawerExpandedHeight,
                    onPick: (pack, sticker) {
                      final placeholder = ':${pack.prefix}+${sticker.slug}:';
                      if (sticker.mode == 0) {
                        widget.messageController.value = TextEditingValue(
                          text: placeholder,
                          selection: TextSelection.collapsed(
                            offset: placeholder.length,
                          ),
                        );
                        widget.onSendMessage();
                        return;
                      }

                      _insertPlaceholder(widget.messageController, placeholder);
                    },
                    onLongPress: (pack, sticker) {
                      final placeholder = ':${pack.prefix}+${sticker.slug}:';
                      _insertPlaceholder(widget.messageController, placeholder);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _AttachmentsExpandedTab extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onPickAudio;
  final VoidCallback onPickGeneralFile;
  final List<UniversalFile> attachments;
  final Function(int, {String? encryptKey}) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;
  final Map<String, Map<int, double?>> attachmentProgress;
  final String? roomEncryptKey;

  const _AttachmentsExpandedTab({
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onPickAudio,
    required this.onPickGeneralFile,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
    required this.attachmentProgress,
    required this.roomEncryptKey,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _AttachmentAction(
        icon: Symbols.add_a_photo,
        label: 'addPhoto'.tr(),
        onTap: onPickPhoto,
      ),
      _AttachmentAction(
        icon: Symbols.videocam,
        label: 'addVideo'.tr(),
        onTap: onPickVideo,
      ),
      _AttachmentAction(
        icon: Symbols.mic,
        label: 'addAudio'.tr(),
        onTap: onPickAudio,
      ),
      _AttachmentAction(
        icon: Symbols.file_upload,
        label: 'uploadFile'.tr(),
        onTap: onPickGeneralFile,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minCardWidth = 112.0;
              const gap = 8.0;
              const horizontalPadding = 24.0;
              final availableWidth = constraints.maxWidth - horizontalPadding;
              final sharedWidth =
                  (availableWidth - gap * (actions.length - 1)) /
                  actions.length;
              final shouldShareWidth = sharedWidth >= minCardWidth;

              Widget buildAction(_AttachmentAction action) => SizedBox(
                width: shouldShareWidth ? sharedWidth : minCardWidth,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: action.onTap,
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action.icon, size: 20),
                          const Gap(6),
                          Flexible(
                            child: Text(
                              action.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              if (shouldShareWidth) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        buildAction(actions[i]),
                        if (i != actions.length - 1) const Gap(gap),
                      ],
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                scrollDirection: Axis.horizontal,
                itemCount: actions.length,
                separatorBuilder: (_, _) => const Gap(gap),
                itemBuilder: (context, index) => buildAction(actions[index]),
              );
            },
          ),
        ),
        Expanded(
          child: CloudFileLinkPicker(
            padding: const EdgeInsets.all(8),
            recentUploadsSliverHeaders: [
              if (attachments.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                    child: _AttachmentPreviewStrip(
                      attachments: attachments,
                      onUploadAttachment: onUploadAttachment,
                      onDeleteAttachment: onDeleteAttachment,
                      onMoveAttachment: onMoveAttachment,
                      onAttachmentsChanged: onAttachmentsChanged,
                      attachmentProgress: attachmentProgress,
                      roomEncryptKey: roomEncryptKey,
                    ),
                  ).padding(vertical: 10),
                ),
              if (attachments.isNotEmpty)
                const SliverToBoxAdapter(child: Divider(height: 1)),
            ],
            onSelected: (file) {
              final linkAttachment = UniversalFile.fromAttachment(
                file,
              ).copyWith(isLink: true);
              final alreadyLinked = attachments.any(
                (item) => item.isOnCloud && item.data.id == file.id,
              );
              if (alreadyLinked) return;
              onAttachmentsChanged([...attachments, linkAttachment]);
            },
          ),
        ),
      ],
    );
  }
}

class _AttachmentPreviewStrip extends StatelessWidget {
  final List<UniversalFile> attachments;
  final Function(int, {String? encryptKey}) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;
  final Map<String, Map<int, double?>> attachmentProgress;
  final String? roomEncryptKey;

  const _AttachmentPreviewStrip({
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
    required this.attachmentProgress,
    required this.roomEncryptKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: attachments.length,
      itemBuilder: (context, idx) {
        return SizedBox(
          width: 180,
          child: AttachmentPreview(
            isCompact: true,
            item: attachments[idx],
            progress: attachmentProgress['chat-upload']?[idx],
            isUploading:
                attachmentProgress['chat-upload']?.containsKey(idx) ?? false,
            onRequestUpload: () =>
                onUploadAttachment(idx, encryptKey: roomEncryptKey),
            onDelete: () => onDeleteAttachment(idx),
            onUpdate: (value) {
              final clone = List<UniversalFile>.of(attachments);
              clone[idx] = value;
              onAttachmentsChanged(clone);
            },
            onMove: (delta) => onMoveAttachment(idx, delta),
          ),
        );
      },
      separatorBuilder: (_, _) => const Gap(8),
    );
  }
}

class ChatInput extends HookConsumerWidget {
  final TextEditingController messageController;
  final SnChatRoom chatRoom;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final Function(bool isPhoto) onPickFile;
  final VoidCallback onPickAudio;
  final VoidCallback onPickGeneralFile;
  final VoidCallback? onLinkAttachment;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnChatMessage? messageEditingTo;
  final List<UniversalFile> attachments;
  final Function(int, {String? encryptKey}) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;
  final Map<String, Map<int, double?>> attachmentProgress;
  final SnPoll? selectedPoll;
  final Function(SnPoll?) onPollSelected;
  final SnWalletFund? selectedFund;
  final Function(SnWalletFund?) onFundSelected;
  final String? selectedLocationName;
  final String? selectedLocationAddress;
  final String? selectedLocationWkt;
  final String? selectedMeetId;
  final Function({String? name, String? address, String? wkt})?
  onLocationSelected;
  final Function(String?)? onMeetSelected;
  final bool isMessageListScrolling;

  const ChatInput({
    super.key,
    required this.messageController,
    required this.chatRoom,
    required this.onSend,
    required this.onClear,
    required this.onPickFile,
    required this.onPickAudio,
    required this.onPickGeneralFile,
    this.onLinkAttachment,
    required this.messageReplyingTo,
    required this.messageForwardingTo,
    required this.messageEditingTo,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
    required this.attachmentProgress,
    this.selectedPoll,
    required this.onPollSelected,
    this.selectedFund,
    required this.onFundSelected,
    this.selectedLocationName,
    this.selectedLocationAddress,
    this.selectedLocationWkt,
    this.selectedMeetId,
    this.onLocationSelected,
    this.onMeetSelected,
    required this.isMessageListScrolling,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputFocusNode = useFocusNode();
    final roomIdentity = ref.watch(chatRoomIdentityProvider(chatRoom.id));
    final chatSubscribe = ref.watch(chatSubscribeProvider(chatRoom.id));
    final isExpanded = useState(false);
    final expandedTabIndex = useState(0);
    final isDraggingOver = useState(false);
    final isVoiceMode = useState(false);
    final isRecordingVoice = useState(false);
    final isVoiceCancelArmed = useState(false);
    final recordingDuration = useState(Duration.zero);
    final recordingOrigin = useState<Offset?>(null);
    final recordingPath = useState<String?>(null);
    final recorder = useMemoized(() => rec.AudioRecorder(), []);
    final amplitudeStream = useMemoized(
      () => StreamController<Amplitude>.broadcast(),
      [],
    );
    final amplitudeSub = useRef<StreamSubscription<rec.Amplitude>?>(null);
    final recordingTicker = useRef<Timer?>(null);
    final recordingStartedAt = useRef<DateTime?>(null);
    final messagesNotifier = ref.read(messagesProvider(chatRoom.id).notifier);
    const maxVoiceRecordDuration = Duration(minutes: 5);
    final timeoutUntil = roomIdentity.value?.timeoutUntil;
    final hasActiveTimeout =
        timeoutUntil != null && timeoutUntil.isAfter(DateTime.now());
    final canCompose = !hasActiveTimeout;

    useEffect(() {
      return () {
        recordingTicker.value?.cancel();
        amplitudeSub.value?.cancel();
        amplitudeStream.close();
        recorder.dispose();
      };
    }, [recorder, amplitudeStream]);

    void send() {
      if (!canCompose) return;
      if (isExpanded.value) isExpanded.value = false;
      onSend.call();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          inputFocusNode.requestFocus();
        }
      });
    }

    late Future<void> Function({required bool shouldCancel})
    finishVoiceRecording;

    Future<void> startVoiceRecording() async {
      if (!canCompose) return;
      if (kIsWeb) {
        showSnackBar('Voice recording is not supported on web yet.');
        return;
      }
      if (isRecordingVoice.value) return;
      if (!await recorder.hasPermission()) {
        showErrorAlert('Microphone permission denied.');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/chat-voice-${const Uuid().v4().substring(0, 8)}.m4a';

      const config = rec.RecordConfig(
        encoder: rec.AudioEncoder.aacLc,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      );
      await recorder.start(config, path: path);

      recordingPath.value = path;
      recordingStartedAt.value = DateTime.now();
      recordingDuration.value = Duration.zero;
      isVoiceCancelArmed.value = false;
      isRecordingVoice.value = true;
      amplitudeSub.value?.cancel();
      amplitudeSub.value = recorder
          .onAmplitudeChanged(const Duration(milliseconds: 90))
          .listen((value) {
            amplitudeStream.add(
              Amplitude(current: value.current, max: value.max),
            );
          });

      recordingTicker.value?.cancel();
      recordingTicker.value = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) async {
          final startedAt = recordingStartedAt.value;
          if (startedAt == null) return;
          final elapsed = DateTime.now().difference(startedAt);
          if (elapsed >= maxVoiceRecordDuration) {
            recordingDuration.value = maxVoiceRecordDuration;
            showSnackBar('Max recording duration (5 minutes) reached.');
            await finishVoiceRecording(shouldCancel: false);
            return;
          }
          recordingDuration.value = elapsed;
        },
      );
    }

    finishVoiceRecording = ({required bool shouldCancel}) async {
      if (!isRecordingVoice.value) return;
      isRecordingVoice.value = false;
      recordingTicker.value?.cancel();
      amplitudeSub.value?.cancel();

      String? resultPath;
      try {
        resultPath = await recorder.stop();
      } catch (_) {}

      if (shouldCancel) {
        isVoiceCancelArmed.value = false;
        recordingOrigin.value = null;
        recordingDuration.value = Duration.zero;
        return;
      }

      final cappedDuration = recordingDuration.value > maxVoiceRecordDuration
          ? maxVoiceRecordDuration
          : recordingDuration.value;
      final durationMs = cappedDuration.inMilliseconds;
      final path = resultPath ?? recordingPath.value;
      if (path == null || path.isEmpty || durationMs <= 0) {
        showErrorAlert('Failed to record voice message.');
        return;
      }

      try {
        await messagesNotifier.sendVoiceMessage(
          path,
          durationMs: durationMs,
          replyingTo: messageReplyingTo,
          forwardingTo: messageForwardingTo,
        );
        onClear();
      } catch (_) {
        // Error UI already handled by notifier.
      } finally {
        isVoiceCancelArmed.value = false;
        recordingOrigin.value = null;
        recordingDuration.value = Duration.zero;
      }
    };

    void leaveVoiceMode() {
      if (isRecordingVoice.value) {
        unawaited(finishVoiceRecording(shouldCancel: true));
      }
      isVoiceMode.value = false;
    }

    useEffect(() {
      if (hasActiveTimeout) {
        isExpanded.value = false;
        if (isVoiceMode.value) {
          leaveVoiceMode();
        }
      }
      return null;
    }, [hasActiveTimeout]);

    void insertNewLine() {
      final text = messageController.text;
      final selection = messageController.selection;
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;
      final newText = text.replaceRange(start, end, '\n');
      messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + 1),
      );
    }

    Future<void> handlePaste() async {
      final image = await Pasteboard.image;
      if (image != null) {
        onAttachmentsChanged([
          ...attachments,
          UniversalFile(
            displayName: 'image.jpeg',
            data: XFile.fromData(
              image,
              mimeType: "image/jpeg",
              name: 'image.jpeg',
            ),
            type: UniversalFileType.image,
          ),
        ]);
        return;
      }

      final textData = await Clipboard.getData(Clipboard.kTextPlain);
      if (textData != null && textData.text != null) {
        final text = messageController.text;
        final selection = messageController.selection;
        final start = selection.start >= 0 ? selection.start : text.length;
        final end = selection.end >= 0 ? selection.end : text.length;
        final newText = text.replaceRange(start, end, textData.text!);
        messageController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: start + textData.text!.length,
          ),
        );
      }
    }

    Future<void> handleDroppedFiles(DropDoneDetails details) async {
      final droppedFiles = <UniversalFile>[];

      for (final xfile in details.files) {
        final file = UniversalFile(data: xfile, type: UniversalFileType.file);
        final mimeType = FileUploader.getMimeType(file);
        final topLevelType = mimeType.split('/').first;
        final fileType = switch (topLevelType) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        };
        droppedFiles.add(UniversalFile(data: xfile, type: fileType));
      }

      if (droppedFiles.isNotEmpty) {
        onAttachmentsChanged([...attachments, ...droppedFiles]);
      }
    }

    final settings = ref.watch(appSettingsProvider);

    inputFocusNode.onKeyEvent = (node, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;

      final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
      final isModifierPressed =
          HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed;

      if (isPaste && isModifierPressed) {
        handlePaste();
        return KeyEventResult.handled;
      }

      final enterToSend = settings.enterToSend;
      final isEnter = event.logicalKey == LogicalKeyboardKey.enter;

      if (isEnter) {
        if (isModifierPressed) {
          insertNewLine();
          return KeyEventResult.handled;
        } else if (enterToSend) {
          send();
          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.ignored;
    };

    final double leftMargin = isWideScreen(context) ? 8 : 16;
    final double rightMargin = isWideScreen(context) ? leftMargin : 16;
    const double bottomMargin = 16;
    final inputBorderRadius = BorderRadius.circular(32);

    final userInfo = ref.watch(userInfoProvider);

    List<SnChatMember> getValidMembers(List<SnChatMember> members) {
      return members
          .where((member) => member.accountId != userInfo.value?.id)
          .toList();
    }

    final roomEncryptKey = chatRoom.encryptionMode == 3
        ? deriveE2eeFileEncryptKey(chatRoom.id)
        : null;
    final validMembers = getValidMembers(chatRoom.members ?? const []);

    return DropTarget(
      onDragEntered: (_) => isDraggingOver.value = true,
      onDragExited: (_) => isDraggingOver.value = false,
      onDragDone: (details) async {
        isDraggingOver.value = false;
        await handleDroppedFiles(details);
      },
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: AnimatedContainer(
              decoration: BoxDecoration(
                boxShadow: [
                  if (isMessageListScrolling)
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, -4),
                    ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                ),
                color: isMessageListScrolling
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Colors.transparent,
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 16,
              left: leftMargin,
              right: rightMargin,
              bottom: bottomMargin,
            ),
            child: Material(
              elevation: 2,
              color: isDraggingOver.value
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.8)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: inputBorderRadius,
                side: isDraggingOver.value
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      )
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  children: [
                    _DirectMessageStatusBanner(
                      chatRoom: chatRoom,
                      validMembers: validMembers,
                    ),
                    if (hasActiveTimeout)
                      _ChatTimeoutBanner(timeoutUntil: timeoutUntil),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      switchInCurve: Curves.fastEaseInToSlowEaseOut,
                      switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, -0.3),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child: chatSubscribe.isNotEmpty
                          ? Container(
                              key: const ValueKey('typing-indicator'),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  const _TypingIndicatorDots().padding(
                                    horizontal: 8,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      'typingHint'.plural(
                                        chatSubscribe.length,
                                        args: [
                                          chatSubscribe
                                              .map(
                                                (x) =>
                                                    (x.nick?.isNotEmpty == true)
                                                    ? x.nick
                                                    : x.account.nick,
                                              )
                                              .join(', '),
                                        ],
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('typing-indicator-none'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child: attachments.isNotEmpty && !isExpanded.value
                          ? SizedBox(
                              key: ValueKey(
                                'attachments-${attachments.length}',
                              ),
                              height: 180,
                              child: _AttachmentPreviewStrip(
                                attachments: attachments,
                                onUploadAttachment: onUploadAttachment,
                                onDeleteAttachment: onDeleteAttachment,
                                onMoveAttachment: onMoveAttachment,
                                onAttachmentsChanged: onAttachmentsChanged,
                                attachmentProgress: attachmentProgress,
                                roomEncryptKey: roomEncryptKey,
                              ),
                            ).padding(vertical: 12)
                          : const SizedBox.shrink(
                              key: ValueKey('no-attachments'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.25),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child: selectedPoll != null
                          ? Container(
                              key: const ValueKey('selected-poll'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.how_to_vote,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      selectedPoll!.title ?? 'Poll',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => onPollSelected(null),
                                      tooltip: 'clear'.tr(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('no-selected-poll'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.25),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child: selectedFund != null
                          ? Container(
                              key: const ValueKey('selected-fund'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.currency_exchange,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${selectedFund!.totalAmount.toStringAsFixed(2)} ${selectedFund!.currency}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (selectedFund!.message != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              selectedFund!.message!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontSize: 10,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => onFundSelected(null),
                                      tooltip: 'clear'.tr(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('no-selected-fund'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child:
                          selectedLocationName != null ||
                              selectedLocationAddress != null ||
                              selectedLocationWkt != null
                          ? Container(
                              key: const ValueKey('selected-location'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.location_on,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (selectedLocationName != null)
                                          Text(
                                            selectedLocationName!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (selectedLocationAddress != null)
                                          Text(
                                            selectedLocationAddress!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () =>
                                          onLocationSelected?.call(),
                                      tooltip: 'clear'.tr(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('no-selected-location'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child: selectedMeetId != null
                          ? Container(
                              key: const ValueKey('selected-meet'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.groups,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      'meetLinked'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () =>
                                          onMeetSelected?.call(null),
                                      tooltip: 'clear'.tr(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('no-selected-meet'),
                            ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child:
                          (messageReplyingTo != null ||
                              messageForwardingTo != null ||
                              messageEditingTo != null)
                          ? Container(
                              key: ValueKey(
                                messageReplyingTo?.id ??
                                    messageForwardingTo?.id ??
                                    messageEditingTo?.id ??
                                    'action',
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        messageReplyingTo != null
                                            ? Symbols.reply
                                            : messageForwardingTo != null
                                            ? Symbols.forward
                                            : Symbols.edit,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const Gap(8),
                                      Expanded(
                                        child: Text(
                                          messageReplyingTo != null
                                              ? 'chatReplyingTo'.tr(
                                                  args: [
                                                    messageReplyingTo
                                                            ?.sender
                                                            .account
                                                            .nick ??
                                                        'unknown'.tr(),
                                                  ],
                                                )
                                              : messageForwardingTo != null
                                              ? 'chatForwarding'.tr()
                                              : 'chatEditing'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          onPressed: onClear,
                                          tooltip: 'clear'.tr(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (messageReplyingTo != null ||
                                      messageForwardingTo != null ||
                                      messageEditingTo != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 6,
                                        left: 26,
                                      ),
                                      child: Text(
                                        (() {
                                          final actionMessage =
                                              messageReplyingTo ??
                                              messageForwardingTo ??
                                              messageEditingTo;
                                          if (actionMessage == null) {
                                            return 'chatNoContent'.tr();
                                          }
                                          final resolved =
                                              resolveE2eeDisplayContentForMessage(
                                                actionMessage,
                                              );
                                          if (resolved.content?.isNotEmpty ==
                                              true) {
                                            return resolved.content!;
                                          }
                                          if (resolved.decryptFailed) {
                                            return '[Unable to decrypt this message]';
                                          }
                                          if (resolved.emptyAfterDecrypt) {
                                            return '[Encrypted message has no text content]';
                                          }
                                          return 'chatNoContent'.tr();
                                        })(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no-action')),
                    ),
                    Row(
                      crossAxisAlignment: isVoiceMode.value
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: isVoiceMode.value
                                  ? 'Leave voice mode'
                                  : (isExpanded.value
                                        ? 'collapse'.tr()
                                        : 'more'.tr()),
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: isVoiceMode.value
                                    ? const Icon(
                                        Symbols.keyboard_return,
                                        key: ValueKey('voice-leave'),
                                      )
                                    : isExpanded.value
                                    ? const Icon(
                                        Symbols.close,
                                        key: ValueKey('close'),
                                      )
                                    : const Icon(
                                        Symbols.add,
                                        key: ValueKey('add'),
                                      ),
                              ),
                              onPressed: canCompose
                                  ? () {
                                      if (isVoiceMode.value) {
                                        leaveVoiceMode();
                                        return;
                                      }
                                      isExpanded.value = !isExpanded.value;
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        Expanded(
                          child: isVoiceMode.value
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onLongPressStart: (details) async {
                                    recordingOrigin.value =
                                        details.globalPosition;
                                    await startVoiceRecording();
                                  },
                                  onLongPressMoveUpdate: (details) {
                                    final origin = recordingOrigin.value;
                                    if (origin == null ||
                                        !isRecordingVoice.value) {
                                      return;
                                    }
                                    final dy =
                                        details.globalPosition.dy - origin.dy;
                                    isVoiceCancelArmed.value = dy < -56;
                                  },
                                  onLongPressEnd: (_) async {
                                    await finishVoiceRecording(
                                      shouldCancel: isVoiceCancelArmed.value,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    height: isRecordingVoice.value ? 72 : 44,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: isRecordingVoice.value
                                          ? (isVoiceCancelArmed.value
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.error
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary)
                                          : Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isRecordingVoice.value
                                                ? (isVoiceCancelArmed.value
                                                      ? 'Release to cancel • ${recordingDuration.value.inSeconds}s'
                                                      : 'Recording ${recordingDuration.value.inSeconds}s • swipe up to cancel')
                                                : 'Hold to record voice • max 300s',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: isRecordingVoice.value
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.onPrimary
                                                      : null,
                                                ),
                                          ),
                                          if (isRecordingVoice.value) ...[
                                            const Gap(4),
                                            SizedBox(
                                              height: 16,
                                              child: AnimatedWaveList(
                                                stream: amplitudeStream.stream,
                                                barBuilder: (animation, amplitude) {
                                                  final baseColor = Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary;
                                                  return SizeTransition(
                                                    sizeFactor: animation,
                                                    child: Container(
                                                      width: 3,
                                                      height:
                                                          (160 /
                                                              amplitude.current
                                                                  .abs()
                                                                  .clamp(
                                                                    1,
                                                                    160,
                                                                  )) *
                                                          1.6,
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: baseColor
                                                            .withOpacity(0.9),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : TypeAheadField<AutocompleteSuggestion>(
                                  controller: messageController,
                                  focusNode: inputFocusNode,
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      focusNode: focusNode,
                                      controller: controller,
                                      enabled: canCompose,
                                      readOnly: !canCompose,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintMaxLines: 1,
                                        hintText:
                                            (chatRoom.type == 1 &&
                                                chatRoom.name == null)
                                            ? 'chatDirectMessageHint'.tr(
                                                args: [
                                                  getValidMembers(
                                                        chatRoom.members!,
                                                      )
                                                      .map(
                                                        (e) => e.account.nick,
                                                      )
                                                      .join(', '),
                                                ],
                                              )
                                            : 'chatMessageHint'.tr(
                                                args: [chatRoom.name!],
                                              ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                        counterText:
                                            messageController.text.length > 1024
                                            ? '${messageController.text.length}/4096'
                                            : null,
                                      ),
                                      maxLines: 5,
                                      minLines: 1,
                                      onTapOutside: (_) => FocusManager
                                          .instance
                                          .primaryFocus
                                          ?.unfocus(),
                                      textInputAction: settings.enterToSend
                                          ? TextInputAction.send
                                          : null,
                                      onEditingComplete: () {
                                        if (settings.enterToSend &&
                                            canCompose) {
                                          inputFocusNode.requestFocus();
                                        }
                                      },
                                      onSubmitted: settings.enterToSend
                                          ? (_) => send()
                                          : null,
                                    );
                                  },
                                  suggestionsCallback: (pattern) async {
                                    // Only trigger on @ or :
                                    final atIndex = pattern.lastIndexOf('@');
                                    final colonIndex = pattern.lastIndexOf(':');
                                    final triggerIndex = atIndex > colonIndex
                                        ? atIndex
                                        : colonIndex;
                                    if (triggerIndex == -1) return [];
                                    final chopped = pattern.substring(
                                      triggerIndex,
                                    );
                                    if (chopped.contains(' ')) return [];
                                    final service = ref.read(
                                      autocompleteServiceProvider,
                                    );
                                    try {
                                      return await service.getSuggestions(
                                        chatRoom.id,
                                        chopped,
                                      );
                                    } catch (e) {
                                      return [];
                                    }
                                  },
                                  itemBuilder: (context, suggestion) {
                                    String title = 'unknown'.tr();
                                    Widget leading = Icon(Symbols.help);

                                    // Ensure all keys are snake_case before deserialization
                                    final normalizedData =
                                        _convertKeysToSnakeCase(
                                          suggestion.data,
                                        );

                                    switch (suggestion.type) {
                                      case 'user':
                                        final user = SnAccount.fromJson(
                                          normalizedData,
                                        );
                                        title = user.nick;
                                        leading = ProfilePictureWidget(
                                          file: user.profile.picture,
                                          radius: 18,
                                        );
                                        break;
                                      case 'chatroom':
                                        final chatRoom = SnChatRoom.fromJson(
                                          normalizedData,
                                        );
                                        title = chatRoom.name ?? 'Chat Room';
                                        leading = ProfilePictureWidget(
                                          file: chatRoom.picture,
                                          radius: 18,
                                        );
                                        break;
                                      case 'realm':
                                        final realm = SnRealm.fromJson(
                                          normalizedData,
                                        );
                                        title = realm.name;
                                        leading = ProfilePictureWidget(
                                          file: realm.picture,
                                          radius: 18,
                                        );
                                        break;
                                      case 'publisher':
                                        final publisher = SnPublisher.fromJson(
                                          normalizedData,
                                        );
                                        title = publisher.name;
                                        leading = ProfilePictureWidget(
                                          file: publisher.picture,
                                          radius: 18,
                                        );
                                        break;
                                      case 'sticker':
                                        final sticker = SnSticker.fromJson(
                                          normalizedData,
                                        );
                                        title =
                                            sticker.name?.trim().isNotEmpty ==
                                                true
                                            ? sticker.name!
                                            : sticker.slug;
                                        leading = ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CloudImageWidget(
                                              file: sticker.image,
                                            ),
                                          ),
                                        );
                                        break;
                                      default:
                                    }
                                    return ListTile(
                                      leading: leading,
                                      title: Text(title),
                                      subtitle: Text(suggestion.keyword),
                                      dense: true,
                                    );
                                  },
                                  onSelected: (suggestion) {
                                    final text = messageController.text;
                                    final atIndex = text.lastIndexOf('@');
                                    final colonIndex = text.lastIndexOf(':');
                                    final triggerIndex = atIndex > colonIndex
                                        ? atIndex
                                        : colonIndex;
                                    if (triggerIndex == -1) return;
                                    final newText = text.replaceRange(
                                      triggerIndex,
                                      text.length,
                                      suggestion.keyword,
                                    );
                                    messageController.value = TextEditingValue(
                                      text: newText,
                                      selection: TextSelection.collapsed(
                                        offset:
                                            triggerIndex +
                                            suggestion.keyword.length,
                                      ),
                                    );
                                  },
                                  direction: VerticalDirection.up,
                                  hideOnEmpty: true,
                                  hideOnLoading: true,
                                  debounceDuration: const Duration(
                                    milliseconds: 1000,
                                  ),
                                ),
                        ),
                        if (!isVoiceMode.value)
                          IconButton(
                            icon: const Icon(Icons.send),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: canCompose ? send : null,
                          ),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                      child: isExpanded.value
                          ? _ExpandedSection(
                              onSendMessage: send,
                              messageController: messageController,
                              selectedTabIndex: expandedTabIndex.value,
                              onTabChanged: (index) {
                                expandedTabIndex.value = index;
                              },
                              onPickPhoto: () => onPickFile(true),
                              onPickVideo: () => onPickFile(false),
                              onPickAudio: onPickAudio,
                              onPickGeneralFile: onPickGeneralFile,
                              attachments: attachments,
                              onUploadAttachment: onUploadAttachment,
                              onDeleteAttachment: onDeleteAttachment,
                              onMoveAttachment: onMoveAttachment,
                              onAttachmentsChanged: onAttachmentsChanged,
                              attachmentProgress: attachmentProgress,
                              roomEncryptKey: roomEncryptKey,
                              selectedPoll: selectedPoll,
                              onPollSelected: onPollSelected,
                              selectedFund: selectedFund,
                              onFundSelected: onFundSelected,
                              selectedLocationName: selectedLocationName,
                              selectedLocationAddress: selectedLocationAddress,
                              selectedLocationWkt: selectedLocationWkt,
                              selectedMeetId: selectedMeetId,
                              onLocationSelected: onLocationSelected,
                              onMeetSelected: onMeetSelected,
                              isE2eeRoom: roomEncryptKey != null,
                              onEnableVoiceMode: () {
                                isVoiceMode.value = true;
                                isExpanded.value = false;
                                onPollSelected(null);
                                onFundSelected(null);
                              },
                            )
                          : const SizedBox.shrink(key: ValueKey('collapsed')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
