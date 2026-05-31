import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTTRelease {
  final String id;
  final String title;
  final String poster;
  final String platform;
  final String releaseDate;
  final String language;
  final String status;

  OTTRelease({
    required this.id,
    required this.title,
    required this.poster,
    required this.platform,
    required this.releaseDate,
    required this.language,
    required this.status,
  });

  factory OTTRelease.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OTTRelease(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      poster: data['poster'] ?? '',
      platform: data['platform'] ?? '',
      releaseDate: data['releaseDate'] ?? '',
      language: data['language'] ?? '',
      status: data['status'] ?? '',
    );
  }
}

final ottReleasesProvider = StreamProvider.autoDispose<List<OTTRelease>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('ott_releases').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => OTTRelease.fromDoc(doc)).toList();
  });
});

class OttReleasesPage extends ConsumerStatefulWidget {
  const OttReleasesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OttReleasesPage> createState() => _OttReleasesPageState();
}

class _OttReleasesPageState extends ConsumerState<OttReleasesPage> {
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
    final asyncOtt = ref.watch(ottReleasesProvider);

    return Scaffold(
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OTT Releases',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upcoming digital premieres on streaming platforms',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          asyncOtt.when(
            data: (ottList) {
              // Filter only upcoming releases
              final upcoming = ottList.where((o) => o.status.toLowerCase() == 'upcoming').toList();
              if (upcoming.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No upcoming OTT releases found.')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ott = upcoming[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Image.network(
                                    ott.poster,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ott.platform,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ott.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Release: ${ott.releaseDate}'),
                                  Text('Status: ${ott.status}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: upcoming.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
            error: (e, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
