import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/widgets/custom_button.dart';
import 'package:rentease_simple/widgets/custom_text_field.dart';

class RegisterLandlordScreen extends StatefulWidget {
  const RegisterLandlordScreen({super.key});

  @override
  State<RegisterLandlordScreen> createState() => _RegisterLandlordScreenState();
}

class _RegisterLandlordScreenState extends State<RegisterLandlordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final user = await auth.registerLandlord(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your landlord account has been created.'),
                const SizedBox(height: 12),
                const Text('Invite Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(user.inviteCode ?? 'N/A',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Text('Share this code with your tenants.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(title: const Text('Create Landlord Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('Landlord Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      CustomTextField(controller: _nameController, label: 'Full Name', hintText: 'Enter full name', prefixIcon: Icons.person),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _emailController, label: 'Email', hintText: 'Enter email', prefixIcon: Icons.email),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _phoneController, label: 'Phone', hintText: 'Enter phone number', prefixIcon: Icons.phone),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _passwordController, label: 'Password', hintText: 'Create a password', prefixIcon: Icons.lock, obscureText: true),
                      const SizedBox(height: 20),
                      SizedBox(width: double.infinity, child: CustomButton(text: 'Register', onPressed: _register, color: Colors.green)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
