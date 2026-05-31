import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoResolve; // Fading from flipping posters to solid deep orange-red
  late Animation<double> _subTitleFade; // Subtitle "INDEPENDENT" slide & fade
  late Animation<double> _bgThemeFade; // Screen background from dark to light

  // Cinematic masterpiece poster URLs (curated movie-related placeholders)
  final List<String> _posterUrls = [
    'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&fit=crop', // Cinema camera
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=400&fit=crop', // Theater seats
    'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=400&fit=crop', // Projector
    'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=400&fit=crop', // Lens
    'https://images.unsplash.com/photo-1542204172-e7052809a86e?w=400&fit=crop', // Movie reel
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=400&fit=crop', // Clapboard
    'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=400&fit=crop', // Popcorn
    'https://images.unsplash.com/photo-1598899134739-24c46f58b8c0?w=400&fit=crop', // Retro cinema
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoResolve = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );

    _subTitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.95, curve: Curves.easeOut),
      ),
    );

    _bgThemeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start the intro animation
    _controller.forward();

    // Navigate to dashboard on completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.go(RoutePaths.dashboard);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Smoothly transition background from Cinema Black to Scaffold Light Theme
        final bgColor = Color.lerp(
          const Color(0xFF070B14),
          theme.scaffoldBackgroundColor,
          _bgThemeFade.value,
        )!;

        // Rapidly cycle indices for poster frames (12 frames per second during intro)
        final int frameIndex = (_controller.value * 28).floor() % _posterUrls.length;
        final currentPoster = _posterUrls[frameIndex];

        return Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // MARVEL style "NEXT2WATCH" Main Box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3 * (1.0 - _bgThemeFade.value) + 0.1 * _bgThemeFade.value),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Rapidly Flipping Cinematic Background Images
                          Positioned.fill(
                            child: Image.network(
                              currentPoster,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.movie_creation_outlined,
                                  color: Colors.white24,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          // 2. Dark overlay for image contrast
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.35),
                            ),
                          ),
                          // 3. Fading Solid Deep Orange-Red Overlay (The Logo Resolving phase)
                          Positioned.fill(
                            child: Opacity(
                              opacity: _logoResolve.value,
                              child: Container(
                                color: const Color(0xFFE65100), // Deep Marvel-style brand orange-red
                              ),
                            ),
                          ),
                          // 4. White Bold Capital Text Overlay
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Text(
                              'NEXT2WATCH',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.5,
                                fontFamily: theme.textTheme.titleLarge?.fontFamily,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // MARVEL style "STUDIOS" (INDEPENDENT) Subtitle layout
                  Opacity(
                    opacity: _subTitleFade.value,
                    child: Transform.translate(
                      offset: Offset(0, 15 * (1.0 - _subTitleFade.value)),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        width: size.width * 0.72,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 1.5,
                              color: const Color(0xFFFFB300), // Gold line
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'I N D E P E N D E N T',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFB300), // Gold text
                                  letterSpacing: 3.5,
                                ),
                              ),
                            ),
                            Container(
                              height: 1.5,
                              color: const Color(0xFFFFB300), // Gold line
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
