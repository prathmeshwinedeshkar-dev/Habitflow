import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

/// Service managing persistent local storage with SharedPreferences.
/// Completely offline and privacy-first.
class HabitStorageService {
  static const String _keyHabits = 'habitflow_habits_v1';
  static const String _keyThemeDark = 'habitflow_is_dark_theme';
  static const String _keyUserName = 'habitflow_user_name';
  static const String _keyFirstRun = 'habitflow_is_first_run';

  /// Loads habits from SharedPreferences.
  /// If it is the user's first launch, populates starter habits.
  Future<List<Habit>> loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isFirstRun = prefs.getBool(_keyFirstRun) ?? true;
      if (isFirstRun) {
        final starterHabits = _getStarterHabits();
        await saveHabits(starterHabits);
        await prefs.setBool(_keyFirstRun, false);
        return starterHabits;
      }

      final rawString = prefs.getString(_keyHabits);
      if (rawString == null || rawString.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(rawString);
      if (decoded is List) {
        return decoded
            .map((item) => Habit.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      // In case of any corrupt data, return empty list gracefully without crashing
      return [];
    }
  }

  /// Persists the list of habits to local storage immediately
  Future<bool> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = habits.map((h) => h.toJson()).toList();
      final rawString = jsonEncode(jsonList);
      return await prefs.setString(_keyHabits, rawString);
    } catch (e) {
      return false;
    }
  }

  /// Loads theme preference (defaults to dark mode true)
  Future<bool> loadDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyThemeDark) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Saves theme preference
  Future<bool> saveDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_keyThemeDark, isDark);
    } catch (e) {
      return false;
    }
  }

  /// Loads optional user name (defaults to 'Friend')
  Future<String> loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName) ?? 'Friend';
    } catch (e) {
      return 'Friend';
    }
  }

  /// Saves user name
  Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyUserName, name.trim());
    } catch (e) {
      return false;
    }
  }

  /// Exports all habits as pretty-printed JSON text
  Future<String> exportHabitsJson() async {
    final habits = await loadHabits();
    final jsonList = habits.map((h) => h.toJson()).toList();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'app': 'HabitFlow',
      'exportedAt': DateTime.now().toIso8601String(),
      'habitCount': habits.length,
      'habits': jsonList,
    });
  }

  /// Clears all local data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHabits);
      await prefs.remove(_keyThemeDark);
      await prefs.remove(_keyUserName);
      await prefs.setBool(_keyFirstRun, false); // Do not re-seed sample habits on explicit reset
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Thoughtful starter habits for a student/young professional on first launch
  List<Habit> _getStarterHabits() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    return [
      Habit(
        id: 'starter_water',
        title: 'Drink 2L Water',
        emoji: '💧',
        category: HabitCategory.health,
        createdAt: twoDaysAgo,
        completionDates: [twoDaysAgo, yesterday],
        reminderTime: '08:00 AM',
        targetPerDay: 1,
      ),
      Habit(
        id: 'starter_reading',
        title: 'Read 20 Mins',
        emoji: '📚',
        category: HabitCategory.study,
        createdAt: twoDaysAgo,
        completionDates: [twoDaysAgo, yesterday],
        reminderTime: '09:00 PM',
        targetPerDay: 1,
      ),
      Habit(
        id: 'starter_code',
        title: 'Review 1 Code Concept',
        emoji: '💻',
        category: HabitCategory.productivity,
        createdAt: twoDaysAgo,
        completionDates: [twoDaysAgo],
        reminderTime: '11:00 AM',
        targetPerDay: 1,
      ),
      Habit(
        id: 'starter_meditate',
        title: '5-Minute Mindful Breathing',
        emoji: '🧘',
        category: HabitCategory.mindfulness,
        createdAt: now,
        completionDates: [],
        reminderTime: '07:30 AM',
        targetPerDay: 1,
      ),
    ];
  }
}
