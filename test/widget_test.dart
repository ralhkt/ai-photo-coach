import 'package:ai_photo_coach/app.dart';
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

    expect(find.text('攝影師'), findsOneWidget);
    expect(find.text('選擇範例相片'), findsOneWidget);
    expect(find.text('開啟相機'), findsOneWidget);
  });
}