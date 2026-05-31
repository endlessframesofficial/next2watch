import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/movie_card.dart';
import '../../domain/entities/movie_collection.dart';
import '../providers/home_providers.dart';
import '../widgets/curator_note_banner.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  late ScrollController _scrollController;
  double _scrollRatio = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final double ratio = (offset / 50.0).clamp(0.0, 1.0);
      if (ratio != _scrollRatio) {
        setState(() {
          _scrollRatio = ratio;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(firestoreCollectionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from dashboard
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Color.lerp(
              Colors.transparent,
              Theme.of(context).scaffoldBackgroundColor,
              _scrollRatio,
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            title: Text(
              'Next2Watch',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.orange[800] ?? Colors.orange,
              ),
            ),
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08 * _scrollRatio),
                height: 1,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: CuratorNoteBanner(),
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
