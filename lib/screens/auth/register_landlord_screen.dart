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

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Successful'),
          content: Text('Invite Code: ${user.inviteCode}\nShare this code with tenants.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register as Landlord')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _nameController, label: 'Full Name', hintText: 'Enter full name', prefixIcon: Icons.person),
              const SizedBox(height: 12),
              CustomTextField(controller: _emailController, label: 'Email', hintText: 'Enter email', prefixIcon: Icons.email),
              const SizedBox(height: 12),
              CustomTextField(controller: _phoneController, label: 'Phone', hintText: 'Enter phone number', prefixIcon: Icons.phone),
              const SizedBox(height: 12),
              CustomTextField(controller: _passwordController, label: 'Password', hintText: 'Enter password', prefixIcon: Icons.lock, obscureText: true),
              const SizedBox(height: 20),
              CustomButton(text: 'Register', onPressed: _register, color: Colors.green),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
            ],
          ),
        ),
      ),
    );
  }
}
