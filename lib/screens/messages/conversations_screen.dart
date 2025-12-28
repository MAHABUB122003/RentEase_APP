import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/screens/messages/chat_screen.dart';
import 'package:rentease_simple/screens/messages/contact_list_screen.dart';

class ConversationsScreen extends StatelessWidget {
  final String userId;
  final String title;
  const ConversationsScreen({super.key, required this.userId, this.title = 'Messages'});

  @override
  Widget build(BuildContext context) {
    final payment = Provider.of<PaymentProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final convos = payment.getConversationsFor(userId);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // open contacts to start a new conversation
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final current = auth.currentUser;
          if (current == null) return;
          final isLandlord = current.role == 'landlord';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContactListScreen(currentUserId: current.id, isLandlord: isLandlord)),
          );
        },
        child: const Icon(Icons.message),
      ),
      body: convos.isEmpty
          ? const Center(child: Text('No conversations yet'))
          : ListView.separated(
              itemCount: convos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = convos[index];
                final partnerId = item['partnerId'] as String;
                final last = item['lastMessage'] as Map<String, dynamic>;
                final matches = auth.allUsers.where((u) => u.id == partnerId).toList();
                final name = matches.isNotEmpty ? matches.first.name : partnerId;
                final preview = (last['text'] as String? ?? '');
                return ListTile(
                  title: Text(name),
                  subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatScreen(currentUserId: userId, otherUserId: partnerId)),
                    );
                  },
                );
              },
            ),
    );
  }
}
