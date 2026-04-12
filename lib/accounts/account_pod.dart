import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:island/e2ee/mls_storage.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _bootstrapRetryTimeouts = <Duration>[
  Duration(milliseconds: 1000),
  Duration(seconds: 2),
  Duration(seconds: 3),
];

class UserInfoNotifier extends AsyncNotifier<SnAccount?> {
  @override
  Future<SnAccount?> build() async {
    final token = ref.watch(tokenProvider);
    if (token == null) {
      Logger.root.info('[UserInfo] No token found, not going to fetch...');
      return null;
    }
    return _fetchUserWithRetry(showErrorDialog: false);
  }

  Future<SnAccount> _requestUser({Duration? timeout}) async {
    final client = ref.read(solarNetworkClientProvider);
    final options = timeout == null
        ? null
        : Options(
            connectTimeout: timeout,
            sendTimeout: timeout,
            receiveTimeout: timeout,
          );
    final user = await client.accounts.getCurrentAccount(options: options);
    AnalyticsService().setUserId(user.id);
    return user;
  }

  void _handleFetchError(
    Object error,
    StackTrace stackTrace, {
    required bool showErrorDialog,
  }) {
    if (error is DioException) {
      if (error.response?.statusCode == 503) return;
      if (showErrorDialog) {
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
    }
    Logger.root.severe(
      "[UserInfo] Failed to fetch user info...",
      error,
      stackTrace,
    );
  }

  Future<SnAccount?> _fetchUserWithRetry({
    required bool showErrorDialog,
    bool throwOnFailure = false,
    List<Duration> retryTimeouts = _bootstrapRetryTimeouts,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var idx = 0; idx < retryTimeouts.length; idx++) {
      final timeout = retryTimeouts[idx];
      try {
        return await _requestUser(timeout: timeout);
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        Logger.root.warning(
          '[UserInfo] Retry ${idx + 1}/${retryTimeouts.length} failed '
          '(timeout: ${timeout.inMilliseconds}ms): $error',
        );
      }
    }

    if (lastError != null && lastStackTrace != null) {
      _handleFetchError(
        lastError,
        lastStackTrace,
        showErrorDialog: showErrorDialog,
      );
      if (throwOnFailure) {
        Error.throwWithStackTrace(lastError, lastStackTrace);
      }
    }
    return null;
  }

  Future<SnAccount?> fetchUserForBootstrap({
    List<Duration> retryTimeouts = _bootstrapRetryTimeouts,
  }) async {
    final user = await _fetchUserWithRetry(
      showErrorDialog: false,
      throwOnFailure: true,
      retryTimeouts: retryTimeouts,
    );
    state = AsyncValue.data(user);
    return user;
  }

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    final user = await _fetchUserWithRetry(showErrorDialog: true);
    state = AsyncValue.data(user);
  }

  Future<void> logOut() async {
    state = const AsyncValue.data(null);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kTokenPairStoreKey);
    ref.invalidate(tokenProvider);
    ref.invalidate(userInfoProvider);
    AnalyticsService().setUserId(null);
    AnalyticsService().logLogout();

    final mlsStorage = MlsStorage();
    await mlsStorage.clearAllForLogout();
    Logger.root.info('MLS storage cleared on logout');
  }
}

final userInfoProvider = AsyncNotifierProvider<UserInfoNotifier, SnAccount?>(
  UserInfoNotifier.new,
);

final accountInfoProvider = FutureProvider.family
    .autoDispose<SnAccount?, String>((ref, accountRef) async {
      final client = ref.watch(solarNetworkClientProvider);
      try {
        return await client.accounts.getAccountByUsername(accountRef);
      } catch (_) {
        return null;
      }
    });
