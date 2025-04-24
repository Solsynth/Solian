import 'package:flutter_platform_alert/flutter_platform_alert.dart';

void showErrorAlert(dynamic err) async {
  FlutterPlatformAlert.showAlert(
    windowTitle: 'Something went wrong...',
    text: err.toString(),
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
