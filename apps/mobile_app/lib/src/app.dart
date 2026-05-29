import 'package:flutter/material.dart';

import 'features/home/presentation/home_page.dart';

class DoitApp extends StatelessWidget {
  const DoitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'doit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A936F)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
