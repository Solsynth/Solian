import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/talker.dart';
import 'package:island/core/services/analytics_service.dart';

class UserInfoNotifier extends AsyncNotifier<SnAccount?> {
  @override
  Future<SnAccount?> build() async {
    final token = ref.watch(tokenProvider);
    if (token == null) {
      talker.info('[UserInfo] No token found, not going to fetch...');
      return null;
    }
    return _fetchUser();
  }

  Future<SnAccount?> _fetchUser() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/pass/accounts/me');
      final user = SnAccount.fromJson(response.data);

      AnalyticsService().setUserId(user.id);
      return user;
    } catch (error, stackTrace) {
      if (error is DioException) {
        if (error.response?.statusCode == 503) return null;
        showOverlayDialog<bool>(
          builder: (context, close) => AlertDialog(
            title: Text('failedToLoadUserInfo'.tr()),
            content: Text(
              [
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
            ),
            actions: [
              TextButton(
                onPressed: () => close(false),
                child: Text('okay'.tr()),
              ),
              TextButton(
                onPressed: () => close(true),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ).then((value) {
          if (value == true) {
            ref.invalidateSelf();
          }
        });
      }
      talker.error(
        "[UserInfo] Failed to fetch user info...",
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<void> fetchUser() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> logOut() async {
    state = const AsyncValue.data(null);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kTokenPairStoreKey);
    ref.invalidate(tokenProvider);
    AnalyticsService().setUserId(null);
    AnalyticsService().logLogout();
  }
}

final userInfoProvider = AsyncNotifierProvider<UserInfoNotifier, SnAccount?>(
  UserInfoNotifier.new,
);
