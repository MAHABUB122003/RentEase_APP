import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/utils/format.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentProvider>(context);
    final report = provider.generateReport();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: const Text('Total Collected'),
                trailing: Text(AppFormat.formatCurrency(report['totalCollected'] as double)),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Total Bills'),
                trailing: Text(report['totalBills'].toString()),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Pending Bills'),
                trailing: Text(report['pending'].toString()),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Paid Bills'),
                trailing: Text(report['paid'].toString()),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Active Tenants'),
                trailing: Text(report['activeTenants'].toString()),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Properties'),
                trailing: Text(report['properties'].toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
