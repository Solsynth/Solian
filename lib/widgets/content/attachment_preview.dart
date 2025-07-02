import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/file.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class AttachmentPreview extends StatelessWidget {
  final UniversalFile item;
  final double? progress;
  final Function(int)? onMove;
  final Function? onDelete;
  final Function? onInsert;
  final Function? onRequestUpload;
  const AttachmentPreview({
    super.key,
    required this.item,
    this.progress,
    this.onRequestUpload,
    this.onMove,
    this.onDelete,
    this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio:
          (item.isOnCloud ? (item.data.fileMeta?['ratio'] ?? 1) : 1).toDouble(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Builder(
                builder: (context) {
                  if (item.isOnCloud) {
                    return CloudFileWidget(item: item.data);
                  } else if (item.data is XFile) {
                    if (item.type == UniversalFileType.image) {
                      final file = item.data as XFile;
                      if (file.path.isEmpty) {
                        return FutureBuilder<Uint8List>(
                          future: file.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(snapshot.data!);
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      }
                      return kIsWeb
                          ? Image.network(file.path)
                          : Image.file(File(file.path));
                    } else {
                      return Center(
                        child: Text(
                          'Preview is not supported for ${item.type}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  } else if (item is List<int> || item is Uint8List) {
                    if (item.type == UniversalFileType.image) {
                      return Image.memory(item.data);
                    } else {
                      return Center(
                        child: Text(
                          'Preview is not supported for ${item.type}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  }
                  return Placeholder();
                },
              ),
            ),
            if (progress != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (progress != null)
                        Text(
                          '${progress!.toStringAsFixed(2)}%',
                          style: TextStyle(color: Colors.white),
                        )
                      else
                        Text(
                          'uploading'.tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                      Gap(6),
                      Center(
                        child: LinearProgressIndicator(
                          value: progress != null ? progress! / 100.0 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 8,
              top: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onDelete != null)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Symbols.delete,
                              size: 14,
                              color: Colors.white,
                            ).padding(horizontal: 8, vertical: 6),
                            onTap: () {
                              onDelete?.call();
                            },
                          ),
                        if (onDelete != null && onMove != null)
                          SizedBox(
                            height: 26,
                            child: const VerticalDivider(
                              width: 0.3,
                              color: Colors.white,
                              thickness: 0.3,
                            ),
                          ).padding(horizontal: 2),
                        if (onMove != null)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Symbols.keyboard_arrow_up,
                              size: 14,
                              color: Colors.white,
                            ).padding(horizontal: 8, vertical: 6),
                            onTap: () {
                              onMove?.call(-1);
                            },
                          ),
                        if (onMove != null)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Symbols.keyboard_arrow_down,
                              size: 14,
                              color: Colors.white,
                            ).padding(horizontal: 8, vertical: 6),
                            onTap: () {
                              onMove?.call(1);
                            },
                          ),
                        if (onInsert != null)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Symbols.add,
                              size: 14,
                              color: Colors.white,
                            ).padding(horizontal: 8, vertical: 6),
                            onTap: () {
                              onInsert?.call();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onRequestUpload != null)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onRequestUpload?.call(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child:
                          (item.isOnCloud)
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.cloud,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'On-cloud',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.cloud_off,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'On-device',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
