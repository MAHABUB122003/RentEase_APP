import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/providers/theme_provider.dart';
import 'package:rentease_simple/screens/splash_screen.dart';
import 'package:rentease_simple/screens/auth/login_screen.dart';
import 'package:rentease_simple/screens/auth/register_tenant_screen.dart';
import 'package:rentease_simple/screens/auth/register_landlord_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, theme, child) {
        return MaterialApp(
          title: 'RentEase - Simple Version',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF2C3E50),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C3E50)),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2C3E50),
              foregroundColor: Colors.white,
              elevation: 1,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Color(0xFF2C3E50),
              unselectedItemColor: Colors.grey,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F8FA),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register/tenant': (context) => const RegisterTenantScreen(),
            '/register/landlord': (context) => const RegisterLandlordScreen(),
          },
        );
      }),
    );
  }
}