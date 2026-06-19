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

  @override
  Widget build(BuildContext context) {
    final providerVisible = ref.watch(widget.visibleProvider);
    final visible = _optimisticVisible ?? providerVisible;

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

  @override
  void didUpdateWidget(covariant GuidedOptimisticToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_optimisticVisible != null &&
        _optimisticVisible == ref.read(widget.visibleProvider)) {
      _optimisticVisible = null;
    }
  }
}