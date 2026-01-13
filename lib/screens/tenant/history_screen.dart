import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/models/bill.dart';
import 'package:rentease_simple/utils/format.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentTenantId = authProvider.currentUser?.id;
    
    // Filter bills and payments for current tenant only
    final bills = paymentProvider.getBillsForTenantId(currentTenantId ?? '');
    final payments = paymentProvider.getPaymentsForTenantId(currentTenantId ?? '');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Bills'), Tab(text: 'Payments')],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final Bill bill = bills[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('Bill #${bill.id} - ${AppFormat.formatCurrency(bill.totalAmount)}'),
                    subtitle: Text('${AppFormat.formatDate(bill.billDate)} • Due ${AppFormat.formatDate(bill.dueDate)}'),
                    trailing: Text(
                      bill.status.toUpperCase(),
                      style: TextStyle(
                        color: bill.status == 'paid' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final p = payments[index];
                final date = p['date'] is DateTime ? AppFormat.formatDate(p['date'] as DateTime) : 'N/A';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(AppFormat.formatCurrency(p['amount'] as double)),
                    subtitle: Text('$date • ${p['method'] ?? 'N/A'}'),
                    trailing: Text(
                      (p['status'] as String).toUpperCase(),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
