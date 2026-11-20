import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: lets reminders show while the app is open.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Keyboard languages for the language sheet (DeviceLanguagesService).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DeviceLanguages") {
      FlutterMethodChannel(
        name: "deutschlernen/device_languages",
        binaryMessenger: registrar.messenger()
      ).setMethodCallHandler { call, result in
        guard call.method == "keyboardLanguages" else {
          return result(FlutterMethodNotImplemented)
        }
        // Enabled keyboards in the user's order: "uk-UA", "emoji", ...
        result(UITextInputMode.activeInputModes.compactMap { $0.primaryLanguage })
      }
    }
  }
}
