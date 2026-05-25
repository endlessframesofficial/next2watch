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
    final firestoreMoviesAsync = ref.watch(firestoreMoviesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from dashboard
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addCollection',
            onPressed: () => context.push(RoutePaths.addCollection),
            backgroundColor: Colors.blueAccent,
            icon: const Icon(Icons.playlist_add),
            label: const Text('Add Collection'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'addMovie',
            onPressed: () => context.push(RoutePaths.addMovie),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.movie),
            label: const Text('Add Movie'),
          ),
        ],
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
                    'My Movies',
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
              child: firestoreMoviesAsync.when(
                data: (movies) {
                  if (movies.isEmpty) {
                    return const Center(child: Text('No movies yet. Add some!'));
                  }
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
                        genre: movie.genres.isNotEmpty ? movie.genres.first : 'Movie',
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
