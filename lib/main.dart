import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'dashboard.dart';
import 'notification_page.dart';
import 'profile_page.dart';      // ✅ Tambahkan halaman Profile asli
import 'add_new_pot.dart';      // ✅ Tambahkan halaman Add Pot asli

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

        // Notification Page
        '/notifications': (context) => const NotificationPage(),

        // Profile page (bukan placeholder lagi)
        '/profile': (context) => const ProfilePage(),

        // Add Smart Pot Page (bukan placeholder lagi)
        '/add-pot': (context) => const AddNewPotScreen(),
      },
    );
  }
}
