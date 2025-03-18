import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/router.dart';

// https://api.flutter.dev/flutter/widgets/PlatformMenuBar-class.html
// All the code following is only works on macOS
class AppSystemMenuBar extends StatelessWidget {
  final Function? onQuit;
  final Widget child;
  const AppSystemMenuBar({super.key, this.onQuit, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isMacOS) return child;

    final nav = context.watch<NavigationProvider>();

    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: 'Solian',
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: 'screenAbout'.tr(),
                  onSelected: () {
                    appRouter.goNamed('about');
                    nav.autoDetectIndex(appRouter);
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'screenHome'.tr(),
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.digit1,
                    meta: true,
                  ),
                  onSelected: () {
                    appRouter.goNamed('home');
                    nav.autoDetectIndex(appRouter);
                  },
                ),
                PlatformMenuItem(
                  label: 'screenExplore'.tr(),
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.digit2,
                    meta: true,
                  ),
                  onSelected: () {
                    appRouter.goNamed('explore');
                    nav.autoDetectIndex(appRouter);
                  },
                ),
                PlatformMenuItem(
                  label: 'screenChat'.tr(),
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.digit3,
                    meta: true,
                  ),
                  onSelected: () {
                    appRouter.goNamed('chat');
                  },
                ),
                PlatformMenuItem(
                  label: 'screenAccount'.tr(),
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.digit4,
                    meta: true,
                  ),
                  onSelected: () {
                    appRouter.goNamed('account');
                  },
                ),
              ],
            ),
            PlatformMenuItem(
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyH,
                meta: true,
              ),
              label: 'trayMenuHide'.tr(),
              onSelected: () {
                appWindow.hide();
              },
            ),
            if (onQuit != null)
              PlatformMenuItem(
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyQ,
                  meta: true,
                ),
                label: 'trayMenuExit'.tr(),
                onSelected: () {
                  onQuit?.call();
                },
              ),
          ],
        ),
      ],
      child: child,
    );
  }
}
