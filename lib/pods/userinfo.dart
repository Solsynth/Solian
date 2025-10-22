import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/talker.dart';

class UserInfoNotifier extends StateNotifier<AsyncValue<SnAccount?>> {
  final Ref _ref;

  UserInfoNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> fetchUser() async {
    final token = _ref.watch(tokenProvider);
    if (token == null) {
      talker.info('[UserInfo] No token found, not going to fetch...');
      return;
    }
    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.get('/pass/accounts/me');
      final user = SnAccount.fromJson(response.data);
      state = AsyncValue.data(user);

      if (kIsWeb || !(Platform.isLinux || Platform.isWindows)) {
        FirebaseAnalytics.instance.setUserId(id: user.id);
      }
    } catch (error, stackTrace) {
      if (!kIsWeb) {
        if (error is DioException) {
          FlutterPlatformAlert.showCustomAlert(
            windowTitle: 'failedToLoadUserInfo'.tr(),
            text: [
              (error.response?.statusCode == 401
                      ? 'failedToLoadUserInfoUnauthorized'
                      : 'failedToLoadUserInfoNetwork')
                  .tr()
                  .trim(),
              '',
              '${error.response?.statusCode ?? 'Network Error'}',
              if (error.response?.headers != null) error.response?.headers,
              if (error.response?.data != null)
                jsonEncode(error.response?.data),
            ].join('\n'),
            iconStyle: IconStyle.error,
            neutralButtonTitle: 'retry'.tr(),
            negativeButtonTitle: 'okay'.tr(),
          ).then((value) {
            if (value == CustomButton.neutralButton) {
              fetchUser();
            }
          });
        }
        FlutterPlatformAlert.showCustomAlert(
          windowTitle: 'failedToLoadUserInfo'.tr(),
          text:
              [
                'failedToLoadUserInfoNetwork'.tr(),
                error.toString(),
              ].join('\n\n').trim(),
          iconStyle: IconStyle.error,
          neutralButtonTitle: 'retry'.tr(),
          negativeButtonTitle: 'okay'.tr(),
        ).then((value) {
          if (value == CustomButton.neutralButton) {
            fetchUser();
          }
        });
      }
      talker.error(
        "[UserInfo] Failed to fetch user info...",
        error,
        stackTrace,
      );
      state = AsyncValue.data(null);
    }
  }

  Future<void> logOut() async {
    state = const AsyncValue.data(null);
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove(kTokenPairStoreKey);
    _ref.invalidate(tokenProvider);
    if (kIsWeb || !(Platform.isLinux || Platform.isWindows)) {
      FirebaseAnalytics.instance.setUserId(id: null);
    }
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, AsyncValue<SnAccount?>>(
      (ref) => UserInfoNotifier(ref),
    );
