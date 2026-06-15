import 'package:flutter/material.dart';
import 'package:noodle/core/routers/app_router.dart';
import 'package:noodle/core/theme/app_theme.dart';

void main() {
  runApp(const NoodleApp());
}

class NoodleApp extends StatelessWidget {
  const NoodleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: appTheme,
    );
  }
}