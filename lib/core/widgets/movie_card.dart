import 'dart:ui';
import 'package:flutter/material.dart';

class MovieCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String rating;
  final String genre;
  final int? rank;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const MovieCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.genre,
    this.rank,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 16),
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 140,
          margin: widget.margin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster with Drop Shadow
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Poster Image
                        Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white30,
                              size: 40,
                            ),
                          ),
                        ),
                        // Dark Bottom Gradient for Text & Badge contrast
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                  Colors.black.withOpacity(0.85),
                                ],
                                stops: const [0.5, 0.75, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Rank Badge (Premium circular medal/award badge)
                        if (widget.rank != null)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: widget.rank == 1
                                      ? const LinearGradient(
                                          colors: [Color(0xFFFFE066), Color(0xFFF1C40F)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : widget.rank == 2
                                          ? const LinearGradient(
                                              colors: [Color(0xFFF2F4F4), Color(0xFFBDC3C7)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : widget.rank == 3
                                              ? const LinearGradient(
                                                  colors: [Color(0xFFEDBB99), Color(0xFFD35400)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : LinearGradient(
                                                  colors: [Colors.black.withOpacity(0.55), Colors.black.withOpacity(0.8)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                  border: Border.all(
                                    color: widget.rank == 1
                                        ? const Color(0xFFD4AC0D)
                                        : widget.rank == 2
                                            ? const Color(0xFF95A5A6)
                                            : widget.rank == 3
                                                ? const Color(0xFFA04000)
                                                : Colors.white.withOpacity(0.18),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: widget.rank! <= 3
                                    ? Text(
                                        '${widget.rank}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1C2833),
                                        ),
                                      )
                                    : BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Center(
                                          child: Text(
                                            '${widget.rank}',
                                            style: TextStyle(
                                              fontSize: widget.rank! >= 10 ? 10 : 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Movie Title
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              // Genre indicator row
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.genre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
