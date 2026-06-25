#include "include/protocol_handler_windows/protocol_handler_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "protocol_handler_windows_plugin.h"

#include <codecvt>

void ProtocolHandlerWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  protocol_handler_windows::ProtocolHandlerWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

void DispatchToProtocolHandler(HWND hwnd) {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr || argc < 2) {
    return;
  }

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  std::string url = converter.to_bytes(argv[1]);
  ::LocalFree(argv);

  COPYDATASTRUCT cds = {0};
  cds.dwData = PROTOCOL_MSG_ID;
  cds.cbData = (DWORD)(strlen(url.c_str()) + 1);
  cds.lpData = (PVOID)url.c_str();

  SendMessage(hwnd, WM_COPYDATA, 0, (LPARAM)&cds);
}
