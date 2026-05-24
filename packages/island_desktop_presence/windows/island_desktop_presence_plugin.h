#ifndef FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
#define FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <atomic>
#include <condition_variable>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <vector>

#include <winrt/Windows.Media.Control.h>

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
  struct RpcConnection {
    std::string connection_id;
    void* pipe_handle = nullptr;
    std::vector<uint8_t> buffer;
  };

  enum class PresenceState {
    kActive,
    kIdle,
  };

  std::optional<LRESULT> HandleWindowProc(HWND hwnd,
                                          UINT message,
                                          WPARAM wparam,
                                          LPARAM lparam);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnExternalNowPlayingListen(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnExternalNowPlayingCancel(const flutter::EncodableValue* arguments);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnPresenceListen(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnPresenceCancel(const flutter::EncodableValue* arguments);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnRpcListen(const flutter::EncodableValue* arguments,
              std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                  events);
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnRpcCancel(const flutter::EncodableValue* arguments);
  void StartMonitoring();
  void StopMonitoring(bool reset_state = true);
  void EmitCurrentState(bool force);
  std::optional<int64_t> GetIdleMilliseconds() const;
  flutter::EncodableMap BuildPresenceEvent(PresenceState state,
                                           int64_t idle_milliseconds) const;

  struct ExternalNowPlayingSnapshot {
    std::string source;
    std::string state;
    std::optional<std::string> source_app_name;
    std::optional<std::string> source_bundle_identifier;
    std::optional<std::string> unique_identifier;
    std::optional<std::string> title;
    std::optional<std::string> artist;
    std::optional<std::string> album;
    std::optional<double> duration_seconds;
    std::optional<double> position_seconds;
  };

  void StartExternalNowPlayingMonitoring(int poll_interval_milliseconds);
  void StopExternalNowPlayingMonitoring(bool reset_state = true);
  void EmitCurrentExternalNowPlaying(bool force);
  std::optional<ExternalNowPlayingSnapshot> ReadExternalNowPlayingSnapshot() const;
  flutter::EncodableMap BuildExternalNowPlayingEvent(
      const ExternalNowPlayingSnapshot& snapshot) const;
  static std::string NormalizeSourceAppId(const winrt::hstring& value);
  static std::string ToUtf8(const winrt::hstring& value);

  bool StartRpcTransport(std::string* error_message);
  void StopRpcTransport();
  bool SendRpcPacket(const std::string& connection_id,
                     int32_t packet_type,
                     const std::string& data_json,
                     std::string* error_message);
  bool CloseRpcConnection(const std::string& connection_id,
                          std::string* error_message);
  void AcceptRpcConnections();
  void ReadRpcConnection(std::shared_ptr<RpcConnection> connection);
  void EmitRpcConnected(const std::string& connection_id);
  void EmitRpcPacket(const std::string& connection_id,
                     int32_t packet_type,
                     const std::string& data_json);
  void EmitRpcClosed(const std::string& connection_id);
  void EmitRpcError(const std::string& message);
  void QueueRpcEvent(flutter::EncodableMap event);
  static std::vector<uint8_t> EncodeRpcPacket(int32_t packet_type,
                                              const std::string& data_json);

  flutter::PluginRegistrarWindows* registrar_ = nullptr;
  int window_proc_id_ = 0;
  UINT_PTR timer_id_ = 0;
  int64_t idle_threshold_milliseconds_ = 300000;
  std::optional<PresenceState> last_emitted_state_;
  std::optional<flutter::EncodableMap> pending_presence_event_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
      presence_event_sink_;

  std::mutex external_now_playing_mutex_;
  std::condition_variable external_now_playing_cv_;
  std::atomic_bool external_now_playing_running_ = false;
  int external_now_playing_poll_interval_milliseconds_ = 2000;
  std::thread external_now_playing_thread_;
  std::optional<ExternalNowPlayingSnapshot> last_emitted_external_now_playing_;
  std::optional<flutter::EncodableMap> pending_external_now_playing_event_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
      external_now_playing_event_sink_;

  std::mutex rpc_mutex_;
  std::atomic_bool rpc_running_ = false;
  void* rpc_listener_pipe_ = nullptr;
  uint64_t next_rpc_connection_id_ = 1;
  std::vector<flutter::EncodableMap> pending_rpc_events_;
  std::map<std::string, std::shared_ptr<RpcConnection>> rpc_connections_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> rpc_event_sink_;
  std::thread rpc_accept_thread_;
};

}  // namespace island_desktop_presence

#endif  // FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
