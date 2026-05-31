import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/movie_card.dart';
import '../../domain/entities/movie_collection.dart';
import '../providers/home_providers.dart';

class CollectionDetailsPage extends ConsumerStatefulWidget {
  final MovieCollection collection;

  const CollectionDetailsPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends ConsumerState<CollectionDetailsPage> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

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
      final isCollapsed = offset > (240 - kToolbarHeight - MediaQuery.of(context).padding.top);
      if (isCollapsed != _isCollapsed) {
        setState(() {
          _isCollapsed = isCollapsed;
        });
      }
    }
  }

  Widget _buildFallbackBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[850]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.movie,
        color: Colors.white.withOpacity(0.08),
        size: 72,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moviesAsync = ref.watch(collectionMoviesProvider(widget.collection.movieIds));

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240.0,
            pinned: true,
            stretch: true,
            iconTheme: IconThemeData(
              color: _isCollapsed
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.white,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: _isCollapsed ? 1 : 0,
            title: _isCollapsed
                ? Text(
                    widget.collection.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              title: _isCollapsed
                  ? null
                  : Text(
                      widget.collection.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 6.0,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 48),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.collection.banner.isNotEmpty)
                    Hero(
                      tag: 'collection_banner_${widget.collection.id}',
                      child: Image.network(
                        widget.collection.banner,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackBackground(context),
                      ),
                    )
                  else
                    Hero(
                      tag: 'collection_banner_${widget.collection.id}',
                      child: _buildFallbackBackground(context),
                    ),
                  // Dark gradient overlay for text and leading icon readability
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          moviesAsync.when(
            data: (movies) {
              if (movies.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No movies in this collection.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 140 / 230,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        title: movie.title,
                        imageUrl: movie.fullPosterUrl,
                        rating: movie.voteAverage.toStringAsFixed(1),
                        genre: movie.genres.isNotEmpty ? movie.genres.first : 'Movie',
                        rank: index + 1,
                        margin: EdgeInsets.zero,
                      );
                    },
                    childCount: movies.length,
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
                    'Error loading movies:\n$error',
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
