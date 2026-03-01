import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/database.dart';

class E2eeKeypairScreen extends ConsumerStatefulWidget {
  const E2eeKeypairScreen({super.key});

  @override
  ConsumerState<E2eeKeypairScreen> createState() => _E2eeKeypairScreenState();
}

class _E2eeKeypairScreenState extends ConsumerState<E2eeKeypairScreen> {
  late Future<Map<String, String>> _secretsFuture;
  bool _revealSensitive = false;

  @override
  void initState() {
    super.initState();
    _secretsFuture = _loadSecrets();
  }

  Future<Map<String, String>> _loadSecrets() async {
    final db = ref.read(databaseProvider);
    return db.getAllSecrets();
  }

  void _refresh() {
    setState(() {
      _secretsFuture = _loadSecrets();
    });
  }

  bool _isE2eeRelatedKey(String key) {
    return key.contains('e2ee') ||
        key.contains('encryption') ||
        key.startsWith('chat_room_encryption_mode_');
  }

  String _displayValue(String value) {
    if (_revealSensitive) return value;
    if (value.length <= 24) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 8)}';
  }

  String _displayJsonField(dynamic value) {
    final text = value?.toString() ?? 'null';
    return _displayValue(text);
  }

  Map<String, dynamic>? _parseBundle(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) return parsed;
      if (parsed is Map) {
        return parsed.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return null;
  }

  Widget _buildBundleCard(String title, Map<String, dynamic> bundle) {
    final preKeys = (bundle['one_time_pre_keys'] is List)
        ? (bundle['one_time_pre_keys'] as List)
        : const [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text(
          'algorithm: ${bundle['algorithm'] ?? 'unknown'} • prekeys: ${preKeys.length}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('created_at', bundle['created_at']),
          _kv('identity_key', _displayJsonField(bundle['identity_key'])),
          _kv(
            'identity_private_key',
            _displayJsonField(bundle['identity_private_key']),
          ),
          _kv('signed_pre_key_id', bundle['signed_pre_key_id']),
          _kv('signed_pre_key', _displayJsonField(bundle['signed_pre_key'])),
          _kv(
            'signed_pre_key_private_key',
            _displayJsonField(bundle['signed_pre_key_private_key']),
          ),
          _kv(
            'signed_pre_key_signature',
            _displayJsonField(bundle['signed_pre_key_signature']),
          ),
          _kv('signed_pre_key_expires_at', bundle['signed_pre_key_expires_at']),
          const SizedBox(height: 8),
          Text(
            'one_time_pre_keys',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          if (preKeys.isEmpty)
            const Text('None')
          else
            ...preKeys.take(50).whereType<Map>().map((entry) {
              final keyId = entry['key_id'] ?? entry['keyId'];
              final pub = entry['public_key'] ?? entry['publicKey'];
              final pri = entry['private_key'] ?? entry['privateKey'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '#$keyId  pub=${_displayJsonField(pub)}  priv=${_displayJsonField(pri)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _kv(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText(
        '$key: ${value?.toString() ?? 'null'}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E2EE Keypairs'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _secretsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load keys: ${snapshot.error}'),
            );
          }

          final secrets = snapshot.data ?? const <String, String>{};
          final e2eeEntries =
              secrets.entries
                  .where((entry) => _isE2eeRelatedKey(entry.key))
                  .toList()
                ..sort((a, b) => a.key.compareTo(b.key));

          final bundleV2 = _parseBundle(secrets['chat_e2ee_bundle_v2']);
          final bundleV1 = _parseBundle(secrets['chat_e2ee_bundle_v1']);

          if (e2eeEntries.isEmpty && bundleV1 == null && bundleV2 == null) {
            return const Center(child: Text('No E2EE key material found.'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              SwitchListTile(
                title: const Text('Reveal sensitive values'),
                subtitle: const Text(
                  'Hidden by default. Turn on only in trusted environments.',
                ),
                value: _revealSensitive,
                onChanged: (value) => setState(() => _revealSensitive = value),
              ),
              if (bundleV2 != null)
                _buildBundleCard('Local Bundle (v2)', bundleV2),
              if (bundleV1 != null)
                _buildBundleCard('Local Bundle (v1)', bundleV1),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: const Text('Stored E2EE Secrets'),
                  subtitle: Text('${e2eeEntries.length} entries'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: e2eeEntries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: SelectableText(
                            '${entry.key}: ${_displayValue(entry.value)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
