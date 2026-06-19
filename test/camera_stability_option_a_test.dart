import 'package:ai_photo_coach/features/camera/presentation/widgets/camera_zoom_gesture_state.dart';
import 'package:ai_photo_coach/features/camera/services/camera_hdr_capability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Option A stability', () {
    test('HDR is not supported via camera plugin yet', () {
      expect(CameraHdrCapability.isSupported, isFalse);
    });

    test('zoom gesture syncs from provider before pinch', () {
      final gesture = CameraZoomGestureState();
      gesture.syncFromProvider(1.2);

      expect(gesture.currentZoom, 1.2);
      expect(gesture.baseZoom, 1.2);
    });

    test('pinch scale uses synced base zoom after guidance change', () {
      final gesture = CameraZoomGestureState();
      gesture.syncFromProvider(1.15);
      gesture.beginPinch();
      gesture.applyPinchScale(1.1);

      expect(gesture.currentZoom, closeTo(1.265, 0.001));
    });

    test('provider update resets pinch baseline', () {
      final gesture = CameraZoomGestureState();
      gesture.syncFromProvider(1.0);
      gesture.beginPinch();
      gesture.applyPinchScale(2.0);
      expect(gesture.currentZoom, closeTo(2.0, 0.001));

      gesture.syncFromProvider(1.2);
      gesture.beginPinch();
      gesture.applyPinchScale(1.5);

      expect(gesture.currentZoom, closeTo(1.8, 0.001));
    });
  });
}