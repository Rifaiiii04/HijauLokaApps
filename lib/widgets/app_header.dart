import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final bool showActionButtons;
  
  const AppHeader({
    super.key,
    this.title,
    this.centerTitle = false,
    this.actions,
    this.showActionButtons = true,
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
      actions: actions ?? (showActionButtons ? [
        // Wishlist button
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black54),
          onPressed: () {
            Navigator.pushNamed(context, '/wishlist');
          },
        ),
        // Notification button
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black54),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        // Cart button
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ] : null),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}