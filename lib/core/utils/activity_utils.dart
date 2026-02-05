import 'package:flutter/material.dart';
import 'package:island/accounts/accounts_models/account.dart';

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

Widget buildActivityDetails(SnAccountStatus? status) {
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
