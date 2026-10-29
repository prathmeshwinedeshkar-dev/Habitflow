import 'package:flutter/material.dart';

/// Supported habit categories
enum HabitCategory {
  health,
  study,
  fitness,
  mindfulness,
  productivity,
  personal,
  custom;

  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.study:
        return 'Study';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.personal:
        return 'Personal';
      case HabitCategory.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitCategory.health:
        return Icons.favorite_rounded;
      case HabitCategory.study:
        return Icons.menu_book_rounded;
      case HabitCategory.fitness:
        return Icons.fitness_center_rounded;
      case HabitCategory.mindfulness:
        return Icons.self_improvement_rounded;
      case HabitCategory.productivity:
        return Icons.bolt_rounded;
      case HabitCategory.personal:
        return Icons.person_rounded;
      case HabitCategory.custom:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case HabitCategory.health:
        return const Color(0xFFF43F5E); // Rose
      case HabitCategory.study:
        return const Color(0xFF3B82F6); // Blue
      case HabitCategory.fitness:
        return const Color(0xFF10B981); // Emerald
      case HabitCategory.mindfulness:
        return const Color(0xFF8B5CF6); // Purple
      case HabitCategory.productivity:
        return const Color(0xFFF59E0B); // Amber
      case HabitCategory.personal:
        return const Color(0xFFEC4899); // Pink
      case HabitCategory.custom:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  static HabitCategory fromString(String? name) {
    if (name == null) return HabitCategory.personal;
    return HabitCategory.values.firstWhere(
      (c) =>
          c.name.toLowerCase() == name.toLowerCase() ||
          c.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => HabitCategory.personal,
    );
  }
}

/// OOP Habit Model representing a user habit, its schedule, and completion history.
/// Demonstrates encapsulation with private backing list [_completionDates],
/// immutable getters, copyWith pattern, and domain logic methods.
class Habit {
  final String id;
  final String title;
  final String emoji;
  final HabitCategory category;
  final DateTime createdAt;
  final String? reminderTime;
  final bool isActive;
  final int targetPerDay;

  // Encapsulated private completion dates list to prevent unvetted mutation
  final List<DateTime> _completionDates;

  /// Default constructor with named parameters
  Habit({
    required this.id,
    required String title,
    String emoji = '⚡',
    this.category = HabitCategory.productivity,
    DateTime? createdAt,
    List<DateTime>? completionDates,
    this.reminderTime,
    this.isActive = true,
    int targetPerDay = 1,
  })  : title = title.trim(),
        emoji = emoji.trim().isEmpty ? '⚡' : emoji.trim(),
        createdAt = createdAt ?? DateTime.now(),
        _completionDates = _normalizeDateList(completionDates ?? []),
        targetPerDay = targetPerDay > 0 ? targetPerDay : 1;

  /// Read-only unmodifiable view of completion dates
  List<DateTime> get completionDates => List.unmodifiable(_completionDates);

  /// Normalize a DateTime to YYYY-MM-DD (zeroing hours/minutes/seconds)
  static DateTime normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Helper to ensure date list contains only unique normalized dates sorted chronologically
  static List<DateTime> _normalizeDateList(List<DateTime> dates) {
    final set = <String, DateTime>{};
    for (final d in dates) {
      final norm = normalizeDate(d);
      final key = '${norm.year}-${norm.month}-${norm.day}';
      set[key] = norm;
    }
    final sorted = set.values.toList()..sort((a, b) => a.compareTo(b));
    return sorted;
  }

  /// Checks if this habit has been completed today
  bool isCompletedToday([DateTime? now]) {
    final targetDate = normalizeDate(now ?? DateTime.now());
    return _completionDates.any((d) =>
        d.year == targetDate.year &&
        d.month == targetDate.month &&
        d.day == targetDate.day);
  }

  /// Toggles completion status for today (or specified date) and returns a new updated Habit
  Habit toggleCompletionForToday([DateTime? now]) {
    final targetDate = normalizeDate(now ?? DateTime.now());
    final updatedList = List<DateTime>.from(_completionDates);

    final existingIndex = updatedList.indexWhere((d) =>
        d.year == targetDate.year &&
        d.month == targetDate.month &&
        d.day == targetDate.day);

    if (existingIndex >= 0) {
      updatedList.removeAt(existingIndex);
    } else {
      updatedList.add(targetDate);
    }

    return copyWith(completionDates: updatedList);
  }

  /// Calculates the current consecutive day streak.
  /// If completed today, streak counts today + previous consecutive days.
  /// If not yet completed today, streak counts consecutive days ending yesterday.
  /// If yesterday was also missed, streak is 0.
  int getCurrentStreak([DateTime? now]) {
    if (_completionDates.isEmpty) return 0;

    final today = normalizeDate(now ?? DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    final dateSet = _completionDates.map((d) => normalizeDate(d)).toSet();

    // Determine the anchor day to count backwards from
    DateTime anchor;
    if (dateSet.contains(today)) {
      anchor = today;
    } else if (dateSet.contains(yesterday)) {
      anchor = yesterday;
    } else {
      return 0; // Missed yesterday and today
    }

    int streak = 0;
    DateTime checkDay = anchor;

    while (dateSet.contains(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates the all-time best consecutive streak
  int getBestStreak() {
    if (_completionDates.isEmpty) return 0;

    final sorted = List<DateTime>.from(_completionDates)..sort();
    int bestStreak = 1;
    int currentRun = 1;

    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];

      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        currentRun++;
        if (currentRun > bestStreak) {
          bestStreak = currentRun;
        }
      } else if (diff > 1) {
        currentRun = 1;
      }
    }

    return bestStreak;
  }

  /// Calculates the completion rate over the last 7 days (0.0 to 1.0)
  double getCompletionRateForLast7Days([DateTime? now]) {
    final today = normalizeDate(now ?? DateTime.now());
    final dateSet = _completionDates.map((d) => normalizeDate(d)).toSet();

    int completed = 0;
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      if (dateSet.contains(day)) {
        completed++;
      }
    }

    return completed / 7.0;
  }

  /// Creates a copy of this habit with updated fields
  Habit copyWith({
    String? id,
    String? title,
    String? emoji,
    HabitCategory? category,
    DateTime? createdAt,
    List<DateTime>? completionDates,
    String? reminderTime,
    bool? isActive,
    int? targetPerDay,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      completionDates: completionDates ?? _completionDates,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      targetPerDay: targetPerDay ?? this.targetPerDay,
    );
  }

  /// Serialize to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'completionDates':
          _completionDates.map((d) => d.toIso8601String()).toList(),
      'reminderTime': reminderTime,
      'isActive': isActive,
      'targetPerDay': targetPerDay,
    };
  }

  /// Deserialize from JSON Map
  factory Habit.fromJson(Map<String, dynamic> json) {
    final datesList = (json['completionDates'] as List<dynamic>?)
            ?.map((e) => DateTime.tryParse(e.toString()))
            .whereType<DateTime>()
            .toList() ??
        [];

    return Habit(
      id: json['id'] as String? ?? UniqueKey().toString(),
      title: json['title'] as String? ?? 'Untitled Habit',
      emoji: json['emoji'] as String? ?? '⚡',
      category: HabitCategory.fromString(json['category'] as String?),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      completionDates: datesList,
      reminderTime: json['reminderTime'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      targetPerDay: json['targetPerDay'] as int? ?? 1,
    );
  }
}
