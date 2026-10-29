import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_storage_service.dart';

/// Central state management for HabitFlow using ChangeNotifier.
/// Simple, reactive, and easily explainable in interviews.
class HabitProvider extends ChangeNotifier {
  final HabitStorageService _storageService;

  List<Habit> _habits = [];
  bool _isLoading = true;
  bool _isDarkMode = true;
  String _userName = 'Friend';
  HabitCategory? _selectedCategoryFilter;

  HabitProvider({HabitStorageService? storageService})
      : _storageService = storageService ?? HabitStorageService();

  // Getters
  List<Habit> get allHabits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  HabitCategory? get selectedCategoryFilter => _selectedCategoryFilter;

  /// Filtered habits based on selected category tab
  List<Habit> get habits {
    if (_selectedCategoryFilter == null) {
      return List.unmodifiable(_habits);
    }
    return _habits
        .where((h) => h.category == _selectedCategoryFilter)
        .toList();
  }

  int get totalHabitsCount => _habits.length;

  int get completedTodayCount {
    return _habits.where((h) => h.isCompletedToday()).length;
  }

  int get pendingTodayCount {
    return totalHabitsCount - completedTodayCount;
  }

  double get todayCompletionRate {
    if (_habits.isEmpty) return 0.0;
    return completedTodayCount / totalHabitsCount;
  }

  /// Dynamic motivational quote based on completion rate
  String get motivationalMessage {
    if (_habits.isEmpty) {
      return 'Every big journey begins with a single tiny habit.';
    }
    final rate = todayCompletionRate;
    if (rate == 0.0) {
      return 'Start small. One action counts.';
    } else if (rate < 0.50) {
      return 'Momentum is building.';
    } else if (rate < 1.0) {
      return 'Almost there. Finish strong.';
    } else {
      return 'Perfect day. Your future self says thanks.';
    }
  }

  /// Best performing habit based on longest current streak or best streak
  Habit? get bestHabit {
    if (_habits.isEmpty) return null;
    Habit best = _habits.first;
    for (final h in _habits) {
      if (h.getCurrentStreak() > best.getCurrentStreak() ||
          (h.getCurrentStreak() == best.getCurrentStreak() &&
              h.getBestStreak() > best.getBestStreak())) {
        best = h;
      }
    }
    return best;
  }

  /// Habit that has been missed today or has low 7-day rate
  Habit? get habitNeedingAttention {
    if (_habits.isEmpty) return null;
    final uncompleted = _habits.where((h) => !h.isCompletedToday()).toList();
    if (uncompleted.isEmpty) return null;

    uncompleted.sort((a, b) {
      final rateA = a.getCompletionRateForLast7Days();
      final rateB = b.getCompletionRateForLast7Days();
      return rateA.compareTo(rateB);
    });

    return uncompleted.first;
  }

  /// Total completion count across all habits of all time
  int get totalCompletionsAllTime {
    int total = 0;
    for (final h in _habits) {
      total += h.completionDates.length;
    }
    return total;
  }

  /// Highest active streak across all habits
  int get longestStreakAcrossHabits {
    if (_habits.isEmpty) return 0;
    int maxStreak = 0;
    for (final h in _habits) {
      final s = h.getCurrentStreak();
      if (s > maxStreak) {
        maxStreak = s;
      }
    }
    return maxStreak;
  }

  /// Category breakdown completion rate
  Map<HabitCategory, double> get categoryCompletionRates {
    final map = <HabitCategory, double>{};
    for (final cat in HabitCategory.values) {
      final list = _habits.where((h) => h.category == cat).toList();
      if (list.isEmpty) continue;
      final completed = list.where((h) => h.isCompletedToday()).length;
      map[cat] = completed / list.length;
    }
    return map;
  }

  /// Initialize provider by loading persistent data
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _habits = await _storageService.loadHabits();
    _isDarkMode = await _storageService.loadDarkMode();
    _userName = await _storageService.loadUserName();

    _isLoading = false;
    notifyListeners();
  }

  /// Set category filter (null for All)
  void setCategoryFilter(HabitCategory? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  /// Check if a habit name is a duplicate
  bool isTitleDuplicate(String title, [String? excludeHabitId]) {
    final clean = title.trim().toLowerCase();
    return _habits.any((h) =>
        h.id != excludeHabitId && h.title.trim().toLowerCase() == clean);
  }

  /// Add a new habit and persist
  Future<void> addHabit(Habit habit) async {
    _habits.insert(0, habit);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index >= 0) {
      _habits[index] = updatedHabit;
      notifyListeners();
      await _storageService.saveHabits(_habits);
    }
  }

  /// Toggle habit completion for today
  Future<void> toggleHabitCompletion(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index >= 0) {
      final current = _habits[index];
      _habits[index] = current.toggleCompletionForToday();
      notifyListeners();
      await _storageService.saveHabits(_habits);
    }
  }

  /// Delete habit with given ID
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
    await _storageService.saveHabits(_habits);
  }

  /// Toggle Theme mode
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await _storageService.saveDarkMode(isDark);
  }

  /// Update User Name
  Future<void> setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'Friend' : name.trim();
    notifyListeners();
    await _storageService.saveUserName(_userName);
  }

  /// Reset all data
  Future<void> resetAllData() async {
    _habits = [];
    _userName = 'Friend';
    _isDarkMode = true;
    _selectedCategoryFilter = null;
    notifyListeners();
    await _storageService.clearAllData();
  }

  /// Export JSON string
  Future<String> exportDataAsJson() async {
    return await _storageService.exportHabitsJson();
  }
}
