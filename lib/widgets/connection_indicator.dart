import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<WebSocketProvider>();
    final cfg = context.watch<ConfigProvider>();

    final marginLeft =
        cfg.drawerIsCollapsed
            ? 0.0
            : cfg.drawerIsExpanded
            ? 304.0
            : 80.0;

    return ListenableBuilder(
      listenable: ws,
      builder: (context, _) {
        final ua = context.read<UserProvider>();
        final show = (ws.isBusy || !ws.isConnected) && ua.isAuthorized;

        return IgnorePointer(
          ignoring: !show,
          child: Center(
            child: GestureDetector(
              child: Material(
                elevation: 2,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child:
                    ua.isAuthorized
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (ws.isBusy)
                              Text(
                                'serverConnecting',
                              ).tr().textColor(Theme.of(context).colorScheme.onSecondaryContainer)
                            else if (!ws.isConnected)
                              Text(
                                'serverDisconnected',
                              ).tr().textColor(Theme.of(context).colorScheme.onSecondaryContainer)
                            else
                              Text(
                                'serverConnected',
                              ).tr().textColor(Theme.of(context).colorScheme.onSecondaryContainer),
                            const Gap(8),
                            if (ws.isBusy)
                              const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                padding: EdgeInsets.zero,
                              ).width(12).height(12).padding(horizontal: 4, right: 4)
                            else if (!ws.isConnected)
                              const Icon(Symbols.power_off, size: 18)
                            else
                              const Icon(Symbols.power, size: 18),
                          ],
                        ).padding(horizontal: 8, vertical: 4)
                        : const SizedBox.shrink(),
              ).opacity(show ? 1 : 0, animate: true).animate(const Duration(milliseconds: 300), Curves.easeInOut),
              onTap: () {
                if (!ws.isConnected && !ws.isBusy) {
                  ws.connect();
                }
              },
            ),
          ).padding(left: marginLeft),
        );
      },
    );
  }
}
