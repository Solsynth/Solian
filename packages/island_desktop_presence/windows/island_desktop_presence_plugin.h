#ifndef FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
#define FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <optional>

namespace island_desktop_presence {

class IslandDesktopPresencePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  IslandDesktopPresencePlugin();
  explicit IslandDesktopPresencePlugin(
      flutter::PluginRegistrarWindows* registrar);

  ~IslandDesktopPresencePlugin() override;

  IslandDesktopPresencePlugin(const IslandDesktopPresencePlugin&) = delete;
  IslandDesktopPresencePlugin& operator=(const IslandDesktopPresencePlugin&) =
      delete;

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  enum class PresenceState {
    kActive,
    kIdle,
  };

  std::optional<LRESULT> HandleWindowProc(HWND hwnd,
                                          UINT message,
                                          WPARAM wparam,
                                          LPARAM lparam);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListen(const flutter::EncodableValue* arguments,
           std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
               events);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancel(const flutter::EncodableValue* arguments);
  void StartMonitoring();
  void StopMonitoring(bool reset_state = true);
  void EmitCurrentState(bool force);
  std::optional<int64_t> GetIdleMilliseconds() const;
  flutter::EncodableMap BuildEvent(PresenceState state,
                                   int64_t idle_milliseconds) const;

  flutter::PluginRegistrarWindows* registrar_ = nullptr;
  int window_proc_id_ = 0;
  UINT_PTR timer_id_ = 0;
  int64_t idle_threshold_milliseconds_ = 300000;
  std::optional<PresenceState> last_emitted_state_;
  std::optional<flutter::EncodableMap> pending_event_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

}  // namespace island_desktop_presence

#endif  // FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
