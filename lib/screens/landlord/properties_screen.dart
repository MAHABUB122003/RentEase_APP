import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentProvider>(context);
    final props = provider.properties;

    return Scaffold(
      appBar: AppBar(title: const Text('Properties')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: props.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final p = props[index];
          return Card(
            child: ListTile(
              title: Text(p['name'] ?? 'Unnamed'),
              subtitle: Text(p['address'] ?? ''),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
