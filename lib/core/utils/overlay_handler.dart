import 'package:flutter_overlay_window/flutter_overlay_window.dart';

Future<void> updateOverlayData(Map data) async {
  final bool isActive = await FlutterOverlayWindow.isActive();
  if (isActive) {
    await FlutterOverlayWindow.shareData(data);
  } else {
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "Fraud Detector",
      overlayContent: "Running in background",
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: 150,
      width: 150,
    );
    // Give the overlay time to spin up
    Future.delayed(const Duration(milliseconds: 1000), () async {
      await FlutterOverlayWindow.shareData(data);
    });
  }
}
