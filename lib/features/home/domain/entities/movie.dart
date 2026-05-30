class Movie {
  final String id;
  final String title;
  final String posterPath;
  final double voteAverage;
  final List<int> genreIds;
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.genreIds,
    this.genres = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      posterPath: json['poster'] ?? json['poster_path'] ?? '',
      voteAverage: (json['rating'] ?? json['vote_average'] ?? 0).toDouble(),
      genreIds: json['genre_ids'] != null ? List<int>.from(json['genre_ids']) : [],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
    );
  }

  String get fullPosterUrl {
    if (posterPath.startsWith('http')) return posterPath;
    
    const cloudinaryBase = 'https://res.cloudinary.com/dsox7pfi0/image/upload';
    if (posterPath.startsWith('/')) {
      return '$cloudinaryBase$posterPath';
    }
    return '$cloudinaryBase/$posterPath';
  }
}
