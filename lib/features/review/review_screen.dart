import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/core/widgets/crow_mark.dart';
import 'package:flutter/material.dart';

/// Spaced-review entry point.
class ReviewScreen extends StatelessWidget {
  /// Creates the review screen.
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Wiederholen', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        const Text(
          'Schwaches Wissen kommt früher zurück. Starkes Wissen bekommt '
          'mehr Abstand.',
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              children: [
                CrowMark(size: 86),
                SizedBox(height: 16),
                Text(
                  'Noch nichts fällig',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Schließe deine erste Lektion ab. Danach plant CroLingo '
                  'passende Wiederholungen.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _ReviewOption(
          icon: Icons.schedule_rounded,
          title: 'Empfohlen & fällig',
        ),
        const _ReviewOption(
          icon: Icons.error_outline_rounded,
          title: 'Letzte Fehler',
        ),
        const _ReviewOption(
          icon: Icons.auto_awesome_outlined,
          title: 'Neu gelernt',
        ),
      ],
    );
  }
}

class _ReviewOption extends StatelessWidget {
  const _ReviewOption({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: false,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
