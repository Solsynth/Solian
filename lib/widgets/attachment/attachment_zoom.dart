import 'dart:io';
import 'dart:math' show max;

import 'package:dio/dio.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show extension;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

class AttachmentZoomView extends StatefulWidget {
  final Iterable<SnAttachment> data;
  final int? initialIndex;
  final List<String?>? heroTags;

  const AttachmentZoomView({
    super.key,
    required this.data,
    this.initialIndex,
    this.heroTags,
  });

  @override
  State<AttachmentZoomView> createState() => _AttachmentZoomViewState();
}

class _AttachmentZoomViewState extends State<AttachmentZoomView> {
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex ?? 0);

  bool _showOverlay = true;
  bool _dismissable = true;

  void _updatePage() {
    setState(() {
      if (_isCompletedDownload) {
        setState(() => _isCompletedDownload = false);
      }
    });
  }

  bool _isDownloading = false;
  bool _isCompletedDownload = false;
  double? _progressOfDownload = 0;

  Future<void> _saveToAlbum(int idx) async {
    final sn = context.read<SnNetworkProvider>();
    final item = widget.data.elementAt(idx);
    final url = sn.getAttachmentUrl(item.rid);

    if (kIsWeb || Platform.isLinux) {
      await launchUrlString(url);
      return;
    }

    setState(() => _isDownloading = true);

    var extName = extension(item.name);
    if (extName.isEmpty) extName = '.png';
    final imagePath = '${Directory.systemTemp.path}/${item.uuid}$extName';
    await Dio().download(
      url,
      imagePath,
      onReceiveProgress: (count, total) {
        setState(() => _progressOfDownload = count / total);
      },
    );

    bool isSuccess = false;
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (!await Gal.hasAccess(toAlbum: true)) {
          if (!await Gal.requestAccess(toAlbum: true)) return;
        }
        await Gal.putImage(imagePath, album: 'Solar Network');
      } else {
        await FileSaver.instance.saveFile(
          name: item.name,
          file: File(imagePath),
        );
      }
      setState(() {
        isSuccess = true;
        _isDownloading = false;
        _isCompletedDownload = isSuccess;
      });
    } catch (e) {
      if (!mounted) return;
      context.showErrorDialog(e);
    }

    if (!mounted) return;
    context.showSnackbar(
      (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
          ? 'attachmentSaved'.tr()
          : 'attachmentSavedDesktop'.tr(),
      action: (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
          ? SnackBarAction(
              label: 'openInAlbum'.tr(),
              onPressed: () async => Gal.open(),
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updatePage);
    Future.delayed(const Duration(milliseconds: 100), _updatePage);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    _pageController.dispose();
    super.dispose();
  }

  Color get _unFocusColor =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.75);

  bool _showDetail = false;

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();
    final uuid = Uuid();

    final metaTextStyle = GoogleFonts.roboto(
      fontSize: 12,
      color: _unFocusColor,
      height: 1,
    );

    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      direction: _dismissable
          ? DismissiblePageDismissDirection.multi
          : DismissiblePageDismissDirection.none,
      backgroundColor: Colors.transparent,
      isFullScreen: true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Builder(builder: (context) {
                if (widget.data.length == 1) {
                  final heroTag = widget.heroTags?.first ?? uuid.v4();
                  return Hero(
                    tag: 'attachment-${widget.data.first.rid}-$heroTag',
                    child: PhotoView(
                      key: Key(
                          'attachment-detail-${widget.data.first.rid}-$heroTag'),
                      backgroundDecoration:
                          BoxDecoration(color: Colors.transparent),
                      scaleStateChangedCallback: (scaleState) {
                        setState(() => _dismissable =
                            scaleState == PhotoViewScaleState.initial);
                      },
                      imageProvider: UniversalImage.provider(
                        sn.getAttachmentUrl(widget.data.first.rid),
                      ),
                    ),
                  );
                }

                return PhotoViewGallery.builder(
                  pageController: _pageController,
                  enableRotation: true,
                  scaleStateChangedCallback: (scaleState) {
                    setState(() => _dismissable =
                        scaleState == PhotoViewScaleState.initial);
                  },
                  builder: (context, idx) {
                    final heroTag =
                        widget.heroTags?.elementAt(idx) ?? uuid.v4();
                    return PhotoViewGalleryPageOptions(
                      imageProvider: UniversalImage.provider(
                        sn.getAttachmentUrl(widget.data.elementAt(idx).rid),
                      ),
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: 'attachment-${widget.data.first.rid}-$heroTag',
                      ),
                    );
                  },
                  itemCount: widget.data.length,
                  loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                (event.expectedTotalBytes ?? 1),
                      ),
                    ),
                  ),
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                );
              }),
              Positioned(
                top: max(MediaQuery.of(context).padding.top, 8),
                left: 14,
                child: IgnorePointer(
                  ignoring: !_showOverlay,
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surface.withOpacity(0.5),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ).opacity(_showOverlay ? 1 : 0, animate: true).animate(
                      const Duration(milliseconds: 300), Curves.easeInOut),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .opacity(_showOverlay ? 1 : 0, animate: true)
                  .animate(const Duration(milliseconds: 300), Curves.easeInOut),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
                child: Material(
                  color: Colors.transparent,
                  child: Builder(builder: (context) {
                    final ud = context.read<UserDirectoryProvider>();
                    final item = widget.data.elementAt(
                      widget.data.length > 1
                          ? _pageController.page?.round() ?? 0
                          : 0,
                    );
                    final account = ud.getFromCache(item.accountId);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.accountId > 0)
                          Row(
                            children: [
                              IgnorePointer(
                                child: AccountImage(
                                  content: account?.avatar,
                                  radius: 19,
                                ),
                              ),
                              const Gap(8),
                              Expanded(
                                child: IgnorePointer(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'attachmentUploadBy'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        account?.nick ?? 'unknown'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.data.length > 1)
                                IgnorePointer(
                                  child: Text(
                                    '${(_pageController.page?.round() ?? 0) + 1}/${widget.data.length}',
                                    style: GoogleFonts.robotoMono(fontSize: 13),
                                  ).padding(right: 8),
                                ),
                              InkWell(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                onTap: _isDownloading
                                    ? null
                                    : () => _saveToAlbum(widget.data.length > 1
                                        ? _pageController.page?.round() ?? 0
                                        : 0),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  child: !_isDownloading
                                      ? !_isCompletedDownload
                                          ? const Icon(Symbols.save_alt)
                                          : const Icon(Symbols.download_done)
                                      : SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            value: _progressOfDownload,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        const Gap(4),
                        IgnorePointer(
                          child: Text(
                            item.alt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Gap(2),
                        IgnorePointer(
                          child: Wrap(
                            spacing: 6,
                            children: [
                              if (item.metadata['exif'] == null)
                                Text(
                                  '#${item.rid}',
                                  style: metaTextStyle,
                                ),
                              if (item.metadata['exif']?['Model'] != null)
                                Text(
                                  'attachmentShotOn'.tr(args: [
                                    item.metadata['exif']?['Model'],
                                  ]),
                                  style: metaTextStyle,
                                ).padding(right: 2),
                              if (item.metadata['exif']?['Megapixels'] !=
                                      null &&
                                  item.metadata['exif']?['Model'] != null)
                                Text(
                                  '${item.metadata['exif']?['Megapixels']}MP',
                                  style: metaTextStyle,
                                )
                              else
                                Text(
                                  item.size.formatBytes(),
                                  style: metaTextStyle,
                                ),
                              if (item.metadata['width'] != null &&
                                  item.metadata['height'] != null)
                                Text(
                                  '${item.metadata['width']}x${item.metadata['height']}',
                                  style: metaTextStyle,
                                ),
                            ],
                          ),
                        ),
                        const Gap(4),
                        InkWell(
                          onTap: () {
                            _showDetail = true;
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => _AttachmentZoomDetailPopup(
                                data: widget.data.elementAt(
                                    widget.data.length > 1
                                        ? _pageController.page?.round() ?? 0
                                        : 0),
                              ),
                            ).then((_) {
                              _showDetail = false;
                            });
                          },
                          child: Text(
                            'viewDetailedAttachment'.tr(),
                            style: metaTextStyle.copyWith(
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    );
                  }),
                ).opacity(_showOverlay ? 1 : 0, animate: true).animate(
                    const Duration(milliseconds: 300), Curves.easeInOut),
              ),
            ],
          ),
        ),
        onTap: () {
          setState(() => _showOverlay = !_showOverlay);
        },
        onVerticalDragUpdate: (details) {
          if (_showDetail) return;
          if (details.delta.dy <= -20) {
            _showDetail = true;
            showModalBottomSheet(
              context: context,
              builder: (context) => _AttachmentZoomDetailPopup(
                data: widget.data.elementAt(widget.data.length > 1
                    ? _pageController.page?.round() ?? 0
                    : 0),
              ),
            ).then((_) {
              _showDetail = false;
            });
          }
        },
      ),
    );
  }
}

