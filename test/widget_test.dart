import 'package:ai_photo_coach/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home screen shows primary actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AiPhotoCoachApp(),
      ),
    );

    expect(find.text('AI 攝影教練'), findsOneWidget);
    expect(find.text('分析參考相片'), findsOneWidget);
    expect(find.text('開啟相機'), findsOneWidget);
  });
}