import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_glass_widgets.dart';
import '../../providers/camera_interaction_provider.dart';

/// Instant visual toggle — updates local state before Riverpod propagates.
class GuidedOptimisticToggleButton extends ConsumerStatefulWidget {
  const GuidedOptimisticToggleButton({
    super.key,
    required this.visibleProvider,
    required this.onIcon,
    required this.offIcon,
    required this.tooltip,
    required this.onToggle,
  });

  final StateProvider<bool> visibleProvider;
  final IconData onIcon;
  final IconData offIcon;
  final String tooltip;
  final void Function(WidgetRef ref) onToggle;

  @override
  ConsumerState<GuidedOptimisticToggleButton> createState() =>
      _GuidedOptimisticToggleButtonState();
}

class _GuidedOptimisticToggleButtonState
    extends ConsumerState<GuidedOptimisticToggleButton> {
  bool? _optimisticVisible;
  bool _syncedVisible = true;
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      _syncedVisible = ref.read(widget.visibleProvider);
      _seeded = true;
    }

    ref.listen<bool>(widget.visibleProvider, (previous, next) {
      if (_optimisticVisible == null || _optimisticVisible == next) {
        setState(() {
          _optimisticVisible = null;
          _syncedVisible = next;
        });
      }
    });

    final visible = _optimisticVisible ?? _syncedVisible;

    return AppCameraToolButton(
      icon: visible ? widget.onIcon : widget.offIcon,
      tooltip: widget.tooltip,
      active: visible,
      onTap: () {
        markGuidedUserActivity(ref);
        final next = !visible;
        setState(() => _optimisticVisible = next);
        widget.onToggle(ref);
      },
    );
  }
}