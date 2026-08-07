import 'package:crolingo/app/providers.dart';
import 'package:crolingo/app/shell/crolingo_shell.dart';
import 'package:crolingo/features/home/home_screen.dart';
import 'package:crolingo/features/lesson/lesson_screen.dart';
import 'package:crolingo/features/more/more_screen.dart';
import 'package:crolingo/features/path/learning_path_screen.dart';
import 'package:crolingo/features/profile/profile_screen.dart';
import 'package:crolingo/features/review/review_screen.dart';
import 'package:crolingo/features/vocabulary/vocabulary_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shared application router.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/lesson/:lessonId',
      builder: (context, state) => Consumer(
        builder: (context, ref, child) => LessonScreen(
          lessonId: state.pathParameters['lessonId']!,
          repository: ref.read(progressRepositoryProvider),
        ),
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
        GoRoute(
          path: '/more/vocabulary',
          builder: _vocabulary,
        ),
        GoRoute(path: '/more/profile', builder: _profile),
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

Widget _vocabulary(BuildContext context, GoRouterState state) =>
    const VocabularyScreen();

Widget _profile(BuildContext context, GoRouterState state) =>
    const ProfileScreen();
