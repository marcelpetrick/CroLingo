import 'package:crolingo/core/motion/app_motion.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Vocabulary, grammar, profile, and settings hub.
class MoreScreen extends StatelessWidget {
  /// Creates the More screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        MotionEntrance(
          child: Text('Mehr', style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: 20),
        MotionEntrance(
          delay: const Duration(milliseconds: 45),
          child: _MoreTile(
            icon: Icons.menu_book_rounded,
            title: 'Wortschatz',
            subtitle: 'Deine gelernten Wörter',
            onTap: () => context.push('/more/vocabulary'),
          ),
        ),
        const MotionEntrance(
          delay: Duration(milliseconds: 90),
          child: _MoreTile(
            icon: Icons.account_tree_outlined,
            title: 'Grammatik',
            subtitle: 'Bereits eingeführte Regeln',
          ),
        ),
        MotionEntrance(
          delay: const Duration(milliseconds: 135),
          child: _MoreTile(
            icon: Icons.bar_chart_rounded,
            title: 'Profil & Statistik',
            subtitle: 'Fortschritt, XP und Lerntage',
            onTap: () => context.push('/more/profile'),
          ),
        ),
        MotionEntrance(
          delay: const Duration(milliseconds: 180),
          child: _MoreTile(
            icon: Icons.settings_outlined,
            title: 'Einstellungen',
            subtitle: 'Darstellung, Bewegung und Feedback',
            onTap: () => context.push('/more/settings'),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Offline · Keine Werbung · Keine Herzen',
            style: TextStyle(color: context.palette.slate),
          ),
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const new({
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
    final enabled = onTap != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(
          icon,
          color: enabled ? context.palette.primary : context.palette.slate,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: !enabled
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.palette.selectedSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Bald',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
