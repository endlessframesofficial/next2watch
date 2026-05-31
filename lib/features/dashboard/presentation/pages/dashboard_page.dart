import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../discover/presentation/pages/discover_tab.dart';
import '../../../home/presentation/pages/home_tab.dart';
import '../../../ott/presentation/pages/ott_releases_page.dart';

// import '../../../watchlist/presentation/pages/watchlist_tab.dart'; // removed per user request
import '../providers/dashboard_provider.dart';


class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(dashboardIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeTab(),
          DiscoverTab(),
          OttReleasesPage(),

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
