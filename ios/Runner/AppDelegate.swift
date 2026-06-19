import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let arHandler = ArPlatformHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let messenger = controller.binaryMessenger
      let methodChannel = FlutterMethodChannel(
        name: "com.aiphotocoach.app/ar",
        binaryMessenger: messenger
      )
      methodChannel.setMethodCallHandler(arHandler.handle)

      let eventChannel = FlutterEventChannel(
        name: "com.aiphotocoach.app/ar_events",
        binaryMessenger: messenger
      )
      eventChannel.setStreamHandler(arHandler)
    }

    if #available(iOS 15.0, *) {
      window?.layer.contentsScale = UIScreen.main.nativeScale
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}