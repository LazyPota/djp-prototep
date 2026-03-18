# E-Commerce Fraud Detector

A Flutter application designed to detect fraudulent e-commerce links using a dual-approach (Android floating overlay and iOS Share Extension). This project uses Clean Architecture and Riverpod for state management.

## Setup Instructions for Visual Studio Code

Follow these steps to set up and run the project locally using Visual Studio Code (VS Code).

### Prerequisites

1.  **Flutter SDK**: Ensure you have Flutter installed. [Install Flutter](https://docs.flutter.dev/get-started/install).
2.  **Visual Studio Code**: Download and install [VS Code](https://code.visualstudio.com/).
3.  **VS Code Extensions**:
    *   Install the **Flutter** extension (this will also install the **Dart** extension).
    *   *(Optional but recommended)* Install **Riverpod Snippets** or **Flutter Riverpod Snippets** for easier provider creation.

### 1. Open the Project

1.  Open VS Code.
2.  Go to `File` > `Open Folder...` and select the root directory of this project (`ecommerce_fraud_detector`).

### 2. Fetch Dependencies

1.  Open a new terminal in VS Code (`Terminal` > `New Terminal`).
2.  Run the following command to download all required packages:
    ```bash
    flutter pub get
    ```

### 3. Generate Code (Riverpod)

Since this project uses `riverpod_generator` and `riverpod_annotation`, you need to run the code generator whenever you create or modify annotated providers.

1.  In the VS Code terminal, run:
    ```bash
    dart run build_runner build -d
    ```
    *Note: Use `dart run build_runner watch -d` if you want it to continuously generate files as you save.*

### 4. Running the App

1.  Connect a physical device or start an emulator/simulator.
    *   You can select the target device in the bottom right corner of the VS Code window (e.g., clicking on "macOS" or "No Device" to bring up the device list).
2.  Press **F5** or go to the `Run` tab on the left sidebar and click `Run and Debug` to launch the application.
3.  Alternatively, you can run the app from the terminal:
    ```bash
    flutter run
    ```

## Architecture and Key Packages

*   **State Management**: `flutter_riverpod`, `riverpod_annotation`
*   **Android Overlay**: `system_alert_window` (Requires granting "Display over other apps" permission).
*   **iOS Integration**: `receive_sharing_intent` (Requires manual Xcode configuration. See `iOS_SETUP_INSTRUCTIONS.md` for details).
*   **UI Gauge**: `syncfusion_flutter_gauges` for the Trust Score visualizer.

## Important Note on iOS

The iOS Share Extension cannot be fully configured via Flutter tooling alone. You **must** follow the manual steps outlined in the `iOS_SETUP_INSTRUCTIONS.md` file located in the root of this project to correctly configure the Xcode target, App Groups, and Swift native code.
