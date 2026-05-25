import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final addCollectionProvider = NotifierProvider<AddCollectionNotifier, bool>(AddCollectionNotifier.new);

class AddCollectionNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // false means not loading
  }

  Future<bool> addCollection(Map<String, dynamic> collectionData) async {
    state = true;
    try {
      final firestore = FirebaseFirestore.instance;
      
      final dataToSave = Map<String, dynamic>.from(collectionData);
      dataToSave['createdAt'] = FieldValue.serverTimestamp();
      
      final String id = dataToSave['id'] as String;
      
      await firestore.collection('collections').doc(id).set(dataToSave);
      
      state = false;
      return true;
    } catch (e) {
      print('Error adding collection: $e');
      state = false;
      return false;
    }
  }
}
