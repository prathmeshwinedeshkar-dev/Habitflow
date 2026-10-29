import 'package:flutter/material.dart';
import 'app.dart';
import 'providers/habit_provider.dart';

/// Application entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize central habit state and load persisted data
  final habitProvider = HabitProvider();
  await habitProvider.init();

  runApp(HabitFlowApp(provider: habitProvider));
}
