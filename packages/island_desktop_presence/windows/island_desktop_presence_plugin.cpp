#include "island_desktop_presence_plugin.h"

#include <windows.h>

#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

namespace {
constexpr char kMethodChannelName[] = "island_desktop_presence";
constexpr char kEventChannelName[] = "island_desktop_presence/events";
constexpr UINT_PTR kPollingTimerId = 1;
constexpr UINT kPollingIntervalMilliseconds = 3000;
}  // namespace

namespace island_desktop_presence {

void IslandDesktopPresencePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto method_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kMethodChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kEventChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<IslandDesktopPresencePlugin>(registrar);

  method_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  event_channel->SetStreamHandler(std::make_unique<
                                  flutter::StreamHandlerFunctions<
                                      flutter::EncodableValue>>(
      [plugin_pointer = plugin.get()](
          const auto* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
              events) {
        return plugin_pointer->OnListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const auto* arguments) {
        return plugin_pointer->OnCancel(arguments);
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

    const auto* threshold =
        std::get_if<int32_t>(&threshold_iterator->second);
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
IslandDesktopPresencePlugin::OnListen(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  event_sink_ = std::move(events);
  if (pending_event_.has_value()) {
    event_sink_->Success(flutter::EncodableValue(*pending_event_));
    pending_event_.reset();
  }
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
IslandDesktopPresencePlugin::OnCancel(const flutter::EncodableValue* arguments) {
  event_sink_.reset();
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
    pending_event_.reset();
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
  flutter::EncodableMap event = BuildEvent(state, *idle_milliseconds);
  if (event_sink_ != nullptr) {
    event_sink_->Success(flutter::EncodableValue(event));
  } else {
    pending_event_ = std::move(event);
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

flutter::EncodableMap IslandDesktopPresencePlugin::BuildEvent(
    PresenceState state,
    int64_t idle_milliseconds) const {
  const char* state_name =
      state == PresenceState::kIdle ? "idle" : "active";
  return flutter::EncodableMap{
      {flutter::EncodableValue("state"),
       flutter::EncodableValue(std::string(state_name))},
      {flutter::EncodableValue("idle_seconds"),
       flutter::EncodableValue(static_cast<int32_t>(idle_milliseconds / 1000))},
  };
}

}  // namespace island_desktop_presence
