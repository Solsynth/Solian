import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension AppPromptExtension on BuildContext {
  void showSnackbar(String content, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(content),
      action: action,
    ));
  }

  void clearSnackbar() {
    ScaffoldMessenger.of(this).clearSnackBars();
  }

  Future<void> showModalDialog(String title, desc) {
    return showDialog<void>(
      useRootNavigator: true,
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('dialogDismiss').tr(),
          )
        ],
      ),
    );
  }

  Future<void> showInfoDialog(String title, body) {
    return showDialog<void>(
      useRootNavigator: true,
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('dialogDismiss').tr(),
          )
        ],
      ),
    );
  }

  Future<bool> showConfirmDialog(String title, body) async {
    return await showDialog<bool>(
          useRootNavigator: true,
          context: this,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('dialogCancel').tr(),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('dialogConfirm').tr(),
              )
            ],
          ),
        ) ??
        false;
  }

  Future<void> showErrorDialog(dynamic exception) {
    Widget content = Text(exception.toString().capitalize());
    if (exception is DioException) {
      String preview;
      switch (exception.response?.statusCode) {
        case 400:
          preview = 'errorRequestBad'.tr();
          break;
        case 401:
          preview = 'errorRequestUnauthorized'.tr();
          break;
        case 403:
          preview = 'errorRequestForbidden'.tr();
          break;
        case 404:
          preview = 'errorRequestNotFound'.tr();
          break;
        case null:
          preview = 'errorRequestConnection'.tr();
          break;
        default:
          preview = 'errorRequestUnknown'.tr();
          break;
      }

      if (exception.response != null) {
        content = Text(
          '$preview\n\n${exception.requestOptions.uri.path}\n(${exception.response?.statusCode}) ${exception.response?.data}',
        );
      } else {
        content = Text(preview);
      }
    }

    return showDialog<void>(
      useRootNavigator: true,
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text('dialogError').tr(),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            content,
            Text.rich(
              TextSpan(
                text: 'needHelp'.tr(),
                children: [
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'needHelpLaunch'.tr(),
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(ctx).colorScheme.primary,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrlString(
                            'https://kb.solsynth.dev/solar-network');
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('dialogDismiss').tr(),
          )
        ],
      ),
    );
  }
}

extension ByteFormatter on int {
  String formatBytes({int decimals = 2}) {
    if (this == 0) return '0 Bytes';
    const k = 1024;
    final dm = decimals < 0 ? 0 : decimals;
    final sizes = [
      'Bytes',
      'KiB',
      'MiB',
      'GiB',
      'TiB',
      'PiB',
      'EiB',
      'ZiB',
      'YiB'
    ];
    final i = (math.log(this) / math.log(k)).floor().toInt();
    return '${(this / math.pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}';
  }
}

extension StringFormatter on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String capitalizeEachWord() {
    if (isEmpty) {
      return this;
    }
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
