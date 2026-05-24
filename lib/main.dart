import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive, Firebase, etc. here later
  
  runApp(
    const ProviderScope(
      child: Next2WatchApp(),
    ),
  );
}
