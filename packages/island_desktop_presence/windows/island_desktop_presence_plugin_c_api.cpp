#include "include/island_desktop_presence/island_desktop_presence_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "island_desktop_presence_plugin.h"

void IslandDesktopPresencePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  island_desktop_presence::IslandDesktopPresencePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
