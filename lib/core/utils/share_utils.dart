import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/calendar_event_screenshot.dart';
import 'package:island/accounts/widgets/check_in/check_in_result_screenshot.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/posts/widgets/compose/post_item_screenshot.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Shares a post as a screenshot image
Future<void> sharePostAsScreenshot(
  BuildContext context,
  WidgetRef ref,
  SnPost post, {
  PostThreadData? thread,
}) async {
  if (kIsWeb) return;

  final screenshotController = ScreenshotController();

  showLoadingModal(context);
  await screenshotController
      .captureFromLongWidget(
        MediaQuery(
          data: MediaQuery.of(context),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 520,
              child: PostItemScreenshot(
                item: post,
                isFullPost: true,
                thread: thread,
              ),
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
      })
      .whenComplete(() {
        final postTypeStr = post.type == 0
            ? 'regular'
            : post.type == 1
                ? 'article'
                : 'blog';
        AnalyticsService().logPostShared(post.id, 'screenshot', postTypeStr);
      });
}

Future<void> shareCheckInAsScreenshot(
  BuildContext context,
  WidgetRef ref,
  SnCheckInResult result,
) async {
  if (kIsWeb) return;

  final user = result.account ?? ref.read(userInfoProvider).value;
  if (user == null) return;

  final screenshotController = ScreenshotController();

  showLoadingModal(context);
  await screenshotController
      .captureFromLongWidget(
        MediaQuery(
          data: MediaQuery.of(context),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              child: CheckInResultScreenshot(user: user, result: result),
            ),
          ),
        ),
        context: context,
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
        delay: const Duration(milliseconds: 1000),
      )
      .then((Uint8List? image) async {
        if (image == null) return;
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/check-in-image.png',
        ).create();
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
      })
      .whenComplete(() {
        AnalyticsService().logEvent('checkin_shared', {
          'share_method': 'screenshot',
          'level': result.level,
        });
      });
}

Future<void> shareCalendarEventAsScreenshot(
  BuildContext context,
  WidgetRef ref,
  SnUserCalendarEvent event, {
  DateTime? displayStartTime,
  DateTime? displayEndTime,
  int? selectedOccurrenceIndex,
}) async {
  if (kIsWeb) return;

  final screenshotController = ScreenshotController();

  showLoadingModal(context);
  await screenshotController
      .captureFromLongWidget(
        MediaQuery(
          data: MediaQuery.of(context),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              child: CalendarEventScreenshot(
                event: event,
                displayStartTime: displayStartTime,
                displayEndTime: displayEndTime,
                selectedOccurrenceIndex: selectedOccurrenceIndex,
              ),
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
        final imagePath = await File(
          '${directory.path}/calendar-event-image.png',
        ).create();
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
      })
      .whenComplete(() {
        AnalyticsService().logEvent('calendar_event_shared', {
          'share_method': 'screenshot',
        });
      });
}
