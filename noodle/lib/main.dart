import 'package:flutter/material.dart';
import 'package:noodle/core/routers/app_router.dart';

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
    );
  }
}