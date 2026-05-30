class MovieCollection {
  final String id;
  final String title;
  final String description;
  final String banner;
  final String type;
  final String language;
  final bool isFeatured;
  final int order;
  final List<String> movieIds;

  MovieCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.banner,
    required this.type,
    required this.language,
    required this.isFeatured,
    required this.order,
    required this.movieIds,
  });

  factory MovieCollection.fromJson(Map<String, dynamic> json) {
    return MovieCollection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      banner: json['banner'] ?? '',
      type: json['type'] ?? '',
      language: json['language'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      order: json['order'] ?? 0,
      movieIds: json['movieIds'] != null ? List<String>.from(json['movieIds']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'banner': banner,
      'type': type,
      'language': language,
      'isFeatured': isFeatured,
      'order': order,
      'movieIds': movieIds,
    };
  }
}
