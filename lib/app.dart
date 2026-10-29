import 'package:flutter/material.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

/// Root Application Widget configuring theme mode, navigation scaffold,
/// and reactive updates from the HabitProvider.
class HabitFlowApp extends StatelessWidget {
  final HabitProvider provider;

  const HabitFlowApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'HabitFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainNavigationScaffold(provider: provider),
        );
      },
    );
  }
}

/// Main Shell holding bottom navigation tabs: Today, Insights, and Settings.
class MainNavigationScaffold extends StatefulWidget {
  final HabitProvider provider;

  const MainNavigationScaffold({super.key, required this.provider});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(provider: widget.provider),
      InsightsScreen(provider: widget.provider),
      SettingsScreen(provider: widget.provider),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.darkBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Theme.of(context).cardTheme.color,
          indicatorColor: AppTheme.primaryMint.withValues(alpha: 0.2),
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded),
              selectedIcon: Icon(Icons.check_circle_rounded,
                  color: AppTheme.primaryMint),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded,
                  color: AppTheme.primaryMint),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded,
                  color: AppTheme.primaryMint),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
