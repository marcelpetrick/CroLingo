import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';

/// The next ordered lesson a learner can start or resume.
class CoursePosition {
  /// Creates a stable position in the course hierarchy.
  const CoursePosition({
    required this.unit,
    required this.lesson,
    required this.unitNumber,
    required this.lessonNumber,
    required this.isResuming,
  });

  /// Unit containing the lesson.
  final CourseUnit unit;

  /// First incomplete lesson in course order.
  final Lesson lesson;

  /// One-based unit number for display.
  final int unitNumber;

  /// One-based lesson number inside the unit.
  final int lessonNumber;

  /// Whether a durable incomplete checkpoint exists.
  final bool isResuming;
}

/// Pure sequential progression rules shared by dashboard and path UI.
abstract final class CourseProgression {
  /// Returns the first incomplete lesson, or null when the course is complete.
  static CoursePosition? next(
    Course course,
    List<LessonProgress> progress,
  ) {
    final byLesson = {for (final item in progress) item.lessonId: item};
    for (var unitIndex = 0; unitIndex < course.units.length; unitIndex++) {
      final unit = course.units[unitIndex];
      for (
        var lessonIndex = 0;
        lessonIndex < unit.lessons.length;
        lessonIndex++
      ) {
        final lesson = unit.lessons[lessonIndex];
        final checkpoint = byLesson[lesson.id];
        if (checkpoint?.completedAt == null) {
          return CoursePosition(
            unit: unit,
            lesson: lesson,
            unitNumber: unitIndex + 1,
            lessonNumber: lessonIndex + 1,
            isResuming: checkpoint != null,
          );
        }
      }
    }
    return null;
  }
}
