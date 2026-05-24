import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

class Next2WatchApp extends ConsumerWidget {
  const Next2WatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Next2Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Placeholder theme
      routerConfig: goRouter,
    );
  }
}
