import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/composition_overlay_type.dart';

final overlayVisibleProvider = StateProvider<bool>((ref) => true);

final overlayTypeProvider = StateProvider<CompositionOverlayType>(
  (ref) => CompositionOverlayType.ruleOfThirds,
);