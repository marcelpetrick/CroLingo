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
    final window = WindowManager.instance.getCurrent();
    if (window == null) {
      throw StateError('The Linux application window is unavailable.');
    }
    final size = const Size(412, 915).toNative();
    window
      ..setSize(size, false)
      ..minimumSize = size
      ..maximumSize = size
      ..title = 'CroLingo'
      ..center()
      ..show()
      ..focus();
  }
  runApp(const ProviderScope(child: CroLingoApp()));
}

// coverage:ignore-end
