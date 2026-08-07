import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Learner dashboard and continuation entry point.
class HomeScreen extends StatelessWidget {
  /// Creates the dashboard.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const _Header(),
        const SizedBox(height: 24),
        Text(
          'Bok! Bereit für Kroatisch?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Kleine Schritte, klare Antworten und so viele Versuche, '
          'wie du brauchst.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flag_rounded, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text('Einheit 1 · Erste Worte'),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Begrüßen', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('Lerne „bok“ und „dobar dan“ kennen.'),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.go('/path'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Lernweg öffnen'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _Stats(),
      ],
    );
  }
}

class _Stats extends ConsumerWidget {
  const _Stats();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<LearningStats>(
        future: ref.read(progressRepositoryProvider).loadStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data;
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '${stats?.currentStreak ?? 0}',
                  label: 'Tage Serie',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  value: '${stats?.totalXp ?? 0}',
                  label: 'XP',
                ),
              ),
            ],
          );
        },
      );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CrowMark(size: 58),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CroLingo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            Text(
              'Deutsch → Hrvatski',
              style: TextStyle(color: AppColors.slate),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
