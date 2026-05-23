#ifndef FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
#define FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace island_desktop_presence {

class IslandDesktopPresencePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  IslandDesktopPresencePlugin();

  virtual ~IslandDesktopPresencePlugin();

  // Disallow copy and assign.
  IslandDesktopPresencePlugin(const IslandDesktopPresencePlugin&) = delete;
  IslandDesktopPresencePlugin& operator=(const IslandDesktopPresencePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace island_desktop_presence

#endif  // FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
