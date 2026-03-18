# iOS Setup Instructions for Share Extension

Since iOS does not allow overlay windows, we use an iOS Share Extension to analyze e-commerce links. Follow these manual steps carefully to configure your Xcode project and establish communication with Flutter.

## 1. Create the Share Extension Target

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Go to `File` > `New` > `Target...`
3. Select `Share Extension` and click `Next`.
4. Name the product (e.g., `ShareExtension`), choose `Swift` as the language, and ensure the target is embedded in the `Runner` application. Click `Finish`.
5. When prompted to activate the scheme, click `Activate`.

## 2. Configure App Groups

We need App Groups to share memory between the main Flutter app and the Share Extension.

1. Select the top-level `Runner` project in the Project Navigator.
2. Under `Signing & Capabilities`, click `+ Capability` and add `App Groups`.
3. Create a new App Group, e.g., `group.com.yourcompany.ecommerce_fraud_detector` (ensure it matches your bundle ID structure).
4. Repeat this step for the `ShareExtension` target. Ensure *both* targets have the exact same App Group selected.

## 3. Update the Main App Delegate (Swift)

Modify `ios/Runner/AppDelegate.swift` to setup a `FlutterMethodChannel` to receive data from the Share Extension via UserDefaults (which utilizes the App Group).

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let shareChannel = FlutterMethodChannel(name: "com.yourcompany.ecommerce_fraud_detector/share",
                                              binaryMessenger: controller.binaryMessenger)

    shareChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getSharedData" {
          // Access App Group UserDefaults
          let defaults = UserDefaults(suiteName: "group.com.yourcompany.ecommerce_fraud_detector")
          let sharedText = defaults?.string(forKey: "sharedText")
          result(sharedText)

          // Clear it after reading
          defaults?.removeObject(forKey: "sharedText")
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 4. Update the Share Extension View Controller (Swift)

Replace the contents of `ShareViewController.swift` in your `ShareExtension` folder with the following code. This code captures the URL, displays a simple loading UI, simulates analysis (since we can't spin up the full Flutter engine easily without memory overhead in a share extension), and displays the score before completing the request.

```swift
import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {

    let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        processSharedURL()
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        statusLabel.text = "Analyzing Link..."
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 20, weight: .bold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func processSharedURL() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let attachments = item.attachments {

            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (item, error) in
                        if let sharedURL = item as? URL {

                            // 1. Save the URL to the App Group UserDefaults to sync back to Flutter later
                            let defaults = UserDefaults(suiteName: "group.com.yourcompany.ecommerce_fraud_detector")
                            defaults?.set(sharedURL.absoluteString, forKey: "sharedText")
                            defaults?.synchronize()

                            // 2. Perform a network request to your FastAPI backend here to get the Trust Score
                            // Note: In a real app, do an async URLSession call here to the same endpoint
                            // the Flutter app uses, rather than waiting for the user to open the app.

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                // Mocking the result for the boilerplate
                                self.statusLabel.text = "Trust Score: 25% (High Risk)"
                                self.statusLabel.textColor = .systemRed

                                // Auto dismiss after showing result
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                                }
                            }
                        }
                    })
                    return // Exit early since we found a URL
                }
            }
        }

        // If no URL was found, just complete the request
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
```

## 5. Handle the URL in Flutter

In your Flutter app, you can now call the method channel to retrieve the shared URL when the app becomes active, or use the `receive_sharing_intent` package which handles much of this bridging for you under the hood if configured properly via its documentation.

Since you are using `receive_sharing_intent`, you will also need to add the following to your `ios/Runner/Info.plist`:

```xml
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
```

Follow the `receive_sharing_intent` package documentation for any additional specific `Info.plist` entries required for URL handling.
