import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart' as sdk;
import 'config.dart';
import 'network.dart';

final sdkTokenStorageProvider = Provider<sdk.TokenStorage>((ref) {
  return sdk.SharedPreferencesTokenStorage(key: kTokenPairStoreKey);
});

final sdkNetworkStatusServiceProvider = Provider<sdk.NetworkStatusService>((
  ref,
) {
  return sdk.NetworkStatusService();
});

final sdkWebAuthClientProvider = Provider<sdk.WebAuthClient>((ref) {
  return sdk.WebAuthClient(
    baseUrl: 'http://127.0.0.1',
    port: 0,
    webUrl: 'https://api.solian.app',
  );
});

final sdkAuthServiceProvider = Provider<sdk.AuthService>((ref) {
  final dio = ref.read(apiClientProvider);
  final tokenStorage = ref.read(sdkTokenStorageProvider);
  final serverUrl = ref.read(serverUrlProvider);
  return sdk.AuthService(
    dio: dio,
    serverUrl: serverUrl,
    tokenStorage: tokenStorage,
  );
});
