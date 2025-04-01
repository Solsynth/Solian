import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/attachment/attachment_zoom.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:uuid/uuid.dart';

class AttachmentList extends StatefulWidget {
  final List<SnAttachment?> data;
  final bool bordered;
  final bool gridded;
  final bool columned;
  final BoxFit fit;
  final double? maxHeight;
  final double? minWidth;
  final double? maxWidth;
  final EdgeInsets? padding;
  final FilterQuality? filterQuality;

  const AttachmentList({
    super.key,
    required this.data,
    this.bordered = false,
    this.gridded = false,
    this.columned = false,
    this.fit = BoxFit.cover,
    this.maxHeight,
    this.minWidth,
    this.maxWidth,
    this.padding,
    this.filterQuality,
  });

  static const BorderRadius kDefaultRadius =
      BorderRadius.all(Radius.circular(8));

  @override
  State<AttachmentList> createState() => _AttachmentListState();
}

class _AttachmentListState extends State<AttachmentList> {
  late final List<String> heroTags =
      List.generate(widget.data.length, (_) => const Uuid().v4());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layoutConstraints) {
        final borderSide = widget.bordered
            ? BorderSide(width: 1, color: Theme.of(context).dividerColor)
            : BorderSide.none;
        final backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
        final constraints = BoxConstraints(
          minWidth: widget.minWidth ?? 80,
          maxHeight: widget.maxHeight ?? MediaQuery.of(context).size.height,
        );

        if (widget.data.isEmpty) return const SizedBox.shrink();
        if (widget.data.length == 1) {
          final singleAspectRatio = widget.data[0]?.data['ratio']?.toDouble() ??
              switch (widget.data[0]?.mimetype.split('/').firstOrNull) {
                'audio' => 16 / 9,
                'video' => 16 / 9,
                _ => 1,
              }
                  .toDouble();

          return Container(
            padding: widget.padding ?? EdgeInsets.zero,
            constraints: constraints,
            child: AspectRatio(
              aspectRatio: singleAspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.fromBorderSide(borderSide),
                  borderRadius: AttachmentList.kDefaultRadius,
                ),
                child: ClipRRect(
                  borderRadius: AttachmentList.kDefaultRadius,
                  child: AttachmentItem(
                    data: widget.data[0],
                    heroTag: heroTags[0],
                    fit: widget.fit,
                    filterQuality: widget.filterQuality,
                    onZoom: () {
                      context.pushTransparentRoute(
                        AttachmentZoomView(
                          data: widget.data.where((ele) => ele != null).cast(),
                          initialIndex: 0,
                          heroTags: heroTags,
                        ),
                        backgroundColor: Colors.black.withOpacity(0.7),
                        rootNavigator: true,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }

        final fullOfImage = widget.data
                .where((ele) => ele?.mediaType == SnMediaType.image)
                .length ==
            widget.data.length;

        if (widget.gridded && fullOfImage) {
          return Container(
            margin: widget.padding ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(top: borderSide, bottom: borderSide),
              borderRadius: AttachmentList.kDefaultRadius,
            ),
            child: ClipRRect(
              borderRadius: AttachmentList.kDefaultRadius,
              child: StaggeredGrid.count(
                crossAxisCount: math.min(widget.data.length, 2),
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                children: widget.data
                    .mapIndexed(
                      (idx, ele) => Container(
                        constraints: constraints,
                        child: AttachmentItem(
                          data: ele,
                          heroTag: heroTags[idx],
                          fit: BoxFit.cover,
                          filterQuality: widget.filterQuality,
                          onZoom: () {
                            context.pushTransparentRoute(
                              AttachmentZoomView(
                                data: widget.data
                                    .where((ele) => ele != null)
                                    .cast(),
                                initialIndex: idx,
                                heroTags: heroTags,
                              ),
                              backgroundColor: Colors.black.withOpacity(0.7),
                              rootNavigator: true,
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }

        if ((!fullOfImage && widget.gridded) || widget.columned) {
          return Container(
            margin: widget.padding ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(top: borderSide, bottom: borderSide),
              borderRadius: AttachmentList.kDefaultRadius,
            ),
            child: ClipRRect(
              borderRadius: AttachmentList.kDefaultRadius,
              child: Column(
                children: widget.data
                    .mapIndexed(
                      (idx, ele) => AspectRatio(
                        aspectRatio: ele?.data['ratio']?.toDouble() ?? 1,
                        child: Container(
                          constraints: constraints,
                          child: AttachmentItem(
                            data: ele,
                            heroTag: heroTags[idx],
                            fit: BoxFit.cover,
                            filterQuality: widget.filterQuality,
                            onZoom: () {
                              context.pushTransparentRoute(
                                AttachmentZoomView(
                                  data: widget.data
                                      .where((ele) =>
                                          ele != null &&
                                          ele.mediaType == SnMediaType.image)
                                      .cast(),
                                  initialIndex: idx,
                                  heroTags: heroTags,
                                ),
                                backgroundColor: Colors.black.withOpacity(0.7),
                                rootNavigator: true,
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    .expand((ele) => [ele, const Divider(height: 1)])
                    .toList()
                  ..removeLast(),
              ),
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: widget.data[0]?.data['ratio']?.toDouble() ?? 1,
            child: ScrollConfiguration(
              behavior: AttachmentListScrollBehavior(),
              child: ListView.separated(
                padding: widget.padding,
                shrinkWrap: true,
                itemCount: widget.data.length,
                itemBuilder: (context, idx) {
                  return Container(
                    constraints:
                        constraints.copyWith(maxWidth: widget.maxWidth),
                    child: AspectRatio(
                      aspectRatio:
                          (widget.data[idx]?.data['ratio'] ?? 1).toDouble(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: AttachmentList.kDefaultRadius,
                            ),
                            child: ClipRRect(
                              borderRadius: AttachmentList.kDefaultRadius,
                              child: AttachmentItem(
                                data: widget.data[idx],
                                heroTag: heroTags[idx],
                                filterQuality: widget.filterQuality,
                                onZoom: () {
                                  context.pushTransparentRoute(
                                    AttachmentZoomView(
                                      data: widget.data
                                          .where((ele) =>
                                              ele != null &&
                                              ele.mediaType ==
                                                  SnMediaType.image)
                                          .cast(),
                                      initialIndex: idx,
                                      heroTags: heroTags,
                                    ),
                                    backgroundColor:
                                        Colors.black.withOpacity(0.7),
                                    rootNavigator: true,
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Chip(
                              label: Text('${idx + 1}/${widget.data.length}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Gap(8),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AttachmentListScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}
