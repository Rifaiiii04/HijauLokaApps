import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/screens/home/home_screen.dart';
import 'package:hijauloka/screens/category/category_screen.dart';
import 'package:hijauloka/screens/profile/profile_screen.dart';
import 'package:hijauloka/widgets/custom_bottom_nav.dart';
import 'package:hijauloka/screens/auth/login_screen.dart';
import 'package:hijauloka/screens/auth/register_screen.dart';
// Remove imports for screens that don't exist yet

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
        // Use placeholder screens for now
        '/cart': (context) => const PlaceholderScreen(title: 'Cart'),
        '/notifications': (context) => const PlaceholderScreen(title: 'Notifications'),
        '/wishlist': (context) => const PlaceholderScreen(title: 'Wishlist'),
      },
    );
  }
}

// Add a placeholder screen for routes that don't have dedicated screens yet
class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForTitle(title),
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This screen is under development',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'cart':
        return Icons.shopping_cart;
      case 'notifications':
        return Icons.notifications;
      case 'wishlist':
        return Icons.favorite;
      default:
        return Icons.construction;
    }
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
