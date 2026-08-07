import 'package:crolingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Vocabulary, grammar, profile, and settings hub.
class MoreScreen extends StatelessWidget {
  /// Creates the More screen.
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Mehr', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        const _MoreTile(
          icon: Icons.menu_book_rounded,
          title: 'Wortschatz',
          subtitle: 'Deine gelernten Wörter',
        ),
        const _MoreTile(
          icon: Icons.account_tree_outlined,
          title: 'Grammatik',
          subtitle: 'Bereits eingeführte Regeln',
        ),
        const _MoreTile(
          icon: Icons.bar_chart_rounded,
          title: 'Profil & Statistik',
          subtitle: 'Fortschritt, XP und Lerntage',
        ),
        const _MoreTile(
          icon: Icons.settings_outlined,
          title: 'Einstellungen',
          subtitle: 'Darstellung, Bewegung und Feedback',
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Offline · Keine Werbung · Keine Herzen',
            style: TextStyle(color: AppColors.slate),
          ),
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
