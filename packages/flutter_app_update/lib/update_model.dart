class UpdateModel {
  ///Apk url
  final String apkUrl;

  ///Download apk name
  final String apkName;

  ///Notification small icon, here the name of the image in the mipmap, eg: ic_launcher.png then set ic_launcher
  final String smallIcon;

  ///iOS download url
  final String iOSUrl;

  ///New version md5 file verification (32-bit), verification for repeated downloads
  final String? apkMD5;

  ///Display progress notification
  final bool showNotification;

  ///Download completed and installation
  final bool jumpInstallPage;

  ///Show "Downloading new version in the background…" toast
  final bool showBgdToast;

  UpdateModel(
    this.apkUrl,
    this.apkName,
    this.smallIcon,
    this.iOSUrl, {
    this.apkMD5,
    this.showNotification = true,
    this.jumpInstallPage = true,
    this.showBgdToast = true,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['apkUrl'] = apkUrl;
    data['apkName'] = apkName;
    data['smallIcon'] = smallIcon;
    data['iOSUrl'] = iOSUrl;
    data['apkMD5'] = apkMD5 ?? '';
    data['showNotification'] = showNotification;
    data['jumpInstallPage'] = jumpInstallPage;
    data['showBgdToast'] = showBgdToast;
    return data;
  }
}
