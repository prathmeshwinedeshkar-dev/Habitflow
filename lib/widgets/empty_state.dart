import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Empty state widget shown when no habits are found
class EmptyState extends StatelessWidget {
  final VoidCallback onAddHabit;
  final String title;
  final String subtitle;
  final String buttonText;

  const EmptyState({
    super.key,
    required this.onAddHabit,
    this.title = 'No habits yet.',
    this.subtitle = 'Start with one tiny win.',
    this.buttonText = 'Add your first habit',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.darkSurfaceVariant,
                border: Border.all(color: AppTheme.darkBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryMint.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddHabit,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: const Color(0xFF062A1F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
