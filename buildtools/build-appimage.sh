rm -rf Solian.AppDir
mkdir Solian.AppDir
cp linux/flutter/ephemeral/.plugin_symlinks/flutter_js/linux/shared/libquickjs_c_bridge_plugin.so build/linux/x64/release/bundle/lib/
cp -r build/linux/x64/release/bundle/* Solian.AppDir
cp -r buildtools/appimage_config/* Solian.AppDir
cp buildtools/icon-padded.png Solian.AppDir
sudo chmod +x buildtools/appimagetool-x86_64.AppImage
sudo chmod +x Solian.AppDir/AppRun
./buildtools/appimagetool-x86_64.AppImage Solian.AppDir
