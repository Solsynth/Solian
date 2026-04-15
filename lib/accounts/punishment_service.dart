import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final punishmentServiceProvider = Provider<PunishmentService>((ref) {
  return PunishmentService(ref);
});

class PunishmentService {
  final Ref ref;
  PunishmentService(this.ref);

  Future<PaginatedResult<SnAccountPunishment>> getPunishments(
    String username, {
    int offset = 0,
    int take = 20,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.padlock.getAccountPunishments(
      username,
      offset: offset,
      take: take,
    );
  }

  Future<SnAccountPunishment?> getPunishmentOverview(String username) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.padlock.getAccountPunishmentOverview(username);
  }

  Future<SnAccountPunishment> createPunishment({
    required String username,
    required String reason,
    required PunishmentType type,
    DateTime? expiredAt,
    List<String>? blockedPermissions,
    double? socialCreditReduction,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.padlock.createPunishment(
      username: username,
      reason: reason,
      type: type,
      expiredAt: expiredAt,
      blockedPermissions: blockedPermissions,
      socialCreditReduction: socialCreditReduction,
    );
  }

  Future<SnAccountPunishment> updatePunishment({
    required String username,
    required String punishmentId,
    String? reason,
    PunishmentType? type,
    DateTime? expiredAt,
    List<String>? blockedPermissions,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.padlock.updatePunishment(
      username: username,
      punishmentId: punishmentId,
      reason: reason,
      type: type,
      expiredAt: expiredAt,
      blockedPermissions: blockedPermissions,
    );
  }

  Future<void> deletePunishment(String username, String punishmentId) async {
    final client = ref.watch(solarNetworkClientProvider);
    await client.padlock.deletePunishment(username, punishmentId);
  }

  Future<PaginatedResult<SnAccountPunishment>> getAdminCreatedPunishments({
    int offset = 0,
    int take = 20,
  }) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.padlock.getAdminCreatedPunishments(
      offset: offset,
      take: take,
    );
  }
}
