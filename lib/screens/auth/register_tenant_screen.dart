import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/screens/tenant/tenant_dashboard.dart';
import 'package:rentease_simple/widgets/custom_button.dart';
import 'package:rentease_simple/widgets/custom_text_field.dart';

class RegisterTenantScreen extends StatefulWidget {
  const RegisterTenantScreen({super.key});

  @override
  State<RegisterTenantScreen> createState() => _RegisterTenantScreenState();
}

class _RegisterTenantScreenState extends State<RegisterTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final payment = Provider.of<PaymentProvider>(context, listen: false);
    try {
      final user = await auth.registerTenantWithCode(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        inviteCode: _codeController.text.trim(),
      );

      // add tenant record for landlord UI
      payment.addTenantFromUser(user);

      // auto-login
      await auth.login(email: user.email, password: user.password ?? '');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TenantDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(title: const Text('Create Tenant Account')),
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
                      const Text('Tenant Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      CustomTextField(controller: _nameController, label: 'Full Name', hintText: 'Enter full name', prefixIcon: Icons.person),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _emailController, label: 'Email', hintText: 'Enter email', prefixIcon: Icons.email),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _phoneController, label: 'Phone', hintText: 'Enter phone number', prefixIcon: Icons.phone),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _passwordController, label: 'Password', hintText: 'Create a password', prefixIcon: Icons.lock, obscureText: true),
                      const SizedBox(height: 12),
                      CustomTextField(controller: _codeController, label: 'Invite Code (optional)', hintText: 'Enter invite code', prefixIcon: Icons.vpn_key),
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
