import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_collection.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HomeRepositoryImpl(dio);
});

final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getTopRatedMovies();
});

final firestoreMoviesProvider = StreamProvider<List<Movie>>((ref) {
  return FirebaseFirestore.instance
      .collection('malayalam_movies')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Movie.fromJson(data);
    }).toList();
  });
});

final firestoreCollectionsProvider = StreamProvider<List<MovieCollection>>((ref) {
  return FirebaseFirestore.instance
      .collection('collections')
      .orderBy('order')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => MovieCollection.fromJson(doc.data())).toList();
  });
});

final collectionMoviesProvider = FutureProvider.family<List<Movie>, List<String>>((ref, movieIds) async {
  if (movieIds.isEmpty) return [];
  
  final firestore = FirebaseFirestore.instance;
  
  final snapshot = await firestore
      .collection('malayalam_movies')
      .where(FieldPath.documentId, whereIn: movieIds)
      .get();
      
  final movies = snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList();
  
  final movieMap = {for (var movie in movies) movie.id: movie};
  return movieIds.map((id) => movieMap[id]).whereType<Movie>().toList();
});
