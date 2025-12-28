import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/widgets/custom_button.dart';
import 'package:rentease_simple/widgets/custom_text_field.dart';
import 'package:rentease_simple/screens/tenant/tenant_dashboard.dart';
import 'package:rentease_simple/screens/landlord/landlord_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (authProvider.currentUser != null) {
          if (authProvider.currentUser!.role == 'tenant') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TenantDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LandlordDashboard()),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Welcome to RentEase',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _isPasswordVisible,
                      onChanged: (value) {
                        setState(() {
                          _isPasswordVisible = value ?? false;
                        });
                      },
                    ),
                    const Text('Show Password'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register/tenant');
                      },
                      child: const Text('Register as Tenant'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register/landlord');
                      },
                      child: const Text('Register as Landlord'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Sign In',
                      onPressed: authProvider.isLoading ? () {} : _login,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      _emailController.text = 'test@example.com';
                      _passwordController.text = 'password123';
                    },
                    child: const Text(
                      'Use Demo Credentials',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'For demo: test@example.com / password123',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}