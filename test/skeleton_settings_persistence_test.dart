import 'package:ai_photo_coach/core/settings/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SettingsRepository persists skeleton studio preferences', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository();

    await repository.saveSkeletonStrokeWidth(4.5);
    await repository.saveSkeletonOnlyPreview(true);

    expect(await repository.loadSkeletonStrokeWidth(), 4.5);
    expect(await repository.loadSkeletonOnlyPreview(), isTrue);
  });

  test('skeleton settings fall back to defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository();

    expect(await repository.loadSkeletonStrokeWidth(), 2.2);
    expect(await repository.loadSkeletonOnlyPreview(), isFalse);
  });
}