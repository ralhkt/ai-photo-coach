import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/camera_shell_mode.dart';

/// Active camera shell (錄影 / 影相 / 引導) — switching does not navigate.
final cameraShellModeProvider = StateProvider<CameraShellMode>(
  (ref) => CameraShellMode.photo,
);