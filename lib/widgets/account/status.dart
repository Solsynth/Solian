import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/status_creation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'status.g.dart';

@riverpod
Future<SnAccountStatus?> accountStatus(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get('/id/accounts/$uname/statuses');
    return SnAccountStatus.fromJson(resp.data);
  } catch (err) {
    if (err is DioException) {
      if (err.response?.statusCode == 404) {
        return null;
      }
    }
    rethrow;
  }
}

class AccountStatusCreationWidget extends HookConsumerWidget {
  final String uname;
  final EdgeInsets? padding;
  const AccountStatusCreationWidget({
    super.key,
    required this.uname,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatus = ref.watch(accountStatusProvider(uname));

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: userStatus.when(
        data:
            (status) =>
                (status?.isCustomized ?? false)
                    ? Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: AccountStatusWidget(uname: uname),
                    )
                    : Padding(
                      padding:
                          padding ??
                          EdgeInsets.symmetric(horizontal: 27, vertical: 4),
                      child: Row(
                        spacing: 4,
                        children: [
                          Icon(Symbols.keyboard_arrow_up),
                          Expanded(
                            child: Text('statusCreateHint', maxLines: 1).tr(),
                          ),
                        ],
                      ),
                    ).opacity(0.85),
        error:
            (error, _) => Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: 26, vertical: 4),
              child: Row(
                spacing: 4,
                children: [Icon(Symbols.close), Text('Error: $error')],
              ),
            ).opacity(0.85),
        loading:
            () => Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: 26, vertical: 4),
              child: Row(
                spacing: 4,
                children: [Icon(Symbols.more_vert), Text('loading').tr()],
              ),
            ).opacity(0.85),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder:
              (context) => AccountStatusCreationSheet(
                initialStatus:
                    (userStatus.value?.isCustomized ?? false)
                        ? userStatus.value
                        : null,
              ),
        );
      },
    );
  }
}

