import '../entities/movie.dart';

abstract class HomeRepository {
  Future<List<Movie>> getTopRatedMovies();
}
