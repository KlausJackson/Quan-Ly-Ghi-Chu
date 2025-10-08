import 'package:go_router/go_router.dart';
import 'package:notes/core/routing/app_routes.dart';
import 'package:notes/features/notes/presentation/pages/home_page.dart';
import 'package:notes/features/notes/presentation/pages/trash_page.dart';

class AppGoRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(path: AppRoutes.trash,
        builder: (context,state) => const TrashPage(),
        ),
    ],
  );
}