rm -rf Solian.AppDir
mkdir Solian.AppDir

cmake -B build_qjs -S third_party/quickjs_c_bridge/linux/ -DCMAKE_BUILD_TYPE=Release
cmake --build build_qjs
cp build_qjs/libquickjs_c_bridge_plugin.so build/linux/x64/release/bundle/lib/

cp -r build/linux/x64/release/bundle/* Solian.AppDir
cp -r buildtools/appimage_config/* Solian.AppDir
cp buildtools/icon-padded.png Solian.AppDir
sudo chmod +x buildtools/appimagetool-x86_64.AppImage
sudo chmod +x Solian.AppDir/AppRun
./buildtools/appimagetool-x86_64.AppImage Solian.AppDir
