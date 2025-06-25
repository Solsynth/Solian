import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:auto_route/auto_route.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/models/file.dart';
import 'package:island/models/embed.dart';
import 'package:island/pods/network.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:island/models/chat.dart';
import 'package:island/screens/chat/chat.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

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

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
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
            for (final xFile in widget.content.files!) {
              final file = File(xFile.path);
              final mimeType = xFile.mimeType;
              
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
              
              attachments.add(UniversalFile(
                data: file,
                type: fileType,
              ));
            }
          }
          break;
      }
      
      final initialState = PostComposeInitialState(
        title: widget.title,
        content: content,
        attachments: attachments,
      );
      
      // Navigate to compose screen
      if (mounted) {
        context.router.push(PostComposeRoute(initialState: initialState));
        Navigator.of(context).pop(); // Close the share sheet
      }
    } catch (e) {
      showErrorAlert(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareToChat() async {
    setState(() => _isLoading = true);
    try {} catch (e) {
      showErrorAlert(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareToSpecificChat(SnChatRoom chatRoom) async {
    setState(() => _isLoading = true);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'shareToSpecificChatComingSoon'.tr(
              args: [chatRoom.name ?? 'directChat'.tr()],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share to chat: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareToSystem() async {
    if (!widget.toSystem) return;

    setState(() => _isLoading = true);
    try {
      switch (widget.content.type) {
        case ShareContentType.text:
          if (widget.content.text?.isNotEmpty == true) {
            await Share.share(widget.content.text!);
          }
          break;
        case ShareContentType.link:
          if (widget.content.link?.isNotEmpty == true) {
            await Share.share(widget.content.link!);
          }
          break;
        case ShareContentType.file:
          if (widget.content.files?.isNotEmpty == true) {
            await Share.shareXFiles(widget.content.files!);
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
    return SheetScaffold(
      titleText: widget.title ?? 'share'.tr(),
      heightFactor: 0.75,
      child: Column(
        children: [
          // Content preview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'contentToShare'.tr(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _ContentPreview(content: widget.content),
              ],
            ),
          ),

          // Share options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions row (horizontally scrollable)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'quickActions'.tr(),
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sendToChat'.tr(),
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ChatRoomsList(
                          onChatSelected:
                              _isLoading ? null : _shareToSpecificChat,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const CircularProgressIndicator(),
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
    final chatRooms = ref.watch(chatroomsJoinedProvider);

    return chatRooms.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
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
                onTap:
                    onChatSelected != null ? () => onChatSelected!(room) : null,
              );
            },
          ),
        );
      },
      loading:
          () => SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      error:
          (error, stack) => Container(
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

class _ChatRoomOption extends StatelessWidget {
  final SnChatRoom room;
  final VoidCallback? onTap;

  const _ChatRoomOption({required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDirect = room.type == 1; // Assuming type 1 is direct chat
    final displayName =
        room.name ??
        (isDirect && room.members != null
            ? room.members!.map((m) => m.account.nick).join(', ')
            : 'unknownChat'.tr());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              onTap != null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chat room avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  room.picture != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CloudFileWidget(
                          item: room.picture!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Icon(
                        isDirect ? Symbols.person : Symbols.group,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
            ),
            const SizedBox(height: 4),
            // Chat room name
            Text(
              displayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    onTap != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              onTap != null
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  onTap != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    onTap != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ShareOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          icon,
          color:
              onTap != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                onTap != null
                    ? null
                    : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                onTap != null
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
        trailing: onTap != null ? const Icon(Symbols.chevron_right) : null,
        onTap: onTap,
        enabled: onTap != null,
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
      child: SingleChildScrollView(
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _LinkPreview extends HookConsumerWidget {
  final String link;

  const _LinkPreview({required this.link});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkData = useState<SnEmbedLink?>(null);
    final isLoading = useState(false);
    final hasError = useState(false);

    useEffect(() {
      Future<void> fetchLinkData() async {
        if (link.isEmpty) return;
        
        isLoading.value = true;
        hasError.value = false;
        
        try {
          final client = ref.read(apiClientProvider);
          final response = await client.get('/scrap/link', queryParameters: {
            'url': link,
          });
          
          if (response.data != null) {
            linkData.value = SnEmbedLink.fromJson(response.data);
          }
        } catch (e) {
          hasError.value = true;
        } finally {
          isLoading.value = false;
        }
      }
      
      fetchLinkData();
      return null;
    }, [link]);

    if (isLoading.value) {
      return Container(
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
      );
    }

    if (hasError.value || linkData.value == null) {
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
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  link,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final embed = linkData.value!;
    return Container(
      constraints: const BoxConstraints(maxHeight: 120), // Increased height for rich preview
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favicon and image
          if (embed.imageUrl != null || embed.faviconUrl.isNotEmpty)
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: embed.imageUrl != null
                    ? Image.network(
                        embed.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFaviconFallback(context, embed.faviconUrl);
                        },
                      )
                    : _buildFaviconFallback(context, embed.faviconUrl),
              ),
            ),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Site name
                if (embed.siteName.isNotEmpty)
                  Text(
                    embed.siteName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                // Title
                Text(
                  embed.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Description
                if (embed.description != null && embed.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      embed.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
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
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                child: Icon(
                                  Symbols.broken_image,
                                  size: 20,
                                  color:
                                      Theme.of(
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
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            _getFileIcon(file.name),
                            size: 20,
                            color:
                                Theme.of(
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
                                  final sizeStr =
                                      size < 1024
                                          ? '${size}B'
                                          : size < 1024 * 1024
                                          ? '${(size / 1024).toStringAsFixed(1)}KB'
                                          : '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
                                  return Text(
                                    sizeStr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(
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
    builder:
        (context) => ShareSheet(
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
