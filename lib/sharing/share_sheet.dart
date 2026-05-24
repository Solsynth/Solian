import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/posts/compose.dart';
import 'package:island/core/link_preview.dart';
import 'package:island/core/network.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum ShareContentType { text, link, file }

class ShareContent {
  final ShareContentType type;
  final String? text;
  final String? link;
  final List<XFile>? files;

  const ShareContent({required this.type, this.text, this.link, this.files});

  ShareContent.text(String this.text)
    : type = ShareContentType.text,
      link = null,
      files = null;

  ShareContent.link(String this.link)
    : type = ShareContentType.link,
      text = null,
      files = null;

  ShareContent.files(List<XFile> this.files)
    : type = ShareContentType.file,
      text = null,
      link = null;

  String get displayText {
    switch (type) {
      case ShareContentType.text:
        return text ?? '';
      case ShareContentType.link:
        return link ?? '';
      case ShareContentType.file:
        return files?.map((f) => f.name).join(', ') ?? '';
    }
  }
}

class ShareSheet extends ConsumerStatefulWidget {
  final ShareContent content;
  final String? title;
  final bool toSystem;
  final VoidCallback? onClose;

  const ShareSheet({
    super.key,
    required this.content,
    this.title,
    this.toSystem = false,
    this.onClose,
  });

  // Convenience constructors
  ShareSheet.text({
    Key? key,
    required String text,
    String? title,
    bool toSystem = false,
    VoidCallback? onClose,
  }) : this(
         key: key,
         content: ShareContent.text(text),
         title: title,
         toSystem: toSystem,
         onClose: onClose,
       );

  ShareSheet.link({
    Key? key,
    required String link,
    String? title,
    bool toSystem = false,
    VoidCallback? onClose,
  }) : this(
         key: key,
         content: ShareContent.link(link),
         title: title,
         toSystem: toSystem,
         onClose: onClose,
       );

  ShareSheet.files({
    Key? key,
    required List<XFile> files,
    String? title,
    bool toSystem = false,
    VoidCallback? onClose,
  }) : this(
         key: key,
         content: ShareContent.files(files),
         title: title,
         toSystem: toSystem,
         onClose: onClose,
       );

