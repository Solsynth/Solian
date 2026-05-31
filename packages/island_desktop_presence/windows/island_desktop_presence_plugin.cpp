#include "island_desktop_presence_plugin.h"

#include <windows.h>

#include <flutter/standard_method_codec.h>

#include <chrono>
#include <cstring>
#include <memory>
#include <sstream>
#include <string>
#include <thread>

#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Media.Control.h>
#include <winrt/Windows.Security.Cryptography.h>
#include <winrt/Windows.Security.Cryptography.Core.h>
#include <winrt/Windows.Storage.Streams.h>
#include <winrt/Windows.Web.Http.h>
#include <winrt/Windows.Web.Http.Headers.h>

using namespace winrt;
using namespace winrt::Windows::Foundation;
using namespace winrt::Windows::Media::Control;
using namespace winrt::Windows::Security::Cryptography;
using namespace winrt::Windows::Storage::Streams;
using namespace winrt::Windows::Web::Http;
using namespace winrt::Windows::Web::Http::Headers;

namespace {
constexpr char kMethodChannelName[] = "island_desktop_presence";
constexpr char kPresenceEventChannelName[] = "island_desktop_presence/events";
constexpr char kExternalNowPlayingEventChannelName[] =
    "island_desktop_presence/external_now_playing";
constexpr char kRpcEventChannelName[] = "island_desktop_presence/rpc_events";
constexpr char kRpcPipeName[] = R"(\\.\pipe\discord-ipc-0)";
constexpr UINT_PTR kPollingTimerId = 1;
constexpr UINT kPollingIntervalMilliseconds = 3000;
constexpr int kExternalNowPlayingDefaultPollIntervalMilliseconds = 2000;
constexpr size_t kRpcReadBufferSize = 4096;

std::string ToHex(const uint8_t* data, size_t length) {
  static constexpr char kHexChars[] = "0123456789abcdef";
  std::string result;
  result.reserve(length * 2);
  for (size_t i = 0; i < length; ++i) {
    result.push_back(kHexChars[(data[i] >> 4) & 0x0f]);
    result.push_back(kHexChars[data[i] & 0x0f]);
  }
  return result;
}

bool StartsWith(const std::string& str, const std::string& prefix) {
  return str.size() >= prefix.size() &&
         str.compare(0, prefix.size(), prefix) == 0;
}
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

  auto external_now_playing_event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kExternalNowPlayingEventChannelName,
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

