#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  bluetooth_low_energy_linux
  desktop_drop
  desktop_multi_window
  disk_space_2
  file_saver
  file_selector_linux
  flutter_js
  flutter_secure_storage_linux
  flutter_timezone
  flutter_webrtc
  irondash_engine_context
  island_desktop_presence
  livekit_client
  media_kit_libs_linux
  media_kit_video
  objectbox_flutter_libs
  open_file_linux
  pasteboard
  record_linux
  screen_retriever_linux
  sentry_flutter
  super_native_extensions
  tray_manager
  url_launcher_linux
  window_manager
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  jni
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/linux plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/linux plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
