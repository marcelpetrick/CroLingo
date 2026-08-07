import 'dart:io';

import 'package:crolingo/app/crolingo_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

// Coverage is provided at the widget/application boundary. Desktop plugin
// initialization is verified by platform builds and smoke tests.
// coverage:ignore-start
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(412, 915),
      minimumSize: Size(412, 915),
      maximumSize: Size(412, 915),
      center: true,
      title: 'CroLingo',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const ProviderScope(child: CroLingoApp()));
}

// coverage:ignore-end
