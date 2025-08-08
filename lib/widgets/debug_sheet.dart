import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/message.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

class DebugSheet extends HookConsumerWidget {
  const DebugSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wsNotifier = ref.watch(websocketStateProvider.notifier);

    return SheetScaffold(
      titleText: 'Debug',
      child: Column(
        children: [
          ListTile(
            minTileHeight: 48,
            leading: const Icon(Symbols.wifi),
            trailing: const Icon(Symbols.chevron_right),
            title: Text('Connection Status'),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder:
                    (context) => NetworkStatusSheet(
                      onReconnect: () => wsNotifier.connect(),
                    ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            minTileHeight: 48,
            leading: const Icon(Symbols.copy_all),
            trailing: const Icon(Symbols.chevron_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            title: Text('Copy access token'),
            onTap: () async {
              final tk = ref.watch(tokenProvider);
              Clipboard.setData(ClipboardData(text: tk!.token));
            },
          ),
          ListTile(
            minTileHeight: 48,
            leading: const Icon(Symbols.delete),
            trailing: const Icon(Symbols.chevron_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            title: Text('Reset database'),
            onTap: () async {
              resetDatabase(ref);
            },
          ),
          ListTile(
            minTileHeight: 48,
            leading: const Icon(Symbols.clear),
            trailing: const Icon(Symbols.chevron_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            title: Text('Clear cache'),
            onTap: () async {
              DefaultCacheManager().emptyCache();
            },
          ),
        ],
      ),
    );
  }
}