  external_now_playing_event_channel->SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [plugin_pointer = plugin.get()](
              const auto* arguments,
              std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                  events) {
            return plugin_pointer->OnExternalNowPlayingListen(
                arguments, std::move(events));
          },
          [plugin_pointer = plugin.get()](const auto* arguments) {
            return plugin_pointer->OnExternalNowPlayingCancel(arguments);
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
  StopExternalNowPlayingMonitoring();
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

  if (method_call.method_name() == "startExternalNowPlayingMonitoring") {
    const auto* arguments_value = method_call.arguments();
    if (arguments_value == nullptr) {
      result->Error("invalid_arguments",
                    "Expected startExternalNowPlayingMonitoring arguments.");
      return;
    }

    const auto* arguments = std::get_if<flutter::EncodableMap>(arguments_value);
    if (arguments == nullptr) {
      result->Error("invalid_arguments",
                    "Expected startExternalNowPlayingMonitoring arguments.");
      return;
    }

    int poll_interval_milliseconds =
        kExternalNowPlayingDefaultPollIntervalMilliseconds;
    const auto poll_interval_iterator =
        arguments->find(flutter::EncodableValue("pollIntervalMilliseconds"));
    if (poll_interval_iterator != arguments->end()) {
      const auto* poll_interval =
          std::get_if<int32_t>(&poll_interval_iterator->second);
      if (poll_interval == nullptr || *poll_interval <= 0) {
        result->Error("invalid_arguments",
                      "pollIntervalMilliseconds must be a positive int.");
        return;
      }
      poll_interval_milliseconds = *poll_interval;
    }

    StartExternalNowPlayingMonitoring(poll_interval_milliseconds);
    EmitCurrentExternalNowPlaying(true);
    result->Success();
    return;
  }

  if (method_call.method_name() == "stopExternalNowPlayingMonitoring") {
    StopExternalNowPlayingMonitoring();
    result->Success();
    return;
  }

  if (method_call.method_name() == "setAuthToken") {
    const auto* arguments_value = method_call.arguments();
    if (arguments_value != nullptr) {
      const auto* arguments =
          std::get_if<flutter::EncodableMap>(arguments_value);
      if (arguments != nullptr) {
        const auto token_it =
            arguments->find(flutter::EncodableValue("token"));
        if (token_it != arguments->end()) {
          const auto* token = std::get_if<std::string>(&token_it->second);
          if (token != nullptr) {
            auth_token_ = *token;
          } else {
            auth_token_.clear();
          }
        } else {
          auth_token_.clear();
        }
        const auto url_it =
            arguments->find(flutter::EncodableValue("serverURL"));
        if (url_it != arguments->end()) {
          const auto* url = std::get_if<std::string>(&url_it->second);
          if (url != nullptr) {
            server_url_ = *url;
          } else {
            server_url_.clear();
          }
        } else {
          server_url_.clear();
        }
      } else {
        auth_token_.clear();
        server_url_.clear();
      }
    } else {
      auth_token_.clear();
      server_url_.clear();
    }
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
IslandDesktopPresencePlugin::OnExternalNowPlayingListen(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  (void)arguments;
  external_now_playing_event_sink_ = std::move(events);
  if (pending_external_now_playing_event_.has_value()) {
    external_now_playing_event_sink_->Success(
        flutter::EncodableValue(*pending_external_now_playing_event_));
    pending_external_now_playing_event_.reset();
  }
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
IslandDesktopPresencePlugin::OnExternalNowPlayingCancel(
    const flutter::EncodableValue* arguments) {
  (void)arguments;
  external_now_playing_event_sink_.reset();
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

void IslandDesktopPresencePlugin::StartExternalNowPlayingMonitoring(
    int poll_interval_milliseconds) {
  StopExternalNowPlayingMonitoring(false);
  external_now_playing_poll_interval_milliseconds_ = poll_interval_milliseconds;
  external_now_playing_running_ = true;
  external_now_playing_thread_ = std::thread([this]() {
    winrt::init_apartment(winrt::apartment_type::multi_threaded);
    while (external_now_playing_running_) {
      EmitCurrentExternalNowPlaying(false);
      std::unique_lock<std::mutex> lock(external_now_playing_mutex_);
      external_now_playing_cv_.wait_for(
          lock,
          std::chrono::milliseconds(
              external_now_playing_poll_interval_milliseconds_),
          [this]() { return !external_now_playing_running_.load(); });
    }
  });
}

void IslandDesktopPresencePlugin::StopExternalNowPlayingMonitoring(
    bool reset_state) {
  if (!external_now_playing_running_) {
    if (reset_state) {
      last_emitted_external_now_playing_.reset();
      pending_external_now_playing_event_.reset();
    }
    return;
  }

  external_now_playing_running_ = false;
  external_now_playing_cv_.notify_all();
  if (external_now_playing_thread_.joinable()) {
    external_now_playing_thread_.join();
  }

  if (reset_state) {
    last_emitted_external_now_playing_.reset();
    pending_external_now_playing_event_.reset();
  }
}

void IslandDesktopPresencePlugin::EmitCurrentExternalNowPlaying(bool force) {
  auto snapshot = ReadExternalNowPlayingSnapshot();
  if (!snapshot.has_value()) {
    return;
  }

  snapshot = EnsureArtworkUploaded(*snapshot);

  if (!force && last_emitted_external_now_playing_.has_value() &&
      last_emitted_external_now_playing_->title == snapshot->title &&
      last_emitted_external_now_playing_->artist == snapshot->artist &&
      last_emitted_external_now_playing_->album == snapshot->album &&
      last_emitted_external_now_playing_->state == snapshot->state &&
      last_emitted_external_now_playing_->artwork_hash ==
          snapshot->artwork_hash) {
    return;
  }

  last_emitted_external_now_playing_ = snapshot;
  const auto event = BuildExternalNowPlayingEvent(*snapshot);
  if (external_now_playing_event_sink_ != nullptr) {
    external_now_playing_event_sink_->Success(flutter::EncodableValue(event));
  } else {
    pending_external_now_playing_event_ = event;
  }
}

std::optional<IslandDesktopPresencePlugin::ExternalNowPlayingSnapshot>
IslandDesktopPresencePlugin::ReadExternalNowPlayingSnapshot() const {
  try {
    auto manager =
        GlobalSystemMediaTransportControlsSessionManager::RequestAsync().get();
    auto session = manager.GetCurrentSession();
    if (!session) {
      return std::nullopt;
    }

    auto properties = session.TryGetMediaPropertiesAsync().get();
    auto playback = session.GetPlaybackInfo();
    auto timeline = session.GetTimelineProperties();

    const auto title = ToUtf8(properties.Title());
    if (title.empty()) {
      return std::nullopt;
    }

    ExternalNowPlayingSnapshot snapshot;

    const auto app_id = NormalizeSourceAppId(session.SourceAppUserModelId());
    snapshot.source = "other";
    snapshot.source_app_name = ResolveApplicationName(app_id);
    snapshot.source_bundle_identifier = MapSourceBundleIdentifier(app_id);
    snapshot.provider_key = MapProviderKey(app_id);
    snapshot.unique_identifier = app_id;

    const auto playback_status = playback.PlaybackStatus();
    snapshot.state =
        playback_status ==
                GlobalSystemMediaTransportControlsSessionPlaybackStatus::Playing
            ? "playing"
            : playback_status ==
                      GlobalSystemMediaTransportControlsSessionPlaybackStatus::
                          Paused
                  ? "paused"
                  : "stopped";

    const auto playback_rate = playback.PlaybackRate();
    if (playback_rate != nullptr) {
      snapshot.playback_rate = playback_rate.GetDouble();
    }

    snapshot.title = title;

    const auto artist = ToUtf8(properties.Artist());
    if (!artist.empty()) {
      snapshot.artist = artist;
    }

    const auto album = ToUtf8(properties.AlbumTitle());
    if (!album.empty()) {
      snapshot.album = album;
    }

    const auto duration = timeline.EndTime().count();
    if (duration > 0) {
      snapshot.duration_seconds = static_cast<double>(duration) / 10'000'000.0;
    }

    const auto position = timeline.Position().count();
    if (position >= 0) {
      snapshot.position_seconds = static_cast<double>(position) / 10'000'000.0;
    }

    // Extract thumbnail artwork.
    auto thumbnail = properties.Thumbnail();
    if (thumbnail != nullptr) {
      auto stream = thumbnail.OpenReadAsync().get();
      if (stream != nullptr) {
        auto image_bytes = ReadStreamBytes(stream);
        if (image_bytes.has_value() && !image_bytes->empty()) {
          auto hash = ComputeArtworkHash(*image_bytes);
          if (hash.has_value()) {
            snapshot.artwork_hash = "sha256:" + *hash;
            snapshot.artwork_data = BytesToBase64(*image_bytes);
          }
        }
      }
    }

    return snapshot;
  } catch (...) {
    return std::nullopt;
  }
}

IslandDesktopPresencePlugin::ExternalNowPlayingSnapshot
IslandDesktopPresencePlugin::EnsureArtworkUploaded(
    const ExternalNowPlayingSnapshot& snapshot) const {
  if (!snapshot.artwork_hash.has_value() || auth_token_.empty()) {
    return snapshot;
  }

  {
    std::lock_guard<std::mutex> lock(artwork_cache_mutex_);
    if (artwork_hash_cache_.count(*snapshot.artwork_hash) > 0) {
      return snapshot;
    }
  }

  if (CheckArtworkExists(*snapshot.artwork_hash)) {
    std::lock_guard<std::mutex> lock(artwork_cache_mutex_);
    artwork_hash_cache_.insert(*snapshot.artwork_hash);
    return snapshot;
  }

  if (snapshot.artwork_data.has_value() &&
      UploadArtwork(*snapshot.artwork_data, *snapshot.artwork_hash)) {
    std::lock_guard<std::mutex> lock(artwork_cache_mutex_);
    artwork_hash_cache_.insert(*snapshot.artwork_hash);
  }

  return snapshot;
}

bool IslandDesktopPresencePlugin::CheckArtworkExists(
    const std::string& hash) const {
  if (server_url_.empty() || auth_token_.empty()) {
    return false;
  }

  try {
    HttpClient client;
    auto uri = Uri(
        winrt::to_hstring(server_url_ + "/passport/presence/artworks/" + hash));
    HttpRequestMessage request(HttpMethod::Get(), uri);
    request.Headers().Authorization(
        HttpCredentialsHeaderValue(L"Bearer", winrt::to_hstring(auth_token_)));
    auto response = client.SendRequestAsync(request).get();
    return response.StatusCode() == HttpStatusCode::Ok;
  } catch (...) {
    return false;
  }
}

bool IslandDesktopPresencePlugin::UploadArtwork(
    const std::string& artwork_data,
    const std::string& hash) const {
  if (server_url_.empty() || auth_token_.empty()) {
    return false;
  }

  try {
    auto image_buffer = CryptographyBuffer::DecodeFromBase64String(
        winrt::to_hstring(artwork_data));

    HttpClient client;
    auto uri =
        Uri(winrt::to_hstring(server_url_ + "/passport/presence/artworks"));

    HttpMultipartFormDataContent form;
    form.Add(HttpBufferContent(image_buffer), L"file", L"now-playing.png");

    HttpRequestMessage request(HttpMethod::Post(), uri);
    request.Headers().Authorization(
        HttpCredentialsHeaderValue(L"Bearer", winrt::to_hstring(auth_token_)));
    request.Content(form);
    auto response = client.SendRequestAsync(request).get();
    auto status = static_cast<int>(response.StatusCode());
    return status >= 200 && status < 300;
  } catch (...) {
    return false;
  }
}

std::optional<std::string> IslandDesktopPresencePlugin::ComputeArtworkHash(
    const std::vector<uint8_t>& image_bytes) {
  try {
    auto algorithm = Cryptography::Core::HashAlgorithmProvider::OpenAlgorithm(
        Cryptography::Core::HashAlgorithmNames::Sha256());
    auto buffer = CryptographyBuffer::CreateFromByteArray(image_bytes);
    auto hash_buffer = algorithm.HashData(buffer);
    auto hash_bytes = CryptographyBuffer::CopyToByteArray(hash_buffer);
    return ToHex(hash_bytes.data(), hash_bytes.size());
  } catch (...) {
    return std::nullopt;
  }
}

std::optional<std::vector<uint8_t>>
IslandDesktopPresencePlugin::ReadStreamBytes(
    const IRandomAccessStream& stream) {
  try {
    auto size = static_cast<uint32_t>(stream.Size());
    if (size == 0) {
      return std::nullopt;
    }
    DataReader reader(stream);
    reader.LoadAsync(size).get();
    std::vector<uint8_t> bytes(size);
    reader.ReadBytes(bytes);
    return bytes;
  } catch (...) {
    return std::nullopt;
  }
}

std::string IslandDesktopPresencePlugin::BytesToBase64(
    const std::vector<uint8_t>& bytes) {
  auto buffer = CryptographyBuffer::CreateFromByteArray(bytes);
  return winrt::to_string(CryptographyBuffer::EncodeToBase64String(buffer));
}

std::string IslandDesktopPresencePlugin::ToUtf8(const winrt::hstring& value) {
  return winrt::to_string(value);
}

std::string IslandDesktopPresencePlugin::NormalizeSourceAppId(
    const winrt::hstring& value) {
  return ToUtf8(value);
}

std::string IslandDesktopPresencePlugin::MapSourceBundleIdentifier(
    const std::string& app_id) {
  if (app_id.find("Spotify") != std::string::npos) {
    return "com.spotify.client";
  }
  if (app_id.find("AppleMusic") != std::string::npos ||
      app_id.find("Apple Music") != std::string::npos) {
    return "com.apple.Music";
  }
  return app_id;
}

std::string IslandDesktopPresencePlugin::MapProviderKey(
    const std::string& app_id) {
  if (app_id.find("Spotify") != std::string::npos) {
    return "spotify";
  }
  if (app_id.find("AppleMusic") != std::string::npos ||
      app_id.find("Apple Music") != std::string::npos) {
    return "apple_music";
  }
  return app_id;
}

std::string IslandDesktopPresencePlugin::ResolveApplicationName(
    const std::string& app_id) {
  if (app_id.find("Spotify") != std::string::npos) {
    return "Spotify";
  }
  if (app_id.find("AppleMusic") != std::string::npos ||
      app_id.find("Apple Music") != std::string::npos) {
    return "Apple Music";
  }
  return app_id;
}

flutter::EncodableMap IslandDesktopPresencePlugin::BuildExternalNowPlayingEvent(
    const ExternalNowPlayingSnapshot& snapshot) const {
  flutter::EncodableMap event{
      {flutter::EncodableValue("source"), flutter::EncodableValue(snapshot.source)},
      {flutter::EncodableValue("state"), flutter::EncodableValue(snapshot.state)},
  };

  if (snapshot.provider_key.has_value()) {
    event[flutter::EncodableValue("provider_key")] =
        flutter::EncodableValue(*snapshot.provider_key);
  }
  if (snapshot.provider_reference_id.has_value()) {
    event[flutter::EncodableValue("provider_reference_id")] =
        flutter::EncodableValue(*snapshot.provider_reference_id);
  }
  if (snapshot.source_app_name.has_value()) {
    event[flutter::EncodableValue("source_app_name")] =
        flutter::EncodableValue(*snapshot.source_app_name);
  }
  if (snapshot.source_bundle_identifier.has_value()) {
    event[flutter::EncodableValue("source_bundle_identifier")] =
        flutter::EncodableValue(*snapshot.source_bundle_identifier);
  }
  if (snapshot.unique_identifier.has_value()) {
    event[flutter::EncodableValue("unique_identifier")] =
        flutter::EncodableValue(*snapshot.unique_identifier);
  }
  if (snapshot.title.has_value()) {
    event[flutter::EncodableValue("title")] =
        flutter::EncodableValue(*snapshot.title);
  }
  if (snapshot.artist.has_value()) {
    event[flutter::EncodableValue("artist")] =
        flutter::EncodableValue(*snapshot.artist);
  }
  if (snapshot.album.has_value()) {
    event[flutter::EncodableValue("album")] =
        flutter::EncodableValue(*snapshot.album);
  }
  if (snapshot.playback_rate.has_value()) {
    event[flutter::EncodableValue("playback_rate")] =
        flutter::EncodableValue(*snapshot.playback_rate);
  }
  if (snapshot.duration_seconds.has_value()) {
    event[flutter::EncodableValue("duration_seconds")] =
        flutter::EncodableValue(*snapshot.duration_seconds);
  }
  if (snapshot.position_seconds.has_value()) {
    event[flutter::EncodableValue("position_seconds")] =
        flutter::EncodableValue(*snapshot.position_seconds);
  }
  if (snapshot.title_url.has_value()) {
    event[flutter::EncodableValue("title_url")] =
        flutter::EncodableValue(*snapshot.title_url);
  }
  if (snapshot.subtitle_url.has_value()) {
    event[flutter::EncodableValue("subtitle_url")] =
        flutter::EncodableValue(*snapshot.subtitle_url);
  }
  if (snapshot.artwork_url.has_value()) {
    event[flutter::EncodableValue("artwork_url")] =
        flutter::EncodableValue(*snapshot.artwork_url);
  }
  if (snapshot.artwork_url_large.has_value()) {
    event[flutter::EncodableValue("artwork_url_large")] =
        flutter::EncodableValue(*snapshot.artwork_url_large);
  }
  if (snapshot.artwork_hash.has_value()) {
    event[flutter::EncodableValue("artwork_hash")] =
        flutter::EncodableValue(*snapshot.artwork_hash);
  }
  if (snapshot.artwork_data.has_value()) {
    event[flutter::EncodableValue("artwork_data")] =
        flutter::EncodableValue(*snapshot.artwork_data);
  }
  if (snapshot.catalog_id.has_value()) {
    event[flutter::EncodableValue("catalog_id")] =
        flutter::EncodableValue(*snapshot.catalog_id);
  }

  return event;
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
