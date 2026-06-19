import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/settings_repository.dart';

/// 僅顯示骨架線（隱藏參考照片），適合描摹練習。
final skeletonOnlyPreviewProvider =
    NotifierProvider<SkeletonOnlyPreviewNotifier, bool>(
  SkeletonOnlyPreviewNotifier.new,
);

/// 骨架線條粗細（預覽、匯出與引導拍攝 overlay 共用）。
final skeletonStrokeWidthProvider =
    NotifierProvider<SkeletonStrokeWidthNotifier, double>(
  SkeletonStrokeWidthNotifier.new,
);

class SkeletonStrokeWidthNotifier extends Notifier<double> {
  @override
  double build() {
    unawaited(_hydrate());
    return 2.2;
  }

  Future<void> _hydrate() async {
    final width = await ref.read(settingsRepositoryProvider).loadSkeletonStrokeWidth();
    if (state != width) {
      state = width;
    }
  }

  void update(double width) {
    state = width;
    unawaited(
      ref.read(settingsRepositoryProvider).saveSkeletonStrokeWidth(width),
    );
  }
}

class SkeletonOnlyPreviewNotifier extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_hydrate());
    return false;
  }

  Future<void> _hydrate() async {
    final value =
        await ref.read(settingsRepositoryProvider).loadSkeletonOnlyPreview();
    if (state != value) {
      state = value;
    }
  }

  void update(bool value) {
    state = value;
    unawaited(
      ref.read(settingsRepositoryProvider).saveSkeletonOnlyPreview(value),
    );
  }
}