import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';

class UserInfoNotifier extends StateNotifier<AsyncValue<SnAccount?>> {
  final Ref _ref;

  UserInfoNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<String?> getAccessToken() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    return prefs.getString('dyn_user_atk');
  }

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.get('/accounts/me');
      final user = SnAccount.fromJson(response.data);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      print('Failed to fetch user: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logOut() async {
    state = const AsyncValue.data(null);
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove(kTokenPairStoreKey);
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, AsyncValue<SnAccount?>>(
      (ref) => UserInfoNotifier(ref),
    );
