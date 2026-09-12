import 'package:flutter/services.dart';

/// Reads the running application version.
///
/// `pubspec.yaml` is the project's only version source, so it is bundled and
/// parsed at runtime. Copying the value into generated Dart or a build-time
/// constant would create a second source that can silently drift from the one
/// the pipeline checks.
class AppVersion {
  /// Creates a reader using a replaceable asset bundle.
  new({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  static final _pattern = RegExp(r'^version:[ \t]*(\S+)', multiLine: true);

  /// Source bundle, replaceable in tests.
  final AssetBundle bundle;

  /// Loads the `name+build` version, or null when it cannot be read.
  ///
  /// A missing or malformed version is not worth crashing a lesson over, so
  /// the caller renders nothing instead.
  Future<String?> load() async {
    try {
      final source = await bundle.loadString('pubspec.yaml');
      return _pattern.firstMatch(source)?.group(1);
    } on Exception {
      return null;
    }
  }
}
