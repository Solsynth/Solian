import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:island/talker.dart';

String _parseRemoteError(DioException err) {
  String? message;
  if (err.response?.data is String) {
    message = err.response?.data;
  } else if (err.response?.data?['message'] != null) {
    message = <String?>[
      err.response?.data?['message']?.toString(),
      err.response?.data?['detail']?.toString(),
    ].where((e) => e != null).cast<String>().map((e) => e.trim()).join('\n');
  } else if (err.response?.data?['errors'] != null) {
    final errors = err.response?.data['errors'] as Map<String, dynamic>;
    message = errors.values
        .map(
          (ele) =>
              (ele as List<dynamic>).map((ele) => ele.toString()).join('\n'),
        )
        .join('\n');
  }
  if (message == null || message.isEmpty) message = err.response?.statusMessage;
  message ??= err.message;
  return message ?? err.toString();
}

void showErrorAlert(dynamic err) async {
  if (err is Error) {
    talker.error('Something went wrong...', err, err.stackTrace);
  }
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
