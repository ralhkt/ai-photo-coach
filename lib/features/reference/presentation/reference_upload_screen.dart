import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/guidance_text.dart';
import '../../../core/widgets/app_surface_widgets.dart';
import '../../../models/scene_type.dart';
import '../../pose/providers/pose_coaching_provider.dart';
import '../data/reference_sample_catalog.dart';
import '../providers/reference_providers.dart';
import 'analysis_result_screen.dart';

class ReferenceUploadScreen extends ConsumerStatefulWidget {
  const ReferenceUploadScreen({super.key});

  @override
  ConsumerState<ReferenceUploadScreen> createState() =>
      _ReferenceUploadScreenState();
}

class _ReferenceUploadScreenState extends ConsumerState<ReferenceUploadScreen> {
  final _picker = ImagePicker();
  String? _activeSampleId;
  bool _isPickingGallery = false;

  Future<void> _runAnalysis(Uint8List bytes, SceneType sceneType) async {
    final l10n = AppLocalizations.of(context)!;
    ref.read(selectedSceneTypeProvider.notifier).state = sceneType;

    await ref.read(referenceAnalysisProvider.notifier).analyze(
          bytes,
          userSceneType: sceneType,
        );

    if (!mounted) {
      return;
    }

    final analysis = ref.read(referenceAnalysisProvider);
    if (analysis.hasError) {
      final detail = analysis.error?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            detail == null || detail.isEmpty
                ? l10n.analysisFailed
                : '${l10n.analysisFailed}\n$detail',
          ),
          action: SnackBarAction(
            label: l10n.retry,
            onPressed: () => _runAnalysis(bytes, sceneType),
          ),
        ),
      );
      return;
    }

    if (analysis.hasValue && analysis.value != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AnalysisResultScreen(),
        ),
      );
    }
  }

  Future<void> _analyzeSample(ReferenceSample sample) async {
    if (_activeSampleId != null || _isPickingGallery) {
      return;
    }

    setState(() => _activeSampleId = sample.id);

    try {
      loadTrendyTemplateForSample(ref, sample.id);
      final data = await rootBundle.load(sample.assetPath);
      await _runAnalysis(data.buffer.asUint8List(), sample.sceneType);
    } finally {
      if (mounted) {
        setState(() => _activeSampleId = null);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_activeSampleId != null || _isPickingGallery) {
      return;
    }

    setState(() => _isPickingGallery = true);

    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (!mounted || file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      final sceneType = ref.read(selectedSceneTypeProvider);
      await _runAnalysis(bytes, sceneType);
    } finally {
      if (mounted) {
        setState(() => _isPickingGallery = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysisState = ref.watch(referenceAnalysisProvider);
    final selectedScene = ref.watch(selectedSceneTypeProvider);
    final isAnalyzing = analysisState.isLoading ||
        _activeSampleId != null ||
        _isPickingGallery;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadReferenceTitle)),
      body: SafeArea(
        child: isAnalyzing
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.accent),
                    const SizedBox(height: AppDesignTokens.spaceLg),
                    Text(l10n.analyzingImage),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDesignTokens.screenPadding,
                      AppDesignTokens.spaceLg,
                      AppDesignTokens.screenPadding,
                      AppDesignTokens.spaceSm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppFlowStrip(
                            activeIndex: 0,
                            steps: [
                              l10n.homeFlowStepReference,
                              l10n.homeFlowStepAnalyze,
                              l10n.homeFlowStepShoot,
                            ],
                          ),
                          const SizedBox(height: AppDesignTokens.space2xl),
                          Text(
                            l10n.uploadReferenceSubtitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppDesignTokens.space2xl),
                          AppSectionHeader(
                            title: l10n.uploadOwnPhotoSection,
                            subtitle: l10n.selectSceneTypeHint,
                          ),
                          const SizedBox(height: AppDesignTokens.spaceMd),
                          AppSegmentedPicker<SceneType>(
                            items: SceneType.values,
                            selected: selectedScene,
                            labelBuilder: (scene) =>
                                sceneTypeChoiceLabel(l10n, scene),
                            onSelected: (scene) {
                              ref
                                  .read(selectedSceneTypeProvider.notifier)
                                  .state = scene;
                            },
                          ),
                          const SizedBox(height: AppDesignTokens.spaceLg),
                          FilledButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(l10n.pickFromGallery),
                          ),
                          const SizedBox(height: AppDesignTokens.space3xl),
                          AppSectionHeader(
                            title: l10n.referenceSamplesSection,
                            subtitle: l10n.uploadPrompt,
                          ),
                          const SizedBox(height: AppDesignTokens.spaceMd),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.screenPadding,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppDesignTokens.spaceMd,
                        crossAxisSpacing: AppDesignTokens.spaceMd,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sample = referenceSampleCatalog[index];
                          return _ReferenceSampleCard(
                            sample: sample,
                            title: referenceSampleTitle(l10n, sample.titleKey),
                            subtitle: referenceSampleSubtitle(
                              l10n,
                              sample.subtitleKey,
                            ),
                            onTap: () => _analyzeSample(sample),
                          );
                        },
                        childCount: referenceSampleCatalog.length,
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
      ),
    );
  }
}

class _ReferenceSampleCard extends StatelessWidget {
  const _ReferenceSampleCard({
    required this.sample,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ReferenceSample sample;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              sample.assetPath,
              fit: BoxFit.cover,
              cacheWidth: 420,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0.45, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              left: AppDesignTokens.spaceMd,
              right: AppDesignTokens.spaceMd,
              bottom: AppDesignTokens.spaceMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppDesignTokens.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppDesignTokens.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}