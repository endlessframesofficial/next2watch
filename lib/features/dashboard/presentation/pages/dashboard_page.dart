import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../discover/presentation/pages/discover_tab.dart';
import '../../../home/presentation/pages/home_tab.dart';
import '../../../ott/presentation/pages/ott_releases_page.dart';

// import '../../../watchlist/presentation/pages/watchlist_tab.dart'; // removed per user request
import '../providers/dashboard_provider.dart';


class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(dashboardIndexProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardIndexProvider);

    // Listen to changes in index and animate PageView
    ref.listen<int>(dashboardIndexProvider, (previous, next) {
      if (next != _pageController.page?.round()) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return Scaffold(
      drawer: const _AppDrawer(),
      body: Stack(
        children: [
          // Background Blob 1: Top-Right Orange Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withOpacity(0.05),
                    Colors.orange.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Background Blob 2: Bottom-Left Amber Glow
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.04),
                    Colors.amber.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Keep bottom nav taps clean
            children: const [
              HomeTab(),
              DiscoverTab(),
              OttReleasesPage(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(dashboardIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'OTT',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Profile Card
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: onSurface.withOpacity(0.08),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(
                      Icons.movie_creation_rounded,
                      color: Colors.orange,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Transform.rotate(
                        angle: -10 * 3.141592653589793 / 180, // Tilted -10 degrees
                        child: Text(
                          '2',
                          style: TextStyle(
                            fontSize: 28, // Slightly dominant size
                            fontWeight: FontWeight.w900,
                            color: Colors.orange[800] ?? Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Watch',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Independent Cinema Journal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[800] ?? Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            // Philosophy / About Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE MISSION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: onSurface.withOpacity(0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Next2Watch is an independent curation platform born out of a pure passion for cinema. We believe that discoverability shouldn\'t be defined by complex rating algorithms, bots, or commercial agendas. Every collection is meticulously hand-curated to offer a human perspective in an algorithm-dominated world.',
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'WHY INDEPENDENT?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: onSurface.withOpacity(0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Modern algorithms feed you generic recommendations based on data points and promotional budgets. We focus strictly on genuine cinematic value. By offering independent reviews and expert curation, Next2Watch connects movie lovers with movies that truly matter.',
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer branding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'v1.0.0 • Pure Movie Passion',
                  style: TextStyle(
                    fontSize: 12,
                    color: onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
