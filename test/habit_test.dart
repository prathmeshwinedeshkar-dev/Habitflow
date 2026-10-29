import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/models/habit.dart';
import 'package:habitflow/services/streak_service.dart';

void main() {
  group('Habit Model & OOP Tests', () {
    test('Habit initializes correctly with default values', () {
      final habit = Habit(
        id: 'h1',
        title: 'Morning Run',
      );

      expect(habit.id, 'h1');
      expect(habit.title, 'Morning Run');
      expect(habit.emoji, '⚡');
      expect(habit.category, HabitCategory.productivity);
      expect(habit.isActive, true);
      expect(habit.targetPerDay, 1);
      expect(habit.completionDates, isEmpty);
      expect(habit.isCompletedToday(), false);
    });

    test('isCompletedToday returns true when completion dates include today', () {
      final today = DateTime.now();
      final habit = Habit(
        id: 'h2',
        title: 'Hydrate',
        completionDates: [today],
      );

      expect(habit.isCompletedToday(), true);
    });

    test('toggleCompletionForToday adds and removes today appropriately', () {
      final habit = Habit(id: 'h3', title: 'Read Book');
      expect(habit.isCompletedToday(), false);

      // Toggle ON
      final completedHabit = habit.toggleCompletionForToday();
      expect(completedHabit.isCompletedToday(), true);
      expect(completedHabit.completionDates.length, 1);

      // Toggle OFF (Undo)
      final uncompletedHabit = completedHabit.toggleCompletionForToday();
      expect(uncompletedHabit.isCompletedToday(), false);
      expect(uncompletedHabit.completionDates.length, 0);
    });

    test('JSON serialization roundtrip preserves all fields', () {
      final created = DateTime(2026, 1, 15, 10, 30);
      final completion1 = DateTime(2026, 1, 16);
      final completion2 = DateTime(2026, 1, 17);

      final original = Habit(
        id: 'habit_123',
        title: 'Learn Flutter',
        emoji: '💙',
        category: HabitCategory.study,
        createdAt: created,
        completionDates: [completion1, completion2],
        reminderTime: '09:00 AM',
        targetPerDay: 2,
        isActive: true,
      );

      final json = original.toJson();
      final reconstructed = Habit.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.emoji, original.emoji);
      expect(reconstructed.category, HabitCategory.study);
      expect(reconstructed.reminderTime, '09:00 AM');
      expect(reconstructed.targetPerDay, 2);
      expect(reconstructed.completionDates.length, 2);
    });
  });

  group('Streak Calculation Tests', () {
    test('Streak is 0 when no dates are recorded', () {
      final habit = Habit(id: 's0', title: 'Meditate');
      expect(habit.getCurrentStreak(), 0);
      expect(habit.getBestStreak(), 0);
    });

    test('Streak counts consecutive days ending today', () {
      final today = DateTime(2026, 10, 29);
      final yesterday = DateTime(2026, 10, 28);
      final twoDaysAgo = DateTime(2026, 10, 27);

      final habit = Habit(
        id: 's1',
        title: 'Coding',
        completionDates: [twoDaysAgo, yesterday, today],
      );

      expect(habit.getCurrentStreak(today), 3);
      expect(habit.getBestStreak(), 3);
    });

    test('Streak is preserved if completed yesterday but not yet today', () {
      final today = DateTime(2026, 10, 29);
      final yesterday = DateTime(2026, 10, 28);
      final twoDaysAgo = DateTime(2026, 10, 27);

      final habit = Habit(
        id: 's2',
        title: 'Workout',
        completionDates: [twoDaysAgo, yesterday],
      );

      // Not yet completed today, but was done yesterday -> active streak of 2
      expect(habit.getCurrentStreak(today), 2);
    });

    test('Streak resets to 0 if yesterday was missed and today is not done', () {
      final today = DateTime(2026, 10, 29);
      final threeDaysAgo = DateTime(2026, 10, 26);

      final habit = Habit(
        id: 's3',
        title: 'Floss',
        completionDates: [threeDaysAgo],
      );

      expect(habit.getCurrentStreak(today), 0);
    });

    test('getBestStreak accurately detects longest historical sequence', () {
      // Sequence 1: 4 days (Jan 1-4)
      // Sequence 2: 2 days (Jan 10-11)
      final habit = Habit(
        id: 's4',
        title: 'Deep Work',
        completionDates: [
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
          DateTime(2026, 1, 4),
          DateTime(2026, 1, 10),
          DateTime(2026, 1, 11),
        ],
      );

      expect(habit.getBestStreak(), 4);
    });

    test('getCompletionRateForLast7Days returns accurate percentage', () {
      final today = DateTime(2026, 10, 29);
      final habit = Habit(
        id: 's5',
        title: 'Stretch',
        completionDates: [
          DateTime(2026, 10, 29), // today
          DateTime(2026, 10, 28), // 1 day ago
          DateTime(2026, 10, 27), // 2 days ago
        ],
      );

      // 3 out of 7 days
      final rate = habit.getCompletionRateForLast7Days(today);
      expect(rate, closeTo(3 / 7.0, 0.001));
    });
  });

  group('StreakService & Impact Simulator Tests', () {
    test('Simulator projection computes correct streaks and growth stages', () {
      final habit = Habit(
        id: 'sim1',
        title: 'Guitar Practice',
        completionDates: [
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now(),
        ],
      );

      final projection7 = StreakService.projectHabitImpact(habit, 7);
      expect(projection7['projectedDays'], 7);
      expect(projection7['projectedStreak'], 9); // 2 existing + 7
      expect(projection7['growthStage'], 'Growing Sapling');

      final projection30 = StreakService.projectHabitImpact(habit, 30);
      expect(projection30['projectedStreak'], 32);
      expect(projection30['growthStage'], 'Flourishing Tree');
    });
  });
}
