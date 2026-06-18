import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/guidance_text.dart';
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
  String? _activeSampleId;

  Future<void> _analyzeSample(ReferenceSample sample) async {
    if (_activeSampleId != null) {
      return;
    }

    setState(() => _activeSampleId = sample.id);
    final l10n = AppLocalizations.of(context)!;

    try {
      final data = await rootBundle.load(sample.assetPath);
      final bytes = data.buffer.asUint8List();
      ref.read(selectedSceneTypeProvider.notifier).state = sample.sceneType;

      await ref.read(referenceAnalysisProvider.notifier).analyze(
            bytes,
            userSceneType: sample.sceneType,
          );

      if (!mounted) {
        return;
      }

      final analysis = ref.read(referenceAnalysisProvider);
      if (analysis.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.analysisFailed)),
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
    } finally {
      if (mounted) {
        setState(() => _activeSampleId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysisState = ref.watch(referenceAnalysisProvider);
    final isAnalyzing = analysisState.isLoading || _activeSampleId != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadReferenceTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.uploadReferenceSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.uploadPrompt,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (isAnalyzing) ...[
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Text(
                  l10n.analyzingImage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ] else
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: referenceSampleCatalog.length,
                    itemBuilder: (context, index) {
                      final sample = referenceSampleCatalog[index];
                      return _ReferenceSampleCard(
                        sample: sample,
                        title: referenceSampleTitle(l10n, sample.titleKey),
                        subtitle:
                            referenceSampleSubtitle(l10n, sample.subtitleKey),
                        onTap: () => _analyzeSample(sample),
                      );
                    },
                  ),
                ),
            ],
          ),
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(17)),
                  child: Image.asset(
                    sample.assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
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
      ),
    );
  }
}