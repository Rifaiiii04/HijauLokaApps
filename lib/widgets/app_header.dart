import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/services/auth_service.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool centerTitle;
  
  const AppHeader({
    super.key,
    this.title,
    this.centerTitle = false,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends State<AppHeader> {
  bool _isLoggedIn = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: widget.title == null ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/img/HijauLoklogo.png', 
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.eco,
            color: AppTheme.primaryColor,
          ),
        ),
      ) : null,
      title: widget.title != null ? Text(
        widget.title!,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ) : null,
      centerTitle: widget.centerTitle,
      actions: _isLoggedIn ? [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/wishlist');
          },
        ),
      ] : [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}