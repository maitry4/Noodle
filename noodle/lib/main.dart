import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noodle/core/providers/app_providers.dart';
import 'package:noodle/core/routers/app_router.dart';
import 'package:noodle/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await hiveService.init();
  
  runApp(
    const ProviderScope(
      child: NoodleApp(),
    ),
  );
}

class NoodleApp extends ConsumerWidget {
  const NoodleApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return  MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      theme: appTheme,
    );
  }
}