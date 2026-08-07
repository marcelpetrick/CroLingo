import 'package:crolingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        _MoreTile(
          icon: Icons.menu_book_rounded,
          title: 'Wortschatz',
          subtitle: 'Deine gelernten Wörter',
          onTap: () => context.push('/more/vocabulary'),
        ),
        const _MoreTile(
          icon: Icons.account_tree_outlined,
          title: 'Grammatik',
          subtitle: 'Bereits eingeführte Regeln',
        ),
        _MoreTile(
          icon: Icons.bar_chart_rounded,
          title: 'Profil & Statistik',
          subtitle: 'Fortschritt, XP und Lerntage',
          onTap: () => context.push('/more/profile'),
        ),
        _MoreTile(
          icon: Icons.settings_outlined,
          title: 'Einstellungen',
          subtitle: 'Darstellung, Bewegung und Feedback',
          onTap: () => context.push('/more/settings'),
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
