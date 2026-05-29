import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Другий екран'),
        // Стрілочка "Назад" в лівому кутку з'явиться АВТОМАТИЧНО!
      ),
      body: const Center(
        child: Text(
          'Ура! Ви перейшли на новий екран! 🎉',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
