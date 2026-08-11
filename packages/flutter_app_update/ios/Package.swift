// swift-tools-version: 5.9
// Aligned with flutter_app_update.podspec:
//   name: flutter_app_update, source_files: Classes/**/*, defines_module: YES
import PackageDescription

let package = Package(
    name: "flutter_app_update",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "flutter_app_update", targets: ["flutter_app_update"])
    ],
    dependencies: [
        // Flutter dependency is provided by the Flutter build system (equivalent to s.dependency 'Flutter' in podspec)
    ],
    targets: [
        .target(
            name: "flutter_app_update",
            path: ".",
            exclude: ["Assets", "flutter_app_update", "flutter_app_update.podspec", ".gitignore"],
            sources: ["Classes/"],
            publicHeadersPath: "Classes",
            cSettings: [
                .headerSearchPath("Classes")
            ]
        )
    ]
)
