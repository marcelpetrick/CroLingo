import 'package:crolingo/app/shell/crolingo_shell.dart';
import 'package:crolingo/features/home/home_screen.dart';
import 'package:crolingo/features/lesson/lesson_screen.dart';
import 'package:crolingo/features/more/more_screen.dart';
import 'package:crolingo/features/path/learning_path_screen.dart';
import 'package:crolingo/features/review/review_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Shared application router.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/lesson/:lessonId',
      builder: (context, state) => LessonScreen(
        lessonId: state.pathParameters['lessonId']!,
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => CroLingoShell(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: '/', builder: _home),
        GoRoute(path: '/path', builder: _path),
        GoRoute(path: '/review', builder: _review),
        GoRoute(path: '/more', builder: _more),
      ],
    ),
  ],
);

Widget _home(BuildContext context, GoRouterState state) => const HomeScreen();

Widget _path(BuildContext context, GoRouterState state) =>
    const LearningPathScreen();

Widget _review(BuildContext context, GoRouterState state) =>
    const ReviewScreen();

Widget _more(BuildContext context, GoRouterState state) => const MoreScreen();