class AccountStatusWidget extends HookConsumerWidget {
  final String uname;
  final EdgeInsets? padding;
  const AccountStatusWidget({super.key, required this.uname, this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(accountStatusProvider(uname));
    final account = ref.watch(accountProvider(uname));

    String? getActivityTitle(String? label, Map<String, dynamic>? meta) {
      if (meta == null) return label;
      if (meta['assets']?['large_text'] is String) {
        return meta['assets']?['large_text'];
      }
      return label;
    }

    String? getActivitySubtitle(Map<String, dynamic>? meta) {
      if (meta == null) return null;
      if (meta['assets']?['small_text'] is String) {
        return meta['assets']?['small_text'];
      }
      return null;
    }

    InlineSpan getActivityFullMessage(SnAccountStatus? status) {
      if (status?.meta == null) return TextSpan(text: 'No activity details available');
      final meta = status!.meta!;
      final List<InlineSpan> spans = [];
      if (meta.containsKey('assets') && meta['assets'] is Map) {
        final assets = meta['assets'] as Map<String, dynamic>;
        if (assets.containsKey('large_text')) {
          spans.add(TextSpan(text: assets['large_text'], style: TextStyle(fontWeight: FontWeight.bold)));
        }
        if (assets.containsKey('small_text')) {
          if (spans.isNotEmpty) spans.add(TextSpan(text: '\n'));
          spans.add(TextSpan(text: assets['small_text']));
        }
      }
      String normalText = '';
      if (meta.containsKey('details')) {
        normalText += 'Details: ${meta['details']}\n';
      }
      if (meta.containsKey('state')) {
        normalText += 'State: ${meta['state']}\n';
      }
      if (meta.containsKey('timestamps') && meta['timestamps'] is Map) {
        final ts = meta['timestamps'] as Map<String, dynamic>;
        if (ts.containsKey('start') && ts['start'] is int) {
          final start = DateTime.fromMillisecondsSinceEpoch(ts['start'] * 1000);
          normalText += 'Started: ${start.toLocal()}\n';
        }
        if (ts.containsKey('end') && ts['end'] is int) {
          final end = DateTime.fromMillisecondsSinceEpoch(ts['end'] * 1000);
          normalText += 'Ends: ${end.toLocal()}\n';
        }
      }
      if (meta.containsKey('party') && meta['party'] is Map) {
        final party = meta['party'] as Map<String, dynamic>;
        if (party.containsKey('size') && party['size'] is List && party['size'].length >= 2) {
          final size = party['size'] as List;
          normalText += 'Party: ${size[0]}/${size[1]}\n';
        }
      }
      if (meta.containsKey('instance')) {
        normalText += 'Instance: ${meta['instance']}\n';
      }
      // Add other keys if present
      meta.forEach((key, value) {
        if (!['details', 'state', 'timestamps', 'assets', 'party', 'secrets', 'instance'].contains(key)) {
          normalText += '$key: $value\n';
        }
      });
      if (normalText.isNotEmpty) {
        if (spans.isNotEmpty) spans.add(TextSpan(text: '\n'));
        spans.add(TextSpan(text: normalText.trimRight()));
      }
      return TextSpan(children: spans);
    }

    Widget _buildActivityDetails(SnAccountStatus? status) {
      if (status?.meta == null) return Text('No activity details available');
      final meta = status!.meta!;
      final List<Widget> children = [];
      if (meta.containsKey('assets') && meta['assets'] is Map) {
        final assets = meta['assets'] as Map<String, dynamic>;
        if (assets.containsKey('large_text')) {
          children.add(Text(assets['large_text']));
        }
        if (assets.containsKey('small_text')) {
          children.add(Text(assets['small_text']));
        }
      }
      if (meta.containsKey('details')) {
        children.add(Text('Details: ${meta['details']}'));
      }
      if (meta.containsKey('state')) {
        children.add(Text('State: ${meta['state']}'));
      }
      if (meta.containsKey('timestamps') && meta['timestamps'] is Map) {
        final ts = meta['timestamps'] as Map<String, dynamic>;
        if (ts.containsKey('start') && ts['start'] is int) {
          final start = DateTime.fromMillisecondsSinceEpoch(ts['start'] * 1000);
          children.add(Text('Started: ${start.toLocal()}'));
        }
        if (ts.containsKey('end') && ts['end'] is int) {
          final end = DateTime.fromMillisecondsSinceEpoch(ts['end'] * 1000);
          children.add(Text('Ends: ${end.toLocal()}'));
        }
      }
      if (meta.containsKey('party') && meta['party'] is Map) {
        final party = meta['party'] as Map<String, dynamic>;
        if (party.containsKey('size') && party['size'] is List && party['size'].length >= 2) {
          final size = party['size'] as List;
          children.add(Text('Party: ${size[0]}/${size[1]}'));
        }
      }
      if (meta.containsKey('instance')) {
        children.add(Text('Instance: ${meta['instance']}'));
      }
      // Add other keys if present
      children.addAll(meta.entries.where((e) => !['details', 'state', 'timestamps', 'assets', 'party', 'secrets', 'instance'].contains(e.key)).map((e) => Text('${e.key}: ${e.value}')));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 27, vertical: 4),
      child: Row(
        spacing: 4,
        children: [
          if (status.value?.isOnline ?? false)
            Icon(
              Symbols.circle,
              fill: 1,
              color: Colors.green,
              size: 16,
            ).padding(right: 4)
          else
            Icon(
              Symbols.circle,
              color: Colors.grey,
              size: 16,
            ).padding(right: 4),
          if (status.value?.isCustomized ?? false)
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Activity Details'),
                      content: _buildActivityDetails(status.value),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Tooltip(
                  richMessage: getActivityFullMessage(status.value),
                  child: Text(
                    getActivityTitle(status.value?.label, status.value?.meta) ??
                        'unknown'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child:
                  Text(
                    (status.value?.label ?? 'offline').toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).tr(),
            ),
          if (getActivitySubtitle(status.value?.meta) != null)
            Flexible(
              child: Text(
                getActivitySubtitle(status.value?.meta)!,
              ).opacity(0.75),
            )
          else if (!(status.value?.isOnline ?? false) &&
              account.value?.profile.lastSeenAt != null)
            Flexible(
              child: Text(
                account.value!.profile.lastSeenAt!.formatRelative(context),
              ).opacity(0.75),
            ),
        ],
      ),
    ).opacity((status.value?.isCustomized ?? false) ? 1 : 0.85);
  }
}

class AccountStatusLabel extends StatelessWidget {
  final SnAccountStatus status;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  const AccountStatusLabel({
    super.key,
    required this.status,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Symbols.circle,
          fill: 1,
          color: status.isOnline ? Colors.green : Colors.grey,
          size: 14,
        ).padding(right: 4),
        Flexible(
          child: Text(
            status.label,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
          ).fontSize(13),
        ),
      ],
    );
  }
}
