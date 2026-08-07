import 'dart:convert';
import 'dart:io';

import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/course/course_validator.dart';

void main() {
  const path = 'assets/content/course_de_hr.json';
  final source = File(path).readAsStringSync();
  final decoded = jsonDecode(source);
  if (decoded is! Map<String, Object?>) {
    stderr.writeln('$path must contain one JSON object.');
    exitCode = 1;
    return;
  }
  try {
    final course = Course.fromJson(decoded);
    final errors = CourseValidator.validate(course);
    if (errors.isNotEmpty) {
      stderr.writeln(errors.join('\n'));
      exitCode = 1;
      return;
    }
    final lessons = course.units.fold<int>(
      0,
      (sum, unit) => sum + unit.lessons.length,
    );
    stdout.writeln('Validated $path: $lessons lessons.');
  } on FormatException catch (error) {
    stderr.writeln('$path: $error');
    exitCode = 1;
  }
}
