import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoodleApp(),
    );
  }
}

class NoodleApp extends StatelessWidget {
  const NoodleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opus Recorder Debug'),
      ),
      body: Center(
        child: Text("Noodle App"),
      ));
  }
}