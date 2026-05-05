import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';

class WalletPinStatus {
  final bool hasPin;
  final bool validationRequired;

  const WalletPinStatus({
    required this.hasPin,
    required this.validationRequired,
  });

  factory WalletPinStatus.fromJson(Map<String, dynamic> json) {
    return WalletPinStatus(
      hasPin: json['has_pin'] == true,
      validationRequired: json['validation_required'] == true,
    );
  }
}

Future<WalletPinStatus> fetchWalletPinStatus(WidgetRef ref) async {
  final client = ref.read(solarNetworkClientProvider);
  final response = await client.dio.get('/accounts/me/pin-status');
  return WalletPinStatus.fromJson(Map<String, dynamic>.from(response.data));
}
