import 'package:crolingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Phone-first navigation shell shared by Android and Linux.
class CroLingoShell extends StatelessWidget {
  /// Creates the navigation shell.
  const CroLingoShell({
    required this.location,
    required this.child,
    super.key,
  });

  /// Current route path.
  final String location;

  /// Active route content.
  final Widget child;

  static const _locations = ['/', '/path', '/review', '/more'];

  @override
  Widget build(BuildContext context) {
    final index = _locations.indexOf(location);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        indicatorColor: AppColors.selectedSurface,
        onDestinationSelected: (value) => context.go(_locations[value]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Start',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Lernweg',
          ),
          NavigationDestination(
            icon: Icon(Icons.refresh_outlined),
            selectedIcon: Icon(Icons.refresh_rounded),
            label: 'Üben',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Mehr',
          ),
        ],
      ),
    );
  }
}
