import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/movie_card.dart';
import '../providers/home_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topRatedAsync = ref.watch(topRatedMoviesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from dashboard
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(RoutePaths.addMovie);
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Rated Movies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),

            // Horizontal ListView for Top Rated Movies
            SizedBox(
              height: 240, // Fixed height for horizontal list
              child: topRatedAsync.when(
                data: (movies) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        title: movie.title,
                        imageUrl: movie.fullPosterUrl,
                        rating: movie.voteAverage.toStringAsFixed(1),
                        genre: 'Movie', // TMDb genres require mapping IDs to names, keeping simple for now
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading movies:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
