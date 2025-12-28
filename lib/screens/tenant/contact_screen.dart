import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent. We will contact you soon.')),
      );
      _subjectController.clear();
      _messageController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter subject' : null,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: null,
                  expands: true,
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter message' : null,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _send, child: const Text('Send')),
            ],
          ),
        ),
      ),
    );
  }
}
