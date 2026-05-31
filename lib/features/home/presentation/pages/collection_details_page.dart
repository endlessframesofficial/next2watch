import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CollectionDetailsPageState extends ConsumerState<CollectionDetailsPage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  double _scrollRatio = 0.0;
  late AnimationController _revealController;

  // Cinematic frames for the Marvel-style flipping intro
  final List<String> _revealPosterUrls = [
    'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&fit=crop', // Cinema camera
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=400&fit=crop', // Theater seats
    'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=400&fit=crop', // Projector
    'https://images.unsplash.com/photo-1542204172-e7052809a86e?w=400&fit=crop', // Movie reel
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=400&fit=crop', // Clapboard
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _revealController.forward();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final double statusBarHeight = MediaQuery.of(context).padding.top;
      final double maxOffset = 240.0 - kToolbarHeight - statusBarHeight;
      final double ratio = (offset / (maxOffset > 0 ? maxOffset : 1.0)).clamp(0.0, 1.0);
      if (ratio != _scrollRatio) {
        setState(() {
          _scrollRatio = ratio;
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
    final titleOpacity = (_scrollRatio > 0.6) ? ((_scrollRatio - 0.6) / 0.4) : 0.0;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240.0,
            pinned: true,
            stretch: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: _scrollRatio > 0.5
                  ? (Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark)
                  : Brightness.light,
              statusBarBrightness: _scrollRatio > 0.5
                  ? (Theme.of(context).brightness == Brightness.dark ? Brightness.dark : Brightness.light)
                  : Brightness.dark,
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3 * (1.0 - _scrollRatio)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Color.lerp(
                      Colors.white,
                      Theme.of(context).colorScheme.onSurface,
                      _scrollRatio,
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Color.lerp(
              Colors.transparent,
              Theme.of(context).scaffoldBackgroundColor,
              _scrollRatio,
            ),
            elevation: _scrollRatio > 0.9 ? 1 : 0,
            title: Opacity(
              opacity: titleOpacity,
              child: Text(
                widget.collection.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _revealController,
                builder: (context, child) {
                  final double progress = _revealController.value;
                  final bool isResolved = progress >= 0.7;

                  // Cycle through cinematic Unsplash image placeholders (12 frames per second)
                  final int frameIndex = (progress * 12).floor() % _revealPosterUrls.length;
                  final currentRevealFrame = _revealPosterUrls[frameIndex];

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Base layer: flipping cinematic images
                      if (!isResolved)
                        Image.network(
                          currentRevealFrame,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackBackground(context),
                        ),

                      // 2. Final resolved image layer fading in
                      Opacity(
                        opacity: isResolved ? ((progress - 0.7) / 0.3).clamp(0.0, 1.0) : 0.0,
                        child: widget.collection.banner.isNotEmpty
                            ? Hero(
                                tag: 'collection_banner_${widget.collection.id}',
                                child: Image.network(
                                  widget.collection.banner,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackBackground(context),
                                ),
                              )
                            : Hero(
                                tag: 'collection_banner_${widget.collection.id}',
                                child: _buildFallbackBackground(context),
                              ),
                      ),

                      // 3. Dark gradient overlay for text and leading icon readability
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
                  // Custom Positioned large title layout
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Opacity(
                      opacity: (1.0 - _scrollRatio).clamp(0.0, 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'COLLECTION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.collection.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 8.0,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.collection.movieIds.length} Human-Curated Titles',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4.0,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
