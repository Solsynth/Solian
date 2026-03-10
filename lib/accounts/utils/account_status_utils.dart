import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

bool showsOnlinePresence(SnAccountStatus? status) {
  if (status == null) return false;
  return status.isOnline && !status.isInvisible;
}

String getStatusTypeLabel(BuildContext context, SnAccountStatus? status) {
  if (status == null || !status.isOnline) {
    return 'offline'.tr();
  }

  return switch (status.type) {
    SnAccountStatusType.busy => 'statusBusy'.tr(),
    SnAccountStatusType.doNotDisturb => 'statusNotDisturb'.tr(),
    SnAccountStatusType.invisible => 'statusInvisible'.tr(),
    _ => 'online'.tr(),
  };
}

String getStatusDisplayLabel(BuildContext context, SnAccountStatus? status) {
  final label = status?.label.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }
  return getStatusTypeLabel(context, status);
}

String? getStatusDisplaySymbol(SnAccountStatus? status) {
  final symbol = status?.symbol?.trim();
  if (symbol == null || symbol.isEmpty) return null;
  return symbol;
}
