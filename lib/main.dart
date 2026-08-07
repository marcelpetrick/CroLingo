import 'package:flutter/material.dart';

void main() => runApp(const CroLingoApp());

/// Root widget for CroLingo.
class CroLingoApp extends StatelessWidget {
  /// Creates the CroLingo application.
  const CroLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CroLingo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769D2)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('CroLingo')),
      ),
    );
  }
}
