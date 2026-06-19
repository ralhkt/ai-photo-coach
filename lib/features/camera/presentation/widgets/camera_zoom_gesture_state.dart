/// Local pinch-zoom bookkeeping kept in sync with [focalPresetProvider].
class CameraZoomGestureState {
  double currentZoom = 1.0;
  double baseZoom = 1.0;

  void syncFromProvider(double providerZoom) {
    currentZoom = providerZoom;
    baseZoom = providerZoom;
  }

  double zoomFromPinchScale(double scale) => baseZoom * scale;

  void beginPinch() {
    baseZoom = currentZoom;
  }

  void applyPinchScale(double scale) {
    currentZoom = zoomFromPinchScale(scale);
  }
}