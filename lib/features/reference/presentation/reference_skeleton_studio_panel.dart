import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../providers/reference_skeleton_providers.dart';

/// 骨架工作室控制：僅骨架預覽、線條粗細、匯出 PNG。
class ReferenceSkeletonStudioPanel extends ConsumerWidget {
  const ReferenceSkeletonStudioPanel({
    super.key,
    required this.onExport,
    this.isExporting = false,
    this.hasSkeleton = true,
  });

  final VoidCallback? onExport;
  final bool isExporting;
  final bool hasSkeleton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final skeletonOnly = ref.watch(skeletonOnlyPreviewProvider);
    final strokeWidth = ref.watch(skeletonStrokeWidthProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.skeletonStudioTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppDesignTokens.spaceSm),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              label: Text(l10n.skeletonViewOverlay),
              icon: const Icon(Icons.layers_outlined, size: 18),
            ),
            ButtonSegment(
              value: true,
              label: Text(l10n.skeletonViewOnly),
              icon: const Icon(Icons.accessibility_outlined, size: 18),
            ),
          ],
          selected: {skeletonOnly},
          onSelectionChanged: hasSkeleton
              ? (selection) {
                  ref
                      .read(skeletonOnlyPreviewProvider.notifier)
                      .update(selection.first);
                }
              : null,
        ),
        const SizedBox(height: AppDesignTokens.spaceMd),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.skeletonStrokeWidthLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Text(
              strokeWidth.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        Slider(
          value: strokeWidth,
          min: 0.8,
          max: 6.0,
          divisions: 26,
          label: strokeWidth.toStringAsFixed(1),
          onChanged: hasSkeleton
              ? (value) {
                  ref.read(skeletonStrokeWidthProvider.notifier).update(value);
                }
              : null,
        ),
        const SizedBox(height: AppDesignTokens.spaceSm),
        FilledButton.icon(
          onPressed: hasSkeleton && !isExporting ? onExport : null,
          icon: isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          label: Text(
            isExporting ? l10n.skeletonExporting : l10n.skeletonExportPng,
          ),
        ),
      ],
    );
  }
}