#include "island_desktop_presence_plugin.h"

#include <windows.h>

#include <flutter/standard_method_codec.h>

#include <cstring>
#include <memory>
#include <string>
#include <thread>

namespace {
constexpr char kMethodChannelName[] = "island_desktop_presence";
constexpr char kPresenceEventChannelName[] = "island_desktop_presence/events";
constexpr char kRpcEventChannelName[] = "island_desktop_presence/rpc_events";
constexpr char kRpcPipeName[] = R"(\\.\pipe\discord-ipc-0)";
constexpr UINT_PTR kPollingTimerId = 1;
constexpr UINT kPollingIntervalMilliseconds = 3000;
constexpr size_t kRpcReadBufferSize = 4096;
}  // namespace

namespace island_desktop_presence {

namespace {
HANDLE AsHandle(void* handle) { return static_cast<HANDLE>(handle); }
void* AsVoidPtr(HANDLE handle) { return static_cast<void*>(handle); }
}  // namespace

void IslandDesktopPresencePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto method_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kMethodChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto presence_event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kPresenceEventChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto rpc_event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kRpcEventChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<IslandDesktopPresencePlugin>(registrar);

  method_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  presence_event_channel->SetStreamHandler(std::make_unique<
                                           flutter::StreamHandlerFunctions<
                                               flutter::EncodableValue>>(
      [plugin_pointer = plugin.get()](
          const auto* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
              events) {
        return plugin_pointer->OnPresenceListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const auto* arguments) {
        return plugin_pointer->OnPresenceCancel(arguments);
      }));

  rpc_event_channel->SetStreamHandler(std::make_unique<
                                      flutter::StreamHandlerFunctions<
                                          flutter::EncodableValue>>(
      [plugin_pointer = plugin.get()](
          const auto* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
              events) {
        return plugin_pointer->OnRpcListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const auto* arguments) {
        return plugin_pointer->OnRpcCancel(arguments);
      }));

  registrar->AddPlugin(std::move(plugin));
}

IslandDesktopPresencePlugin::IslandDesktopPresencePlugin() = default;

IslandDesktopPresencePlugin::IslandDesktopPresencePlugin(
    flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {
  if (registrar_ != nullptr) {
    window_proc_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
        [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
          return HandleWindowProc(hwnd, message, wparam, lparam);
        });
  }
}

IslandDesktopPresencePlugin::~IslandDesktopPresencePlugin() {
  StopRpcTransport();
  StopMonitoring();
  if (registrar_ != nullptr && window_proc_id_ != 0) {
    registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
  }
}

void IslandDesktopPresencePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "getIdleTime") {
    const auto idle_milliseconds = GetIdleMilliseconds();
    if (!idle_milliseconds.has_value()) {
      result->Error("idle_unavailable",
                    "Unable to query idle time from GetLastInputInfo.");
      return;
    }
    result->Success(flutter::EncodableValue(*idle_milliseconds));
    return;
  }

  if (method_call.method_name() == "startMonitoring") {
    const auto* arguments_value = method_call.arguments();
    if (arguments_value == nullptr) {
      result->Error("invalid_arguments",
                    "Expected startMonitoring arguments.");
      return;
    }

    const auto* arguments = std::get_if<flutter::EncodableMap>(arguments_value);
    if (arguments == nullptr) {
      result->Error("invalid_arguments",
                    "Expected startMonitoring arguments.");
      return;
    }

    const auto threshold_iterator =
        arguments->find(flutter::EncodableValue("idleThresholdMilliseconds"));
    if (threshold_iterator == arguments->end()) {
      result->Error("invalid_arguments",
                    "idleThresholdMilliseconds is required.");
      return;
    }

    const auto* threshold = std::get_if<int32_t>(&threshold_iterator->second);
    if (threshold == nullptr || *threshold < 0) {
      result->Error("invalid_arguments",
                    "idleThresholdMilliseconds must be a non-negative int.");
      return;
    }

    idle_threshold_milliseconds_ = *threshold;
    StartMonitoring();
    EmitCurrentState(true);
    result->Success();
    return;
  }

  if (method_call.method_name() == "stopMonitoring") {
    StopMonitoring();
    result->Success();
    return;
  }

  if (method_call.method_name() == "startRpcTransport") {
    std::string error_message;
    if (!StartRpcTransport(&error_message)) {
      result->Error("rpc_transport_unavailable", error_message);
      return;
    }
    result->Success();
    return;
  }

  if (method_call.method_name() == "stopRpcTransport") {
    StopRpcTransport();
    result->Success();
    return;
  }

  if (method_call.method_name() == "sendRpcPacket") {
    const auto* arguments_value = method_call.arguments();
    const auto* arguments =
        arguments_value == nullptr
            ? nullptr
            : std::get_if<flutter::EncodableMap>(arguments_value);
    if (arguments == nullptr) {
      result->Error("invalid_arguments", "Expected sendRpcPacket arguments.");
      return;
    }

    const auto connection_it =
        arguments->find(flutter::EncodableValue("connectionId"));
    const auto type_it = arguments->find(flutter::EncodableValue("packetType"));
    const auto data_it = arguments->find(flutter::EncodableValue("dataJson"));
    if (connection_it == arguments->end() || type_it == arguments->end() ||
        data_it == arguments->end()) {
      result->Error("invalid_arguments",
                    "sendRpcPacket requires connectionId, packetType and dataJson.");
      return;
    }

    const auto* connection_id =
        std::get_if<std::string>(&connection_it->second);
    const auto* data_json = std::get_if<std::string>(&data_it->second);
    int32_t packet_type = 0;
    if (const auto* type32 = std::get_if<int32_t>(&type_it->second)) {
      packet_type = *type32;
    } else if (const auto* type64 = std::get_if<int64_t>(&type_it->second)) {
      packet_type = static_cast<int32_t>(*type64);
    } else {
      result->Error("invalid_arguments", "packetType must be an integer.");
      return;
    }

    if (connection_id == nullptr || data_json == nullptr) {
      result->Error("invalid_arguments",
                    "connectionId and dataJson must be strings.");
      return;
    }

    std::string error_message;
    if (!SendRpcPacket(*connection_id, packet_type, *data_json,
                       &error_message)) {
      result->Error("rpc_send_failed", error_message);
      return;
    }
    result->Success();
    return;
  }

  if (method_call.method_name() == "closeRpcConnection") {
    const auto* arguments_value = method_call.arguments();
    const auto* arguments =
        arguments_value == nullptr
            ? nullptr
            : std::get_if<flutter::EncodableMap>(arguments_value);
    if (arguments == nullptr) {
      result->Error("invalid_arguments",
                    "Expected closeRpcConnection arguments.");
      return;
    }

    const auto connection_it =
        arguments->find(flutter::EncodableValue("connectionId"));
    if (connection_it == arguments->end()) {
      result->Error("invalid_arguments",
                    "closeRpcConnection requires connectionId.");
      return;
    }
    const auto* connection_id =
        std::get_if<std::string>(&connection_it->second);
    if (connection_id == nullptr) {
      result->Error("invalid_arguments", "connectionId must be a string.");
      return;
    }

    std::string error_message;
    if (!CloseRpcConnection(*connection_id, &error_message)) {
      result->Error("rpc_close_failed", error_message);
      return;
    }
    result->Success();
    return;
  }

  result->NotImplemented();
}

