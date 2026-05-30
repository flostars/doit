import 'package:flutter/material.dart';
import 'details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('doit')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monorepo scaffold ready',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'This app is prepared for parallel work with the Java backend.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _AreaCard(
              title: 'mobile_app',
              description: 'Flutter UI, navigation, state management, tests',
            ),
            const SizedBox(height: 12),
            const _AreaCard(
              title: 'api-server',
              description: 'Spring Boot API, domain logic, persistence',
            ),
            const SizedBox(height: 12),
            const _AreaCard(
              title: 'contracts',
              description: 'Shared API contract and integration rules',
            ),
            const SizedBox(height: 32), // Відступ перед кнопкою
            // ДОДАЄМО КНОПКУ:
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.arrow_forward), // Іконка стрілочки
                label: const Text(
                  'Перейти на другу стоірнку',
                ), // Текст на кнопці
                onPressed: () {
                  // ЦЕЙ БЛОК ВИКЛИКАЄТЬСЯ ПРИ НАЖАТТІ
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const DetailsPage(), // Наш новий екран
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(description)),
    );
  }
}
