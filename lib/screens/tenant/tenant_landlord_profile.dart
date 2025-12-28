import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
// payment_provider not required here
import 'package:rentease_simple/screens/messages/conversations_screen.dart';

class TenantLandlordProfile extends StatelessWidget {
  const TenantLandlordProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final landlordId = user?.landlordId;
    final matches = landlordId == null ? <dynamic>[] : auth.allUsers.where((u) => u.id == landlordId).toList();
    final landlord = matches.isNotEmpty ? matches.first : null;

    if (landlord == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Landlord')),
        body: const Center(child: Text('No landlord information available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Landlord Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(radius: 36, backgroundColor: const Color(0xFF2C3E50), child: Text(landlord.name.substring(0,1), style: const TextStyle(color: Colors.white, fontSize: 24))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(landlord.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(landlord.email, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text('Phone: ${landlord.phone.isNotEmpty ? landlord.phone : 'N/A'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ConversationsScreen(userId: auth.currentUser!.id, title: 'Messages')),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Message Landlord'),
            ),
            const SizedBox(height: 12),
            const Text('Tenant Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You can message your landlord directly from this app. Keep conversations polite and related to tenancy.'),
          ],
        ),
      ),
    );
  }
}