class _AttachmentZoomDetailPopup extends StatelessWidget {
  final SnAttachment data;

  const _AttachmentZoomDetailPopup({required this.data});

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();
    final account = ud.getFromCache(data.accountId);

    const tableGap = TableRow(
      children: [
        TableCell(child: SizedBox(height: 16)),
        TableCell(child: SizedBox(height: 16)),
      ],
    );

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Symbols.info, size: 24),
              const Gap(16),
              Text('attachmentDetailInfo')
                  .tr()
                  .textStyle(Theme.of(context).textTheme.titleLarge!),
            ],
          ).padding(horizontal: 20, top: 16, bottom: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child:
                            Text('attachmentUploadBy').tr().padding(right: 16),
                      ),
                      TableCell(
                        child: Row(
                          children: [
                            if (data.accountId > 0)
                              AccountImage(
                                content: account?.avatar,
                                radius: 8,
                              ),
                            const Gap(8),
                            Text(data.accountId > 0
                                ? account?.nick ?? 'unknown'.tr()
                                : 'unknown'.tr()),
                            const Gap(8),
                            Text('#${data.accountId}',
                                    style: GoogleFonts.robotoMono())
                                .opacity(0.75),
                          ],
                        ),
                      ),
                    ],
                  ),
                  tableGap,
                  TableRow(
                    children: [
                      TableCell(child: Text('Mimetype').padding(right: 16)),
                      TableCell(child: Text(data.mimetype)),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(child: Text('Size').padding(right: 16)),
                      TableCell(
                          child: Row(
                        children: [
                          Text(data.size.formatBytes()),
                          const Gap(12),
                          Text('${data.size} Bytes',
                                  style: GoogleFonts.robotoMono())
                              .opacity(0.75),
                        ],
                      )),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(child: Text('Name').padding(right: 16)),
                      TableCell(child: Text(data.name)),
                    ],
                  ),
                  if (data.hash.isNotEmpty)
                    TableRow(
                      children: [
                        TableCell(child: Text('Hash').padding(right: 16)),
                        TableCell(
                            child: Text(data.hash,
                                    style: GoogleFonts.robotoMono(fontSize: 11))
                                .opacity(0.9)),
                      ],
                    ),
                  tableGap,
                  ...(data.metadata['exif']?.keys.map((k) => TableRow(
                            children: [
                              TableCell(child: Text(k).padding(right: 16)),
                              TableCell(
                                  child: Text(
                                      data.metadata['exif'][k].toString())),
                            ],
                          )) ??
                      []),
                ],
              ).padding(
                  horizontal: 20,
                  vertical: 8,
                  bottom: MediaQuery.of(context).padding.bottom),
            ),
          ),
        ],
      ),
    );
  }
}
