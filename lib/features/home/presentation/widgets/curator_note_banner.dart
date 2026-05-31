import 'package:flutter/material.dart';

class CuratorNoteBanner extends StatefulWidget {
  const CuratorNoteBanner({super.key});

  @override
  State<CuratorNoteBanner> createState() => _CuratorNoteBannerState();
}

class _CuratorNoteBannerState extends State<CuratorNoteBanner> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.15),
            Colors.orange.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 18.0, 40.0, 18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Independent Curation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Welcome to Next2Watch! This is an independent cinema journal. Every collection, rating, and recommendation here is hand-curated, based purely on cinematic merit and a genuine passion for film. No algorithms, no bots, and no biased rating pressure—just a human perspective on what's worth watching. Enjoy the curation!",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  _isVisible = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