  @override
  ConsumerState<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<ShareSheet> {
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  final Map<String, List<double>> _fileUploadProgress = {};

  static const _sectionPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _shareToPost() async {
    setState(() => _isLoading = true);
    try {
      // Convert ShareContent to PostComposeInitialState
      String content = '';
      List<UniversalFile> attachments = [];

      switch (widget.content.type) {
        case ShareContentType.text:
          content = widget.content.text ?? '';
          break;
        case ShareContentType.link:
          content = widget.content.link ?? '';
          break;
        case ShareContentType.file:
          if (widget.content.files != null) {
            // Convert XFiles to UniversalFiles
            for (final file in widget.content.files!) {
              var mimeType = file.mimeType;
              mimeType ??= lookupMimeType(file.path);

              UniversalFileType fileType;
              if (mimeType?.startsWith('image/') == true) {
                fileType = UniversalFileType.image;
              } else if (mimeType?.startsWith('video/') == true) {
                fileType = UniversalFileType.video;
              } else if (mimeType?.startsWith('audio/') == true) {
                fileType = UniversalFileType.audio;
              } else {
                fileType = UniversalFileType.file;
              }

              attachments.add(UniversalFile(data: file, type: fileType));
            }
          }
          break;
      }

      final initialState = PostComposeInitialState(
        title: widget.title,
        content: content,
        attachments: attachments,
      );

      // Show compose sheet
      if (mounted) {
        await PostComposeDialog.show(context, initialState: initialState);
        // Close the share sheet after the compose sheet is dismissed
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      showErrorAlert(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareToSpecificChat(SnChatRoom chatRoom) async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(solarNetworkClientProvider).dio;

      String content = _messageController.text.trim();
      List<String> attachmentIds = [];

      // Handle different content types
      switch (widget.content.type) {
        case ShareContentType.text:
          if (content.isEmpty) {
            content = widget.content.text ?? '';
          } else if (widget.content.text?.isNotEmpty == true) {
            content = '$content\n\n${widget.content.text}';
          }
          break;
        case ShareContentType.link:
          if (content.isEmpty) {
            content = widget.content.link ?? '';
          } else if (widget.content.link?.isNotEmpty == true) {
            content = '$content\n\n${widget.content.link}';
          }
          break;
        case ShareContentType.file:
          // Upload files to cloud storage
          if (widget.content.files?.isNotEmpty == true) {
            final universalFiles = widget.content.files!.map((file) {
              UniversalFileType fileType;
              if (file.mimeType?.startsWith('image/') == true) {
                fileType = UniversalFileType.image;
              } else if (file.mimeType?.startsWith('video/') == true) {
                fileType = UniversalFileType.video;
              } else if (file.mimeType?.startsWith('audio/') == true) {
                fileType = UniversalFileType.audio;
              } else {
                fileType = UniversalFileType.file;
              }
              return UniversalFile(data: file, type: fileType);
            }).toList();

            // Initialize progress tracking
            final messageId = DateTime.now().millisecondsSinceEpoch.toString();
            _fileUploadProgress[messageId] = List.filled(
              universalFiles.length,
              0.0,
            );

            // Upload each file
            for (var idx = 0; idx < universalFiles.length; idx++) {
              final file = universalFiles[idx];
              final cloudFile = await ref
                  .read(driveFileUploaderProvider)
                  .createCloudFile(
                    fileData: file,
                    usage: 'post',
                    onProgress: (progress, _) {
                      if (mounted) {
                        setState(() {
                          _fileUploadProgress[messageId]?[idx] =
                              progress ?? 0.0;
                        });
                      }
                    },
                  )
                  .future;

              if (cloudFile == null) {
                throw Exception('Failed to upload file: ${file.data.name}');
              }
              attachmentIds.add(cloudFile.id);
            }
          }
          break;
      }

      if (content.isEmpty && attachmentIds.isEmpty) {
        throw Exception('No content to share');
      }

      // Send message to chat room
      await apiClient.post(
        '/messager/chat/${chatRoom.id}/messages',
        data: {'content': content, 'attachments_id': attachmentIds, 'meta': {}},
      );

      if (mounted) {
        // Show success message
        showSnackBar(
          'shareToSpecificChatSuccess'.tr(
            args: [chatRoom.name ?? 'directChat'.tr()],
          ),
        );

        // Show navigation prompt
        final shouldNavigate = await showConfirmAlert(
          'wouldYouLikeToGoToChat'.tr(),
          'shareSuccess'.tr(),
          icon: Symbols.check_circle,
        );

        // Close the share sheet
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Navigate to chat if requested
        if (shouldNavigate == true && mounted) {
          context.router.push(ChatRoomRoute(id: chatRoom.id));
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar('Failed to share to chat: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareToSystem() async {
    if (!widget.toSystem) return;

    final box = context.findRenderObject() as RenderBox?;

    setState(() => _isLoading = true);
    try {
      switch (widget.content.type) {
        case ShareContentType.text:
          if (widget.content.text?.isNotEmpty == true) {
            await Share.share(
              widget.content.text!,
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          }
          break;
        case ShareContentType.link:
          if (widget.content.link?.isNotEmpty == true) {
            await Share.share(
              widget.content.link!,
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          }
          break;
        case ShareContentType.file:
          if (widget.content.files?.isNotEmpty == true) {
            await Share.shareXFiles(
              widget.content.files!,
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          }
          break;
      }
    } catch (e) {
      showErrorAlert(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadFiles() async {
    if (widget.content.files == null || widget.content.files!.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final universalFiles = widget.content.files!.map((file) {
        UniversalFileType fileType;
        if (file.mimeType?.startsWith('image/') == true) {
          fileType = UniversalFileType.image;
        } else if (file.mimeType?.startsWith('video/') == true) {
          fileType = UniversalFileType.video;
        } else if (file.mimeType?.startsWith('audio/') == true) {
          fileType = UniversalFileType.audio;
        } else {
          fileType = UniversalFileType.file;
        }
        return UniversalFile(data: file, type: fileType);
      }).toList();

      // Initialize progress tracking
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      _fileUploadProgress[messageId] = List.filled(universalFiles.length, 0.0);

      List<SnCloudFile> uploadedFiles = [];

      // Upload each file
      for (var idx = 0; idx < universalFiles.length; idx++) {
        final file = universalFiles[idx];
        final cloudFile = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
              fileData: file,
              onProgress: (progress, _) {
                if (mounted) {
                  setState(() {
                    _fileUploadProgress[messageId]?[idx] = progress ?? 0.0;
                  });
                }
              },
            )
            .future;

        if (cloudFile == null) {
          throw Exception('Failed to upload file: ${file.data.name}');
        }
        uploadedFiles.add(cloudFile);
      }

      if (mounted) {
        // Show success message
        showSnackBar('uploadSuccess'.tr());

        // If single file, ask to view details
        if (uploadedFiles.length == 1) {
          final shouldView = await showConfirmAlert(
            'wouldYouLikeToViewFile'.tr(),
            'uploadSuccess'.tr(),
            icon: Symbols.check_circle,
          );

          if (mounted) {
            Navigator.of(context).pop(); // Close share sheet
            if (shouldView == true) {
              context.router.push(FileDetailRoute(id: uploadedFiles.first.id));
            }
          }
        } else {
          // Just close for multiple files
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      String textToCopy = '';
      switch (widget.content.type) {
        case ShareContentType.text:
          textToCopy = widget.content.text ?? '';
          break;
        case ShareContentType.link:
          textToCopy = widget.content.link ?? '';
          break;
        case ShareContentType.file:
          textToCopy =
              widget.content.files?.map((f) => f.name).join('\n') ?? '';
          break;
      }

      await Clipboard.setData(ClipboardData(text: textToCopy));
      if (mounted) showSnackBar('copyToClipboard'.tr());
    } catch (e) {
      showErrorAlert(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SheetScaffold(
      titleText: widget.title ?? 'share'.tr(),
      heightFactor: 0.75,
      child: Column(
        children: [
          // Share options with keyboard avoidance
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content preview
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'contentToShare'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ContentPreview(content: widget.content),
                      ],
                    ),
                  ),
                  // Quick actions row (horizontally scrollable)
                  Padding(
                    padding: _sectionPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'quickActions'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _CompactShareOption(
                                icon: Symbols.post_add,
                                title: 'post'.tr(),
                                onTap: _isLoading ? null : _shareToPost,
                              ),
                              const SizedBox(width: 12),
                              if (widget.content.type ==
                                  ShareContentType.file) ...[
                                _CompactShareOption(
                                  icon: Symbols.cloud_upload,
                                  title: 'upload'.tr(),
                                  onTap: _isLoading ? null : _uploadFiles,
                                ),
                                const SizedBox(width: 12),
                              ],
                              _CompactShareOption(
                                icon: Symbols.content_copy,
                                title: 'copy'.tr(),
                                onTap: _isLoading ? null : _copyToClipboard,
                              ),
                              if (widget.toSystem) ...<Widget>[
                                const SizedBox(width: 12),
                                _CompactShareOption(
                                  icon: Symbols.share,
                                  title: 'share'.tr(),
                                  onTap: _isLoading ? null : _shareToSystem,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chat section
                  Padding(
                    padding: _sectionPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sendToChat'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Additional message input
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'addAdditionalMessage'.tr(),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHigh,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            maxLines: 3,
                            minLines: 1,
                            enabled: !_isLoading,
                          ),
                        ),

                        _ChatRoomsList(
                          onChatSelected: _isLoading
                              ? null
                              : _shareToSpecificChat,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Loading indicator and file upload progress
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  if (_fileUploadProgress.isNotEmpty)
                    ..._fileUploadProgress.entries.map((entry) {
                      final progress = entry.value;
                      final averageProgress = progress.isEmpty
                          ? 0.0
                          : progress.reduce((a, b) => a + b) / progress.length;
                      return Column(
                        children: [
                          Text(
                            'uploadingFiles'.tr(),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: averageProgress),
                          const SizedBox(height: 4),
                          Text(
                            '${(averageProgress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatRoomsList extends ConsumerWidget {
  final Function(SnChatRoom)? onChatSelected;

  const _ChatRoomsList({this.onChatSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = ref.watch(chatRoomJoinedProvider);

    return chatRooms.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'noChatRoomsAvailable'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _ChatRoomOption(
                room: room,
                onTap: onChatSelected != null
                    ? () => onChatSelected!(room)
                    : null,
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      error: (error, stack) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'failedToLoadChats'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatRoomOption extends HookConsumerWidget {
  final SnChatRoom room;
  final VoidCallback? onTap;

  const _ChatRoomOption({required this.room, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userInfo = ref.watch(userInfoProvider);

    final validMembers = (room.members ?? [])
        .where((m) => m.accountId != userInfo.value?.id)
        .toList();

    final isDirect = room.type == 1; // Assuming type 1 is direct chat
    final displayName =
        room.name ??
        (isDirect
            ? validMembers.map((m) => m.account.nick).join(', ')
            : 'unknownChat'.tr());

    return Material(
      color: onTap != null
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerHigh.withOpacity(0.6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Chat room avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: (isDirect && room.picture == null)
                      ? SplitAvatarWidget(
                          files: validMembers
                              .map((e) => e.account.profile.picture)
                              .toList(),
                          radius: 16,
                        )
                      : room.picture == null
                      ? CircleAvatar(
                          radius: 16,
                          child: Text(room.name![0].toUpperCase()),
                        )
                      : ProfilePictureWidget(file: room.picture, radius: 16),
                ),
                const SizedBox(height: 6),
                // Chat room name
                Text(
                  displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onTap != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _CompactShareOption({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: onTap != null
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHigh.withOpacity(0.6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: onTap != null
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onTap != null
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentPreview extends StatelessWidget {
  final ShareContent content;

  const _ContentPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    switch (content.type) {
      case ShareContentType.text:
        return _TextPreview(text: content.text ?? '');
      case ShareContentType.link:
        return _LinkPreview(link: content.link ?? '');
      case ShareContentType.file:
        return _FilePreview(files: content.files ?? []);
    }
  }
}

const double kPreviewMaxHeight = 80;

class _TextPreview extends StatelessWidget {
  final String text;

  const _TextPreview({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: kPreviewMaxHeight),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _LinkPreview extends ConsumerWidget {
  final String link;

  const _LinkPreview({required this.link});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkPreviewAsync = ref.watch(linkPreviewProvider(link));

    return linkPreviewAsync.when(
      loading: () => Container(
        constraints: const BoxConstraints(maxHeight: kPreviewMaxHeight),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading link preview...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => _buildFallbackPreview(context),
      data: (embed) {
        if (embed == null) {
          return _buildFallbackPreview(context);
        }

        return Container(
          constraints: const BoxConstraints(
            maxHeight: 120,
          ), // Increased height for rich preview
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favicon and image
              if (embed.imageUrl != null ||
                  (embed.faviconUrl?.isNotEmpty ?? false))
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: embed.imageUrl != null
                        ? Image.network(
                            embed.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFaviconFallback(
                                context,
                                embed.faviconUrl ?? '',
                              );
                            },
                          )
                        : _buildFaviconFallback(
                            context,
                            embed.faviconUrl ?? '',
                          ),
                  ),
                ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Site name
                    if (embed.siteName?.isNotEmpty ?? false)
                      Text(
                        embed.siteName!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Title
                    if (embed.title != null)
                      Text(
                        embed.title!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Description
                    if (embed.description != null &&
                        embed.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          embed.description!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // URL
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        embed.url,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackPreview(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: kPreviewMaxHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.link,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Link',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Gap(6),
              Text(
                'Link embed was not loaded.',
                style: Theme.of(context).textTheme.labelSmall,
              ).opacity(0.75),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SelectableText(
              link,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaviconFallback(BuildContext context, String faviconUrl) {
    if (faviconUrl.isNotEmpty) {
      return Image.network(
        faviconUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Symbols.link,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          );
        },
      );
    }
    return Icon(
      Symbols.link,
      color: Theme.of(context).colorScheme.primary,
      size: 24,
    );
  }
}

class _FilePreview extends StatelessWidget {
  final List<XFile> files;

  const _FilePreview({required this.files});

  bool _isImageFile(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(ext);
  }

  bool _isVideoFile(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(ext);
  }

  IconData _getFileIcon(String fileName) {
    final ext = path.extension(fileName).toLowerCase();

    if (_isImageFile(fileName)) return Symbols.image;
    if (_isVideoFile(fileName)) return Symbols.video_file;

    switch (ext) {
      case '.pdf':
        return Symbols.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Symbols.description;
      case '.xls':
      case '.xlsx':
        return Symbols.table_chart;
      case '.ppt':
      case '.pptx':
        return Symbols.slideshow;
      case '.zip':
      case '.rar':
      case '.7z':
        return Symbols.folder_zip;
      case '.txt':
        return Symbols.text_snippet;
      default:
        return Symbols.attach_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: kPreviewMaxHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.attach_file,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${files.length} file${files.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final isImage = _isImageFile(file.name);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      if (isImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(file.path),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                child: Icon(
                                  Symbols.broken_image,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            _getFileIcon(file.name),
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            FutureBuilder<int>(
                              future: file.length(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final size = snapshot.data!;
                                  final sizeStr = size < 1024
                                      ? '${size}B'
                                      : size < 1024 * 1024
                                      ? '${(size / 1024).toStringAsFixed(1)}KB'
                                      : '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
                                  return Text(
                                    sizeStr,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper functions to show the share sheet
void showShareSheet({
  required BuildContext context,
  required ShareContent content,
  String? title,
  bool toSystem = false,
  VoidCallback? onClose,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => ShareSheet(
      content: content,
      title: title,
      toSystem: toSystem,
      onClose: onClose,
    ),
  );
}

void showShareSheetText({
  required BuildContext context,
  required String text,
  String? title,
  bool toSystem = false,
  VoidCallback? onClose,
}) {
  showShareSheet(
    context: context,
    content: ShareContent.text(text),
    title: title,
    toSystem: toSystem,
    onClose: onClose,
  );
}

void showShareSheetLink({
  required BuildContext context,
  required String link,
  String? title,
  bool toSystem = false,
  VoidCallback? onClose,
}) {
  showShareSheet(
    context: context,
    content: ShareContent.link(link),
    title: title,
    toSystem: toSystem,
    onClose: onClose,
  );
}

void showShareSheetFiles({
  required BuildContext context,
  required List<XFile> files,
  String? title,
  bool toSystem = false,
  VoidCallback? onClose,
}) {
  showShareSheet(
    context: context,
    content: ShareContent.files(files),
    title: title,
    toSystem: toSystem,
    onClose: onClose,
  );
}
