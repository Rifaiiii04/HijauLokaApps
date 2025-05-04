import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/screens/home/home_screen.dart';
import 'package:hijauloka/screens/category/category_screen.dart';
import 'package:hijauloka/screens/profile/profile_screen.dart';
import 'package:hijauloka/widgets/custom_bottom_nav.dart';
import 'package:hijauloka/screens/auth/login_screen.dart';
import 'package:hijauloka/screens/auth/register_screen.dart';

void main() {
  runApp(const HijauLokaApp());
}

class HijauLokaApp extends StatelessWidget {
  const HijauLokaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HijauLoka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
