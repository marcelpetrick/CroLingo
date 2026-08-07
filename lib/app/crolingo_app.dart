import 'package:crolingo/app/providers.dart';
import 'package:crolingo/app/router.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
class CroLingoApp extends ConsumerWidget {
  /// Creates the CroLingo application.
  const CroLingoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start the persistent settings stream before any lesson is opened.
    ref.watch(appSettingsProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CroLingo',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
