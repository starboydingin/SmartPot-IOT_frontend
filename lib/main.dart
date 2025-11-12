import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'dashboard.dart';
import 'notification_page.dart'; // ✅ Tambahkan import halaman notifikasi

void main() {
  runApp(const SmartPlantApp());
}

class SmartPlantApp extends StatelessWidget {
  const SmartPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Plant Pot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        // ✅ Ganti placeholder menjadi halaman notifikasi asli
        '/notifications': (context) => const NotificationPage(),

        // Masih placeholder untuk profile & add-pot
        '/profile': (context) => const Scaffold(
              body: Center(child: Text('Profile Page')),
            ),
        '/add-pot': (context) => const Scaffold(
              body: Center(child: Text('Add Smart Pot Page')),
            ),
      },
    );
  }
}
