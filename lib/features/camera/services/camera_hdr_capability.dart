/// HDR support probe for the Flutter [camera] plugin.
///
/// The plugin exposes exposure offset / flash / zoom but not platform HDR fusion.
class CameraHdrCapability {
  const CameraHdrCapability._();

  /// Whether the app can apply a real HDR capture mode on this device.
  static bool get isSupported => false;
}