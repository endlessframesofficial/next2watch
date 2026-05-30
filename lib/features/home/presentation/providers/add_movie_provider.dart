import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final addMovieProvider = NotifierProvider<AddMovieNotifier, bool>(AddMovieNotifier.new);

class AddMovieNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // false means not loading
  }

  Future<bool> addMovie(Map<String, dynamic> movieData) async {
    state = true; // Set loading state to true
    try {
      final firestore = FirebaseFirestore.instance;
      
      final dataToSave = Map<String, dynamic>.from(movieData);
      dataToSave['createdAt'] = FieldValue.serverTimestamp();
      
      final String id = dataToSave['id'] as String;
      
      await firestore.collection('malayalam_movies').doc(id).set(dataToSave);
      
      state = false;
      return true;
    } catch (e) {
      print('Error adding movie: $e');
      state = false;
      return false;
    }
  }
}
