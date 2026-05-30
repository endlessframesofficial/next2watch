import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/firebase/firestore_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Import all Malayalam movies with slugified IDs and "Malayalam" language.
  // await FirestoreSeeder.importAllMalayalamMoviesFromTMDB();

  // Clear existing collections and seed new ones.
  await FirestoreSeeder.clearAndSeedCollections();
  
  // Initialize Hive, etc. here later
  
  runApp(
    const ProviderScope(
      child: Next2WatchApp(),
    ),
  );
}
