#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  bluetooth_low_energy_windows
  connectivity_plus
  dart_ipc
  desktop_drop
  file_saver
  file_selector_windows
  firebase_core
  flutter_blue_plus_winrt
  flutter_inappwebview_windows
  flutter_secure_storage_windows
  flutter_timezone
  flutter_udid
  flutter_webrtc
  gal
  geolocator_windows
  hotkey_manager_windows
  irondash_engine_context
  livekit_client
  local_auth_windows
  media_kit_libs_windows_video
  media_kit_video
  objectbox_flutter_libs
  pasteboard
  permission_handler_windows
  protocol_handler_windows
  record_windows
  screen_retriever_windows
  share_plus
  super_native_extensions
  syncfusion_pdfviewer_windows
  tray_manager
  url_launcher_windows
  webcrypto
  window_manager
  windows_notification
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  croppy
  flutter_local_notifications_windows
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/windows plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
