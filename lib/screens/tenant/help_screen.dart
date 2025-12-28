import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I pay my bill?',
        'a': 'Go to Dashboard > Pay Now or Bills > select a bill and use the Pay Now option.'
      },
      {'q': 'Who can I contact for issues?', 'a': 'Use the Contact Support screen from the Profile or Quick Actions.'},
      {'q': 'Can I save payment methods?', 'a': 'This demo does not store payment methods yet.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text(item['q']!),
              children: [Padding(
                padding: const EdgeInsets.all(12),
                child: Text(item['a']!),
              )],
            ),
          );
        },
      ),
    );
  }
}
