import 'dart:convert';

import 'package:crolingo/domain/course/course.dart';
import 'package:flutter/services.dart';

/// Loads the immutable course bundled with the application.
class AssetCourseRepository {
  /// Creates a repository using a replaceable asset bundle.
  AssetCourseRepository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  /// Source bundle, replaceable in tests.
  final AssetBundle bundle;

  /// Loads and parses the German-to-Croatian course.
  Future<Course> load() async {
    final source = await bundle.loadString(
      'assets/content/course_de_hr.json',
    );
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Course asset must be a JSON object');
    }
    return Course.fromJson(decoded);
  }
}
