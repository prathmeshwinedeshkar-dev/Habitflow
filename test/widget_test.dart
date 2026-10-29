import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/models/habit.dart';
import 'package:habitflow/widgets/category_chip.dart';
import 'package:habitflow/widgets/empty_state.dart';
import 'package:habitflow/widgets/progress_ring.dart';
import 'package:habitflow/widgets/streak_badge.dart';

void main() {
  group('HabitFlow Custom UI Widgets Smoke Tests', () {
    testWidgets('StreakBadge displays flame and day count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(streak: 5),
          ),
        ),
      );

      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('CategoryChip displays category name and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: HabitCategory.study,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Study'), findsOneWidget);
      await tester.tap(find.byType(CategoryChip));
      expect(tapped, true);
    });

    testWidgets('ProgressRing displays accurate completion percentage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 0.75,
              size: 80,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('EmptyState triggers add habit callback when CTA pressed', (tester) async {
      bool addPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              onAddHabit: () => addPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No habits yet.'), findsOneWidget);
      expect(find.text('Start with one tiny win.'), findsOneWidget);

      await tester.tap(find.text('Add your first habit'));
      expect(addPressed, true);
    });
  });
}
