import 'package:crolingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Phone-first navigation shell shared by Android and Linux.
class CroLingoShell extends StatelessWidget {
  /// Creates the navigation shell.
  const new({required this.location, required this.child, super.key});

  /// Current route path.
  final String location;

  /// Active route content.
  final Widget child;

  static const _locations = ['/', '/path', '/review', '/more'];

  @override
  Widget build(BuildContext context) {
    final exactIndex = _locations.indexOf(location);
    final index = exactIndex >= 0
        ? exactIndex
        : _locations.indexWhere(
            (candidate) => candidate != '/' && location.startsWith(candidate),
          );
    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.palette.selectedSurface.withValues(alpha: 0.55),
                context.palette.background,
              ],
              stops: const [0, 0.38],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.surface,
          border: Border(top: BorderSide(color: context.palette.border)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox(
              width: double.infinity,
              child: NavigationBar(
                selectedIndex: index < 0 ? 0 : index,
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
            ),
          ),
        ),
      ),
    );
  }
}
