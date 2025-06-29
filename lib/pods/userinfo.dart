import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';

class UserInfoNotifier extends StateNotifier<AsyncValue<SnAccount?>> {
  final Ref _ref;

  UserInfoNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> fetchUser() async {
    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.get('/accounts/me');
      final user = SnAccount.fromJson(response.data);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      log("[UserInfo] Failed to fetch user info: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logOut() async {
    state = const AsyncValue.data(null);
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove(kTokenPairStoreKey);
    _ref.invalidate(tokenProvider);
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, AsyncValue<SnAccount?>>(
      (ref) => UserInfoNotifier(ref),
    );
