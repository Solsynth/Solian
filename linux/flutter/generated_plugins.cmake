#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  bluetooth_low_energy_linux
  desktop_drop
  file_saver
  file_selector_linux
  flutter_secure_storage_linux
  flutter_timezone
  flutter_webrtc
  hotkey_manager_linux
  irondash_engine_context
  livekit_client
  media_kit_libs_linux
  media_kit_video
  objectbox_flutter_libs
  pasteboard
  record_linux
  screen_retriever_linux
  super_native_extensions
  syncfusion_pdfviewer_linux
  tray_manager
  url_launcher_linux
  webcrypto
  window_manager
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
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
