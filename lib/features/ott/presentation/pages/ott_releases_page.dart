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

class OttReleasesPage extends ConsumerWidget {
  const OttReleasesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOtt = ref.watch(ottReleasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTT Releases'),
      ),
      body: asyncOtt.when(
        data: (ottList) {
          // Filter only upcoming releases
          final upcoming = ottList.where((o) => o.status.toLowerCase() == 'upcoming').toList();
          if (upcoming.isEmpty) {
            return const Center(child: Text('No upcoming OTT releases found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
