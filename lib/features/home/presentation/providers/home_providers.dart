import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/movie.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HomeRepositoryImpl(dio);
});

final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getTopRatedMovies();
});
