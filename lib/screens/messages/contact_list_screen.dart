import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/screens/messages/chat_screen.dart';

class ContactListScreen extends StatelessWidget {
  final String currentUserId;
  final bool isLandlord; // when true, show tenants; otherwise show landlord
  const ContactListScreen({super.key, required this.currentUserId, required this.isLandlord});

  @override
  Widget build(BuildContext context) {
    final payment = Provider.of<PaymentProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    List<Map<String, dynamic>> tenantList = payment.tenants;

    if (isLandlord) {
      // show tenants
      return Scaffold(
        appBar: AppBar(title: const Text('Select Tenant')),
        body: ListView.separated(
          itemCount: tenantList.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final t = tenantList[index];
            final id = t['id'] as String? ?? '';
            final name = t['name'] as String? ?? id;
            return ListTile(
              title: Text(name),
              subtitle: Text(t['email'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(currentUserId: currentUserId, otherUserId: id)),
                );
              },
            );
          },
        ),
      );
    } else {
      // tenant: show landlord (single)
      final matchesUser = auth.allUsers.where((u) => u.id == currentUserId).toList();
      final user = matchesUser.isNotEmpty ? matchesUser.first : null;
      final landlordId = user?.landlordId;
      if (landlordId == null) {
        return Scaffold(appBar: AppBar(title: const Text('Contact Landlord')), body: const Center(child: Text('No landlord found')));
      }
      final matches = auth.allUsers.where((u) => u.id == landlordId).toList();
      final landlord = matches.isNotEmpty ? matches.first : null;
      return Scaffold(
        appBar: AppBar(title: const Text('Contact Landlord')),
        body: ListView(
          children: [
            ListTile(
              title: Text(landlord?.name ?? 'Landlord'),
              subtitle: Text(landlord?.email ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(currentUserId: currentUserId, otherUserId: landlordId)),
                );
              },
            ),
          ],
        ),
      );
    }
  }
}
