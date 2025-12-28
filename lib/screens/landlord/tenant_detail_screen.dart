import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';

class TenantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tenant;
  const TenantDetailScreen({super.key, required this.tenant});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  late TextEditingController _rentController;
  late TextEditingController _noticeController;

  @override
  void initState() {
    super.initState();
    _rentController = TextEditingController(text: (widget.tenant['monthlyRent'] ?? 0).toString());
    _noticeController = TextEditingController();
  }

  @override
  void dispose() {
    _rentController.dispose();
    _noticeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentProvider>(context);
    final tenant = widget.tenant;
    final notices = provider.getNoticesForTenant(tenant['id']);

    return Scaffold(
      appBar: AppBar(title: Text(tenant['name'] ?? 'Tenant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${tenant['email'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Phone: ${tenant['phone'] ?? ''}'),
            const SizedBox(height: 12),
            Text('Monthly Rent (৳):'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final v = double.tryParse(_rentController.text) ?? 0.0;
                    provider.updateTenantRent(tenant['id'], v);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rent updated')));
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Send Notice'),
            TextField(
              controller: _noticeController,
              decoration: const InputDecoration(hintText: 'Enter message', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final msg = _noticeController.text.trim();
                if (msg.isEmpty) return;
                provider.sendNoticeToTenant(tenant['id'], msg);
                _noticeController.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice sent')));
              },
              child: const Text('Send Notice'),
            ),
            const SizedBox(height: 16),
            const Text('Recent Notices', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: notices.isEmpty
                  ? const Center(child: Text('No notices'))
                  : ListView.separated(
                      itemCount: notices.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final n = notices[index];
                        final date = n['date'] is DateTime ? (n['date'] as DateTime).toLocal().toString() : n['date'].toString();
                        return ListTile(
                          title: Text(n['message'] ?? ''),
                          subtitle: Text(date),
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
