import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/screens/landlord/tenant_detail_screen.dart';

class ViewTenantsScreen extends StatelessWidget {
  const ViewTenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentProvider>(context);
    final tenants = provider.tenants;

    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tenants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = tenants[index];
          return Card(
            child: ListTile(
              title: Text(t['name'] ?? 'Unnamed'),
              subtitle: Text('${t['email'] ?? ''}\nRent: ৳${(t['monthlyRent'] ?? 0).toString()}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t['phone'] ?? ''),
                  const SizedBox(height: 6),
                  Text(
                    (t['active'] == true) ? 'Active' : 'Inactive',
                    style: TextStyle(color: (t['active'] == true) ? Colors.green : Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TenantDetailScreen(tenant: t)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
