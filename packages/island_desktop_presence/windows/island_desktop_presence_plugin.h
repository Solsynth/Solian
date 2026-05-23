#ifndef FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_
#define FLUTTER_PLUGIN_ISLAND_DESKTOP_PRESENCE_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <atomic>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <vector>

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
