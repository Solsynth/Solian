import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

bool showsOnlinePresence(SnAccountStatus? status) {
  if (status == null) return false;
  return status.isOnline && !status.isInvisible;
}

String getStatusTypeLabel(BuildContext context, SnAccountStatus? status) {
  if (status == null) {
    return 'offline'.tr();
  }

  return switch (status.type) {
    SnAccountStatusType.busy => 'statusBusy'.tr(),
    SnAccountStatusType.doNotDisturb => 'statusNotDisturb'.tr(),
    SnAccountStatusType.invisible => 'statusInvisible'.tr(),
    _ => status.isOnline ? 'online'.tr() : 'offline'.tr(),
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

IconData getStatusIndicatorIcon(SnAccountStatus? status) {
  if (status == null) {
    return Symbols.circle;
  }

  return switch (status.type) {
    SnAccountStatusType.busy => Symbols.circle,
    SnAccountStatusType.doNotDisturb => Symbols.do_not_disturb_on,
    SnAccountStatusType.invisible => Symbols.visibility_off,
    _ => Symbols.circle,
  };
}

Color getStatusIndicatorColor(SnAccountStatus? status) {
  if (status == null) {
    return Colors.grey;
  }

  return switch (status.type) {
    SnAccountStatusType.busy => Colors.orange,
    SnAccountStatusType.doNotDisturb => Colors.deepOrange,
    SnAccountStatusType.invisible => Colors.grey,
    _ => status.isOnline ? Colors.green : Colors.grey,
  };
}
