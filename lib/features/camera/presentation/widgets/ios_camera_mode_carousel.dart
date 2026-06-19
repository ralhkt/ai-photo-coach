import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ios_camera_ui_kit.dart';

/// Native Camera mode strip below shutter — 錄影 · 影相 · (引導).
class IosCameraModeCarousel extends StatelessWidget {
  const IosCameraModeCarousel({
    super.key,
    required this.modes,
    required this.selectedIndex,
    this.onModeSelected,
  });

  final List<String> modes;
  final int selectedIndex;
  final ValueChanged<int>? onModeSelected;

  @override
  Widget build(BuildContext context) {
    if (modes.isEmpty) {
      return const SizedBox.shrink();
    }

    if (modes.length <= 3) {
      return _NativeModeStrip(
        modes: modes,
        selectedIndex: selectedIndex.clamp(0, modes.length - 1),
        onModeSelected: onModeSelected,
      );
    }

    return _ScrollableModeStrip(
      modes: modes,
      selectedIndex: selectedIndex,
      onModeSelected: onModeSelected,
    );
  }
}

class _NativeModeStrip extends StatelessWidget {
  const _NativeModeStrip({
    required this.modes,
    required this.selectedIndex,
    this.onModeSelected,
  });

  final List<String> modes;
  final int selectedIndex;
  final ValueChanged<int>? onModeSelected;

  void _select(int index) {
    if (onModeSelected == null || index == selectedIndex) {
      return;
    }
    HapticFeedback.selectionClick();
    onModeSelected!(index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -240 && selectedIndex < modes.length - 1) {
          _select(selectedIndex + 1);
        } else if (velocity > 240 && selectedIndex > 0) {
          _select(selectedIndex - 1);
        }
      },
      child: SizedBox(
        height: IosCameraUiKit.modeCarouselHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < modes.length; i++) ...[
              if (i > 0) SizedBox(width: i == 1 ? 32 : 24),
              _ModeTile(
                label: modes[i],
                selected: selectedIndex == i,
                onTap: onModeSelected == null ? null : () => _select(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: IosCameraUiKit.morphAnimation,
            curve: Curves.easeOutCubic,
            style: selected
                ? IosCameraUiKit.modeSelected.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: IosCameraUiKit.accentYellow,
                  )
                : IosCameraUiKit.modeUnselected.copyWith(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            child: Text(label),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: IosCameraUiKit.morphAnimation,
            width: selected ? 5 : 0,
            height: selected ? 5 : 0,
            decoration: const BoxDecoration(
              color: IosCameraUiKit.accentYellow,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollableModeStrip extends StatefulWidget {
  const _ScrollableModeStrip({
    required this.modes,
    required this.selectedIndex,
    this.onModeSelected,
  });

  final List<String> modes;
  final int selectedIndex;
  final ValueChanged<int>? onModeSelected;

  @override
  State<_ScrollableModeStrip> createState() => _ScrollableModeStripState();
}

class _ScrollableModeStripState extends State<_ScrollableModeStrip> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: IosCameraUiKit.modeCarouselHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: widget.modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 28),
        itemBuilder: (context, index) {
          final selected = index == widget.selectedIndex;
          return GestureDetector(
            onTap: widget.onModeSelected == null
                ? null
                : () => widget.onModeSelected!(index),
            child: Text(
              widget.modes[index],
              style: selected
                  ? IosCameraUiKit.modeSelected
                  : IosCameraUiKit.modeUnselected,
            ),
          );
        },
      ),
    );
  }
}