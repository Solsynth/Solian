#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  bluetooth_low_energy_windows
  connectivity_plus
  desktop_drop
  desktop_multi_window
  disk_space_2
  file_saver
  file_selector_windows
  firebase_core
  flutter_blue_plus_winrt
  flutter_inappwebview_windows
  flutter_js
  flutter_secure_storage_windows
  flutter_timezone
  flutter_tts
  flutter_webrtc
  gal
  geolocator_windows
  irondash_engine_context
  island_desktop_presence
  livekit_client
  local_auth_windows
  media_kit_libs_windows_video
  media_kit_video
  objectbox_flutter_libs
  passkeys_windows
  pasteboard
  permission_handler_windows
  protocol_handler_windows
  record_windows
  screen_retriever_windows
  sentry_flutter
  share_plus
  super_native_extensions
  tray_manager
  url_launcher_windows
  window_manager
  windows_notification
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  flutter_local_notifications_windows
  jni
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
