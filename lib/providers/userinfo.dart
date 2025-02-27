import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surface/logger.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';

class UserProvider extends ChangeNotifier {
  bool isAuthorized = false;
  SnAccount? user;

  late final SnNetworkProvider _sn;
  late final ConfigProvider _config;

  UserProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _config = context.read<ConfigProvider>();
  }

  Future<String?> get atk async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kAtkStoreKey);
  }

  Future<void> initialize() async {
    final value = _config.prefs.getString(kAtkStoreKey);
    isAuthorized = value != null;
    notifyListeners();
    refreshUser().then((value) async {
      if (value != null) {
        logging.info('[Auth] Logged in as @${value.name}');
        logging.debug('[Auth] Access token: ${await atk}');
      }
    });
  }

  Future<SnAccount?> refreshUser() async {
    final resp = await _sn.client.get('/cgi/id/users/me');
    final out = SnAccount.fromJson(resp.data);

    isAuthorized = true;
    user = out;
    notifyListeners();

    return out;
  }

  void logoutUser() async {
    _sn.clearTokenPair();
    isAuthorized = false;
    user = null;
    notifyListeners();
  }

  void setLanguage(String? value) {
    if (value == null) return;
    if (user == null) return;
    user = user!.copyWith(language: value);
    notifyListeners();
  }
}
