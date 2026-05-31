import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/movie_card.dart';
import '../../domain/entities/movie_collection.dart';
import '../providers/home_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(firestoreCollectionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from dashboard
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton.extended(
      //       heroTag: 'addCollection',
      //       onPressed: () => context.push(RoutePaths.addCollection),
      //       backgroundColor: Colors.blueAccent,
      //       icon: const Icon(Icons.playlist_add),
      //       label: const Text('Add Collection'),
      //     ),
      //     const SizedBox(height: 16),
      //     FloatingActionButton.extended(
      //       heroTag: 'addMovie',
      //       onPressed: () => context.push(RoutePaths.addMovie),
      //       backgroundColor: Colors.orange,
      //       icon: const Icon(Icons.movie),
      //       label: const Text('Add Movie'),
      //     ),
      //   ],
      // ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'Next2Watch',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.orange[800] ?? Colors.orange,
              ),
            ),
            centerTitle: false,
          ),
          collectionsAsync.when(
            data: (collections) {
              if (collections.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No collections found.\nUse the action buttons below to add collections or trigger the seeder!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final collection = collections[index];
                      return _CollectionRow(collection: collection);
                    },
                    childCount: collections.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading collections:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionRow extends ConsumerWidget {
  final MovieCollection collection;

  const _CollectionRow({required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(collectionMoviesProvider(collection.movieIds));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collection Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push(
                  RoutePaths.collectionDetails,
                  extra: collection,
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),

        // Movies List
        SizedBox(
          height: 260,
          child: moviesAsync.when(
            data: (movies) {
              if (movies.isEmpty) {
                return Center(
                  child: Text(
                    'No movies found in this collection.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    rank: index + 1,
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading movies in collection.',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
