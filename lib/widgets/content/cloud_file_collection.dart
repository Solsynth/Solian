import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/file.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:styled_widget/styled_widget.dart';

class CloudFileList extends StatelessWidget {
  final List<SnCloudFile> files;
  final double maxHeight;
  const CloudFileList({super.key, required this.files, this.maxHeight = 360});

  double calculateAspectRatio() {
    double total = 0;
    for (var ratio in files.map(
      (e) =>
          e.fileMeta?['ratio'] ??
          ((e.mimeType?.startsWith('image') ?? false) ? 1 : 16 / 9),
    )) {
      total += ratio;
    }
    return total / files.length;
  }

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    if (files.length == 1) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: CloudFileWidget(item: files.first),
          ),
        ),
      ).padding(horizontal: 3);
    }

    final allImages =
        !files.any(
          (e) => e.mimeType == null || !e.mimeType!.startsWith('image'),
        );

    if (allImages) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minWidth: double.infinity,
        ),
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(),
          child: CarouselView(
            itemExtent: MediaQuery.of(context).size.width * 0.85,
            itemSnapping: true,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            children: [for (final item in files) CloudFileWidget(item: item)],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minWidth: double.infinity,
      ),
      child: AspectRatio(
        aspectRatio: calculateAspectRatio(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: files.length,
          padding: EdgeInsets.symmetric(horizontal: 3),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: CloudFileWidget(item: files[index]),
            );
          },
          separatorBuilder: (_, __) => const Gap(8),
        ),
      ),
    );
  }
}
