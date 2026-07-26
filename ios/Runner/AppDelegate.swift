import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Mappa alias condiviso (Android/Dart) -> nome set icona nel catalogo iOS.
  private let iconMap: [String: String?] = [
    "IconDefault": nil,            // AppIcon primaria (Ulisse)
    "IconZeus": "AltZeus",
    "IconCyberpunk": "AltCyberpunk",
    "IconSpartacus": "AltSpartacus",
    "IconKratos": "AltKratos",
  ]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "AppIconChannel")?.messenger()
    if let messenger = messenger {
      let channel = FlutterMethodChannel(name: "calistrack/app_icon", binaryMessenger: messenger)
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "setIcon" else { result(FlutterMethodNotImplemented); return }
        guard
          let args = call.arguments as? [String: Any],
          let alias = args["alias"] as? String,
          let entry = self?.iconMap[alias]
        else {
          result(FlutterError(code: "BAD_ARG", message: "Alias non valido", details: nil))
          return
        }
        guard UIApplication.shared.supportsAlternateIcons else {
          result(false); return
        }
        UIApplication.shared.setAlternateIconName(entry) { error in
          result(error == nil)
        }
      }
    }
  }
}
