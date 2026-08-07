import 'package:crolingo/app/router.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Root application widget.
class CroLingoApp extends StatelessWidget {
  /// Creates the CroLingo application.
  const CroLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CroLingo',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
