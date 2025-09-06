import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/post/post_item_screenshot.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// Shares a post as a screenshot image
Future<void> sharePostAsScreenshot(
  BuildContext context,
  WidgetRef ref,
  SnPost post,
) async {
  if (kIsWeb) return;

  final screenshotController = ScreenshotController();

  showLoadingModal(context);
  await screenshotController
      .captureFromWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              ref.watch(sharedPreferencesProvider),
            ),
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 520,
              child: PostItemScreenshot(item: post, isFullPost: true),
            ),
          ),
        ),
        context: context,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        delay: const Duration(seconds: 1),
      )
      .then((Uint8List? image) async {
        if (image == null) return;
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/image.png').create();
        await imagePath.writeAsBytes(image);

        if (!context.mounted) return;
        hideLoadingModal(context);
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles([
          XFile(imagePath.path),
        ], sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
      })
      .catchError((err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      });
}
