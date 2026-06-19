import 'package:ai_photo_coach/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen shows primary actions', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await tester.pumpWidget(
      const ProviderScope(
        child: AiPhotoCoachApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('攝影師'), findsWidgets);
    expect(find.text('選擇範例相片'), findsWidgets);
    expect(find.text('開啟相機'), findsOneWidget);
  });

  testWidgets('reference screen offers gallery upload', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await tester.pumpWidget(
      const ProviderScope(
        child: AiPhotoCoachApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('從相簿選擇'), findsOneWidget);
    expect(find.text('或上傳自己的相片'), findsOneWidget);
  });
}