std::optional<LRESULT> IslandDesktopPresencePlugin::HandleWindowProc(
    HWND hwnd,
    UINT message,
    WPARAM wparam,
    LPARAM lparam) {
  if (message == WM_TIMER && wparam == timer_id_) {
    EmitCurrentState(false);
    return 0;
  }

  return std::nullopt;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
IslandDesktopPresencePlugin::OnPresenceListen(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  presence_event_sink_ = std::move(events);
  if (pending_presence_event_.has_value()) {
    presence_event_sink_->Success(
        flutter::EncodableValue(*pending_presence_event_));
    pending_presence_event_.reset();
  }
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
IslandDesktopPresencePlugin::OnPresenceCancel(
    const flutter::EncodableValue* arguments) {
  presence_event_sink_.reset();
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
IslandDesktopPresencePlugin::OnRpcListen(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  rpc_event_sink_ = std::move(events);
  for (const auto& pending_event : pending_rpc_events_) {
    rpc_event_sink_->Success(flutter::EncodableValue(pending_event));
  }
  pending_rpc_events_.clear();
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
IslandDesktopPresencePlugin::OnRpcCancel(
    const flutter::EncodableValue* arguments) {
  rpc_event_sink_.reset();
  return nullptr;
}

void IslandDesktopPresencePlugin::StartMonitoring() {
  StopMonitoring(false);

  if (registrar_ == nullptr || registrar_->GetView() == nullptr) {
    return;
  }

  HWND window = registrar_->GetView()->GetNativeWindow();
  timer_id_ = SetTimer(window, kPollingTimerId, kPollingIntervalMilliseconds,
                       nullptr);
}

void IslandDesktopPresencePlugin::StopMonitoring(bool reset_state) {
  if (timer_id_ != 0 && registrar_ != nullptr && registrar_->GetView() != nullptr) {
    KillTimer(registrar_->GetView()->GetNativeWindow(), timer_id_);
    timer_id_ = 0;
  }

  if (reset_state) {
    last_emitted_state_.reset();
    pending_presence_event_.reset();
  }
}

void IslandDesktopPresencePlugin::EmitCurrentState(bool force) {
  const auto idle_milliseconds = GetIdleMilliseconds();
  if (!idle_milliseconds.has_value()) {
    return;
  }

  const PresenceState state =
      *idle_milliseconds >= idle_threshold_milliseconds_
          ? PresenceState::kIdle
          : PresenceState::kActive;

  if (!force && last_emitted_state_.has_value() &&
      last_emitted_state_.value() == state) {
    return;
  }

  last_emitted_state_ = state;
  flutter::EncodableMap event = BuildPresenceEvent(state, *idle_milliseconds);
  if (presence_event_sink_ != nullptr) {
    presence_event_sink_->Success(flutter::EncodableValue(event));
  } else {
    pending_presence_event_ = std::move(event);
  }
}

std::optional<int64_t> IslandDesktopPresencePlugin::GetIdleMilliseconds() const {
  LASTINPUTINFO info = {};
  info.cbSize = sizeof(LASTINPUTINFO);
  if (!GetLastInputInfo(&info)) {
    return std::nullopt;
  }

  return static_cast<int64_t>(GetTickCount64() - info.dwTime);
}

flutter::EncodableMap IslandDesktopPresencePlugin::BuildPresenceEvent(
    PresenceState state,
    int64_t idle_milliseconds) const {
  const char* state_name = state == PresenceState::kIdle ? "idle" : "active";
  return flutter::EncodableMap{
      {flutter::EncodableValue("state"),
       flutter::EncodableValue(std::string(state_name))},
      {flutter::EncodableValue("idle_seconds"),
       flutter::EncodableValue(static_cast<int32_t>(idle_milliseconds / 1000))},
  };
}

bool IslandDesktopPresencePlugin::StartRpcTransport(
    std::string* error_message) {
  if (rpc_running_) {
    return true;
  }

  rpc_running_ = true;
  rpc_accept_thread_ = std::thread([this]() { AcceptRpcConnections(); });
  return true;
}

void IslandDesktopPresencePlugin::StopRpcTransport() {
  if (!rpc_running_) {
    return;
  }

  rpc_running_ = false;

  HANDLE listener_pipe = INVALID_HANDLE_VALUE;
  {
    std::lock_guard<std::mutex> lock(rpc_mutex_);
    listener_pipe = AsHandle(rpc_listener_pipe_);
  }

  if (listener_pipe != INVALID_HANDLE_VALUE) {
    HANDLE unblock_handle = CreateFileA(
        kRpcPipeName, GENERIC_READ | GENERIC_WRITE, 0, nullptr, OPEN_EXISTING,
        0, nullptr);
    if (unblock_handle != INVALID_HANDLE_VALUE) {
      CloseHandle(unblock_handle);
    }
  }

  if (rpc_accept_thread_.joinable()) {
    rpc_accept_thread_.join();
  }

  std::vector<std::shared_ptr<RpcConnection>> connections;
  {
    std::lock_guard<std::mutex> lock(rpc_mutex_);
    for (const auto& entry : rpc_connections_) {
      connections.push_back(entry.second);
    }
    rpc_connections_.clear();
    rpc_listener_pipe_ = nullptr;
  }

  for (const auto& connection : connections) {
    HANDLE pipe = AsHandle(connection->pipe_handle);
    if (pipe != INVALID_HANDLE_VALUE) {
      CloseHandle(pipe);
    }
  }
}

bool IslandDesktopPresencePlugin::SendRpcPacket(const std::string& connection_id,
                                                int32_t packet_type,
                                                const std::string& data_json,
                                                std::string* error_message) {
  std::shared_ptr<RpcConnection> connection;
  {
    std::lock_guard<std::mutex> lock(rpc_mutex_);
    const auto it = rpc_connections_.find(connection_id);
    if (it == rpc_connections_.end()) {
      *error_message = "Unknown RPC connection.";
      return false;
    }
    connection = it->second;
  }

  const auto packet = EncodeRpcPacket(packet_type, data_json);
  DWORD bytes_written = 0;
  HANDLE pipe = AsHandle(connection->pipe_handle);
  if (!WriteFile(pipe, packet.data(), static_cast<DWORD>(packet.size()),
                 &bytes_written, nullptr)) {
    *error_message = "Failed to write RPC packet.";
    return false;
  }

  if (packet_type == 2) {
    CloseHandle(pipe);
  }

  return true;
}

bool IslandDesktopPresencePlugin::CloseRpcConnection(
    const std::string& connection_id,
    std::string* error_message) {
  std::shared_ptr<RpcConnection> connection;
  {
    std::lock_guard<std::mutex> lock(rpc_mutex_);
    const auto it = rpc_connections_.find(connection_id);
    if (it == rpc_connections_.end()) {
      *error_message = "Unknown RPC connection.";
      return false;
    }
    connection = it->second;
  }

  HANDLE pipe = AsHandle(connection->pipe_handle);
  CloseHandle(pipe);
  return true;
}

void IslandDesktopPresencePlugin::AcceptRpcConnections() {
  while (rpc_running_) {
    HANDLE pipe = CreateNamedPipeA(
        kRpcPipeName,
        PIPE_ACCESS_DUPLEX,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
        PIPE_UNLIMITED_INSTANCES,
        64 * 1024,
        64 * 1024,
        0,
        nullptr);

    if (pipe == INVALID_HANDLE_VALUE) {
      EmitRpcError("Failed to create Discord IPC named pipe.");
      return;
    }

    {
      std::lock_guard<std::mutex> lock(rpc_mutex_);
      rpc_listener_pipe_ = AsVoidPtr(pipe);
    }

    const BOOL connected =
        ConnectNamedPipe(pipe, nullptr)
            ? TRUE
            : (GetLastError() == ERROR_PIPE_CONNECTED);

    {
      std::lock_guard<std::mutex> lock(rpc_mutex_);
      rpc_listener_pipe_ = nullptr;
    }

    if (!rpc_running_) {
      CloseHandle(pipe);
      return;
    }

    if (!connected) {
      CloseHandle(pipe);
      continue;
    }

    const std::string connection_id = std::to_string(next_rpc_connection_id_++);
    auto connection = std::make_shared<RpcConnection>();
    connection->connection_id = connection_id;
    connection->pipe_handle = AsVoidPtr(pipe);

    {
      std::lock_guard<std::mutex> lock(rpc_mutex_);
      rpc_connections_[connection_id] = connection;
    }

    EmitRpcConnected(connection_id);
    std::thread([this, connection]() { ReadRpcConnection(connection); }).detach();
  }
}

void IslandDesktopPresencePlugin::ReadRpcConnection(
    std::shared_ptr<RpcConnection> connection) {
  HANDLE pipe = AsHandle(connection->pipe_handle);
  std::vector<uint8_t> read_buffer(kRpcReadBufferSize);

  while (rpc_running_) {
    DWORD bytes_read = 0;
    const BOOL success = ReadFile(pipe, read_buffer.data(),
                                  static_cast<DWORD>(read_buffer.size()),
                                  &bytes_read, nullptr);
    if (!success || bytes_read == 0) {
      break;
    }

    connection->buffer.insert(connection->buffer.end(), read_buffer.begin(),
                              read_buffer.begin() + bytes_read);

    while (connection->buffer.size() >= 8) {
      int32_t packet_type = 0;
      int32_t payload_size = 0;
      std::memcpy(&packet_type, connection->buffer.data(), sizeof(int32_t));
      std::memcpy(&payload_size, connection->buffer.data() + 4,
                  sizeof(int32_t));

      if (payload_size < 0 ||
          connection->buffer.size() < static_cast<size_t>(8 + payload_size)) {
        break;
      }

      const std::string payload(
          connection->buffer.begin() + 8,
          connection->buffer.begin() + 8 + payload_size);
      connection->buffer.erase(connection->buffer.begin(),
                               connection->buffer.begin() + 8 + payload_size);
      EmitRpcPacket(connection->connection_id, packet_type, payload);
    }
  }

  {
    std::lock_guard<std::mutex> lock(rpc_mutex_);
    rpc_connections_.erase(connection->connection_id);
  }
  CloseHandle(pipe);
  EmitRpcClosed(connection->connection_id);
}

void IslandDesktopPresencePlugin::EmitRpcConnected(
    const std::string& connection_id) {
  QueueRpcEvent(flutter::EncodableMap{
      {flutter::EncodableValue("event"),
       flutter::EncodableValue(std::string("connected"))},
      {flutter::EncodableValue("connection_id"),
       flutter::EncodableValue(connection_id)},
  });
}

void IslandDesktopPresencePlugin::EmitRpcPacket(const std::string& connection_id,
                                                int32_t packet_type,
                                                const std::string& data_json) {
  QueueRpcEvent(flutter::EncodableMap{
      {flutter::EncodableValue("event"),
       flutter::EncodableValue(std::string("packet"))},
      {flutter::EncodableValue("connection_id"),
       flutter::EncodableValue(connection_id)},
      {flutter::EncodableValue("packet_type"),
       flutter::EncodableValue(packet_type)},
      {flutter::EncodableValue("data_json"),
       flutter::EncodableValue(data_json)},
  });
}

void IslandDesktopPresencePlugin::EmitRpcClosed(
    const std::string& connection_id) {
  QueueRpcEvent(flutter::EncodableMap{
      {flutter::EncodableValue("event"),
       flutter::EncodableValue(std::string("closed"))},
      {flutter::EncodableValue("connection_id"),
       flutter::EncodableValue(connection_id)},
  });
}

void IslandDesktopPresencePlugin::EmitRpcError(const std::string& message) {
  QueueRpcEvent(flutter::EncodableMap{
      {flutter::EncodableValue("event"),
       flutter::EncodableValue(std::string("error"))},
      {flutter::EncodableValue("message"),
       flutter::EncodableValue(message)},
  });
}

void IslandDesktopPresencePlugin::QueueRpcEvent(flutter::EncodableMap event) {
  if (rpc_event_sink_ != nullptr) {
    rpc_event_sink_->Success(flutter::EncodableValue(event));
  } else {
    pending_rpc_events_.push_back(std::move(event));
  }
}

std::vector<uint8_t> IslandDesktopPresencePlugin::EncodeRpcPacket(
    int32_t packet_type,
    const std::string& data_json) {
  std::vector<uint8_t> packet(8 + data_json.size());
  std::memcpy(packet.data(), &packet_type, sizeof(int32_t));
  const int32_t payload_size = static_cast<int32_t>(data_json.size());
  std::memcpy(packet.data() + 4, &payload_size, sizeof(int32_t));
  std::memcpy(packet.data() + 8, data_json.data(), data_json.size());
  return packet;
}

}  // namespace island_desktop_presence
