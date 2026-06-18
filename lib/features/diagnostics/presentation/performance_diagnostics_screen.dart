import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/performance/battery_session_tracker.dart';
import '../../../core/performance/performance_budget.dart';
import '../../../core/performance/performance_tracker.dart';
import '../../session/services/quick_photo_scorer.dart';

class PerformanceDiagnosticsScreen extends ConsumerStatefulWidget {
  const PerformanceDiagnosticsScreen({super.key});

  @override
  ConsumerState<PerformanceDiagnosticsScreen> createState() =>
      _PerformanceDiagnosticsScreenState();
}

class _PerformanceDiagnosticsScreenState
    extends ConsumerState<PerformanceDiagnosticsScreen> {
  bool _runningBenchmark = false;
  String? _benchmarkResult;

  Future<void> _runBenchmark() async {
    setState(() {
      _runningBenchmark = true;
      _benchmarkResult = null;
    });

    final scorer = ref.read(quickPhotoScorerProvider);
    final result = await scorer.score(Uint8List.fromList(_tinyPng));
    final avgQuick = ref.read(performanceTrackerProvider).averageMs(
          'session_photo_quick',
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _runningBenchmark = false;
      _benchmarkResult = '${result.analysisMs} ms (avg quick $avgQuick ms)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tracker = ref.watch(performanceTrackerProvider);
    final batteryReport = ref.watch(lastBatteryReportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosticsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.diagnosticsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          _BudgetRow(
            label: l10n.diagnosticsMlBudget,
            budgetMs: PerformanceBudget.mlInferenceMs,
            averageMs: tracker.averageMs('ml_inference_quick'),
            overBudget: tracker.countOverBudget('ml_inference_quick'),
          ),
          _BudgetRow(
            label: l10n.diagnosticsSessionPhotoBudget,
            budgetMs: PerformanceBudget.sessionPhotoAnalysisMs,
            averageMs: tracker.averageMs('session_photo_quick'),
            overBudget: tracker.countOverBudget('session_photo_quick'),
          ),
          _BudgetRow(
            label: l10n.diagnosticsSessionTotalBudget,
            budgetMs: PerformanceBudget.sessionTotalAnalysisMs,
            averageMs: tracker.averageMs('session_summary_total'),
            overBudget: tracker.countOverBudget('session_summary_total'),
          ),
          const SizedBox(height: 20),
          if (batteryReport != null) ...[
            Text(
              l10n.diagnosticsLastBattery,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.diagnosticsBatteryDetail(
                batteryReport.deltaPercent,
                batteryReport.drainPer10Minutes.toStringAsFixed(1),
                batteryReport.withinMvpBudget
                    ? l10n.diagnosticsWithinBudget
                    : l10n.diagnosticsOverBudget,
              ),
            ),
            const SizedBox(height: 20),
          ],
          FilledButton(
            onPressed: _runningBenchmark ? null : _runBenchmark,
            child: Text(
              _runningBenchmark
                  ? l10n.diagnosticsRunningBenchmark
                  : l10n.diagnosticsRunBenchmark,
            ),
          ),
          if (_benchmarkResult != null) ...[
            const SizedBox(height: 12),
            Text(_benchmarkResult!),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ref.read(performanceTrackerProvider).clear();
              setState(() => _benchmarkResult = null);
            },
            child: Text(l10n.diagnosticsClearSamples),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.label,
    required this.budgetMs,
    required this.averageMs,
    required this.overBudget,
  });

  final String label;
  final int budgetMs;
  final double averageMs;
  final int overBudget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            l10n.diagnosticsBudgetValue(
              averageMs.toStringAsFixed(0),
              '$budgetMs',
              '$overBudget',
            ),
          ),
        ],
      ),
    );
  }
}

final _tinyPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];