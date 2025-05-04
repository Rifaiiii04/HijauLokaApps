import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLoginPressed;
  final String? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final bool showLoginButton;
  
  const AppHeader({
    super.key,
    this.onLoginPressed,
    this.title,
    this.centerTitle = false,
    this.actions,
    this.showLoginButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: title == null ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/img/HijauLoklogo.png', 
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.eco,
            color: AppTheme.primaryColor,
          ),
        ),
      ) : null,
      title: title != null ? Text(
        title!,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ) : null,
      centerTitle: centerTitle,
      actions: actions ?? (showLoginButton ? [
        TextButton(
          onPressed: onLoginPressed ?? () {
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
      ] : null),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}