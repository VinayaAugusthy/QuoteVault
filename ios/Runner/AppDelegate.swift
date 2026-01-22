import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let galleryChannelName = "quote_vault/gallery_saver"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: galleryChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard let self else { return }
        switch call.method {
        case "saveImage":
          guard
            let args = call.arguments as? [String: Any],
            let typedData = args["bytes"] as? FlutterStandardTypedData,
            let image = UIImage(data: typedData.data)
          else {
            result(
              FlutterError(code: "invalid_args", message: "Missing/invalid bytes", details: nil)
            )
            return
          }
          self.saveToPhotos(image: image, result: result)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveToPhotos(image: UIImage, result: @escaping FlutterResult) {
    let handler: (PHAuthorizationStatus) -> Void = { status in
      switch status {
      case .authorized, .limited:
        var localIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
          let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
          localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
        }, completionHandler: { success, error in
          DispatchQueue.main.async {
            if success {
              result(localIdentifier)
            } else {
              result(
                FlutterError(
                  code: "save_failed",
                  message: error?.localizedDescription ?? "Failed to save image",
                  details: nil
                )
              )
            }
          }
        })

      default:
        result(
          FlutterError(code: "permission_denied", message: "Photo permission denied", details: nil)
        )
      }
    }

    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: handler)
    } else {
      PHPhotoLibrary.requestAuthorization(handler)
    }
  }
}
