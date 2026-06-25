#include <windows.h>

#ifndef FLUTTER_PLUGIN_PROTOCOL_HANDLER_WINDOWS_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_PROTOCOL_HANDLER_WINDOWS_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void
ProtocolHandlerWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#define PROTOCOL_MSG_ID (WM_USER + 2)
FLUTTER_PLUGIN_EXPORT void DispatchToProtocolHandler(HWND hwnd);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_PROTOCOL_HANDLER_WINDOWS_PLUGIN_C_API_H_
