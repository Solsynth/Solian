import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_app_update/result_model.dart';
import 'package:flutter_app_update/update_model.dart';

class AzhonAppUpdate {
  static const MethodChannel _channel = MethodChannel('azhon_app_update');
  static const EventChannel _listenerChannel =
      EventChannel('azhon_app_update_listener');
  static StreamSubscription? _listenerStream;

  ///获取应用的versionCode
  static Future<int> get getVersionCode async {
    return await _channel.invokeMethod('getVersionCode');
  }

  ///获取应用的versionName
  static Future<String> get getVersionName async {
    return await _channel.invokeMethod('getVersionName');
  }

  ///更新
  static Future<bool> update(UpdateModel model) async {
    return await _channel.invokeMethod('update', {
      'model': model.toJson(),
    });
  }

  ///安装应用
  static Future<bool> install(String apkPath, {String? authorities}) async {
    return await _channel.invokeMethod('install', {
      'authorities': authorities,
      'path': apkPath,
    });
  }

  ///释放DownloadManager
  static Future<bool> release() async {
    return await _channel.invokeMethod('release');
  }

  ///取消
  static Future<bool> cancel() async {
    return await _channel.invokeMethod('cancel');
  }

  ///删除通知栏消息
  static Future<bool> cancelNotify() async {
    return await _channel.invokeMethod('cancelNotify');
  }

  ///监听
  static void listener(ValueChanged<ResultModel> callback) {
    if (!Platform.isAndroid) return;
    _listenerStream = _listenerChannel.receiveBroadcastStream().listen((data) {
      callback.call(ResultModel.fromJson(jsonDecode(data)));
    });
  }

  static void dispose() {
    _listenerStream?.cancel();
  }
}
