import '../models/habit.dart';

/// Service dedicated to streak analysis, date normalization,
/// and future habit projection calculations.
class StreakService {
  StreakService._();

  /// Normalizes a DateTime to date-only (year, month, day)
  static DateTime normalize(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Calculates current consecutive day streak.
  /// Counts backwards from today if completed today, or from yesterday if completed yesterday.
  static int calculateCurrentStreak(List<DateTime> completionDates, [DateTime? today]) {
    if (completionDates.isEmpty) return 0;

    final todayDate = normalize(today ?? DateTime.now());
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    final dateSet = completionDates.map((d) => normalize(d)).toSet();

    DateTime anchor;
    if (dateSet.contains(todayDate)) {
      anchor = todayDate;
    } else if (dateSet.contains(yesterdayDate)) {
      anchor = yesterdayDate;
    } else {
      return 0; // Streak broken
    }

    int streak = 0;
    DateTime check = anchor;
    while (dateSet.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates the best streak ever achieved from a list of completion dates
  static int calculateBestStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    final sorted = completionDates.map((d) => normalize(d)).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    int best = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];

      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        current++;
        if (current > best) {
          best = current;
        }
      } else if (diff > 1) {
        current = 1;
      }
    }

    return best;
  }

  /// Calculates weekly completion rate (last 7 days including today)
  static double calculateWeeklyRate(List<DateTime> completionDates, [DateTime? today]) {
    final todayDate = normalize(today ?? DateTime.now());
    final dateSet = completionDates.map((d) => normalize(d)).toSet();

    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = todayDate.subtract(Duration(days: i));
      if (dateSet.contains(day)) {
        count++;
      }
    }

    return count / 7.0;
  }

  /// Returns a list of 7 booleans indicating completion status for each of the last 7 days.
  /// Index 0 is 6 days ago, Index 6 is today.
  static List<bool> getLast7DaysStatus(List<DateTime> completionDates, [DateTime? today]) {
    final todayDate = normalize(today ?? DateTime.now());
    final dateSet = completionDates.map((d) => normalize(d)).toSet();

    final result = <bool>[];
    for (int i = 6; i >= 0; i--) {
      final day = todayDate.subtract(Duration(days: i));
      result.add(dateSet.contains(day));
    }
    return result;
  }

  /// Simulates habit trajectory if maintained daily for [days]
  static Map<String, dynamic> projectHabitImpact(Habit habit, int days) {
    final currentStreak = habit.getCurrentStreak();
    final projectedStreak = currentStreak + days;
    final totalCompletionsProjected = habit.completionDates.length + days;

    String stage;
    String stageEmoji;
    if (projectedStreak < 7) {
      stage = 'Sprout Seedling';
      stageEmoji = '🌱';
    } else if (projectedStreak < 21) {
      stage = 'Growing Sapling';
      stageEmoji = '🌿';
    } else if (projectedStreak < 60) {
      stage = 'Flourishing Tree';
      stageEmoji = '🌳';
    } else {
      stage = 'Golden Oak Habit';
      stageEmoji = '🌟';
    }

    return {
      'projectedDays': days,
      'projectedStreak': projectedStreak,
      'totalCompletions': totalCompletionsProjected,
      'growthStage': stage,
      'growthEmoji': stageEmoji,
      'message': 'If completed daily for $days days, your streak will reach $projectedStreak days.',
    };
  }
}
