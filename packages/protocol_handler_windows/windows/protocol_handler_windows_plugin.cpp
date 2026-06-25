#include "include/protocol_handler_windows/protocol_handler_windows_plugin_c_api.h"
#include "protocol_handler_windows_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

namespace protocol_handler_windows {

void ProtocolHandlerWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dev.leanflutter.plugins/protocol_handler",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ProtocolHandlerWindowsPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(),
          "dev.leanflutter.plugins/protocol_handler_event",
          &flutter::StandardMethodCodec::GetInstance());
  auto streamHandler = std::make_unique<flutter::StreamHandlerFunctions<>>(
      [plugin_pointer = plugin.get()](
          const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<>>&& events)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnCancel(arguments);
      });
  event_channel->SetStreamHandler(std::move(streamHandler));

  registrar->AddPlugin(std::move(plugin));
}

ProtocolHandlerWindowsPlugin::ProtocolHandlerWindowsPlugin(
    flutter::PluginRegistrarWindows* registrar) {
  window_proc_id_ = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
}

ProtocolHandlerWindowsPlugin::~ProtocolHandlerWindowsPlugin() {}

std::optional<LRESULT> ProtocolHandlerWindowsPlugin::HandleWindowProc(
    HWND hwnd,
    UINT message,
    WPARAM wparam,
    LPARAM lparam) {
  switch (message) {
    case WM_COPYDATA:
      COPYDATASTRUCT* cds = {0};
      cds = (COPYDATASTRUCT*)lparam;

      if (cds->dwData == PROTOCOL_MSG_ID) {
        std::string url((char*)((LPCWSTR)cds->lpData));

        flutter::EncodableMap args = flutter::EncodableMap();
        args[flutter::EncodableValue("url")] =
            flutter::EncodableValue(url.c_str());
        if (event_sink_) {
          event_sink_->Success(flutter::EncodableValue(url.c_str()));
        }
      }
      break;
  }
  return std::nullopt;
}

std::string ProtocolHandlerWindowsPlugin::GetInitialUrl() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr || argc < 2) {
    return "";
  }

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  std::string url = converter.to_bytes(argv[1]);
  ::LocalFree(argv);
  return url;
}

void ProtocolHandlerWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getInitialUrl") == 0) {
    std::string value = GetInitialUrl();
    result->Success(flutter::EncodableValue(value.c_str()));
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
ProtocolHandlerWindowsPlugin::OnListenInternal(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  event_sink_ = std::move(events);
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
ProtocolHandlerWindowsPlugin::OnCancelInternal(
    const flutter::EncodableValue* arguments) {
  event_sink_ = nullptr;
  return nullptr;
}

}  // namespace protocol_handler_windows
