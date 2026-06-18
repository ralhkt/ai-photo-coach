import 'package:ai_photo_coach/features/overlays/presentation/composition_overlay_painter.dart';
import 'package:ai_photo_coach/models/composition_overlay_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('composition overlay painter renders without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomPaint(
            painter: CompositionOverlayPainter(
              type: CompositionOverlayType.ruleOfThirds,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
  });
}