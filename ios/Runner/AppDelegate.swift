import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let pluginRegistrar = self.registrar(forPlugin: "plugin-name") else { return false }
        
        pluginRegistrar.register(FLNativeImageFactory(messenger: pluginRegistrar.messenger()), withId: "native-image")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
