import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

String _parseRemoteError(DioException err) {
  if (err.response?.data is String) return err.response?.data;
  if (err.response?.data?['errors'] != null) {
    final errors = err.response?.data['errors'] as Map<String, dynamic>;
    return errors.values
        .map(
          (ele) =>
              (ele as List<dynamic>).map((ele) => ele.toString()).join('\n'),
        )
        .join('\n');
  }
  return jsonEncode(err.response?.data);
}

void showErrorAlert(dynamic err) async {
  final text = switch (err) {
    String _ => err,
    DioException _ => _parseRemoteError(err),
    Exception _ => err.toString(),
    _ => err.toString(),
  };
  FlutterPlatformAlert.showAlert(
    windowTitle: 'somethingWentWrong'.tr(),
    text: text,
    alertStyle: AlertButtonStyle.ok,
    iconStyle: IconStyle.error,
  );
}

void showInfoAlert(String message, String title) async {
  FlutterPlatformAlert.showAlert(
    windowTitle: title,
    text: message,
    alertStyle: AlertButtonStyle.ok,
    iconStyle: IconStyle.information,
  );
}

Future<bool> showConfirmAlert(String message, String title) async {
  final result = await FlutterPlatformAlert.showAlert(
    windowTitle: title,
    text: message,
    alertStyle: AlertButtonStyle.okCancel,
    iconStyle: IconStyle.question,
  );
  return result == AlertButton.okButton;
}
