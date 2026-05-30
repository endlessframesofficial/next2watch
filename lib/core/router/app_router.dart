import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/add_movie_page.dart';
import '../../features/home/presentation/pages/add_collection_page.dart';
import '../../features/home/presentation/pages/collection_details_page.dart';
import '../../features/home/domain/entities/movie_collection.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.addMovie,
        name: RouteNames.addMovie,
        builder: (context, state) => const AddMoviePage(),
      ),
      GoRoute(
        path: RoutePaths.addCollection,
        name: RouteNames.addCollection,
        builder: (context, state) => const AddCollectionPage(),
      ),
      GoRoute(
        path: RoutePaths.collectionDetails,
        name: RouteNames.collectionDetails,
        builder: (context, state) {
          final collection = state.extra as MovieCollection;
          return CollectionDetailsPage(collection: collection);
        },
      ),
      // Add more routes here
    ],
  );
});
