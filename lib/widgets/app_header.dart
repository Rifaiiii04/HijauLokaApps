import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/screens/cart/cart_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showCartIcon;
  final bool showNotificationIcon;
  final bool showWishlistIcon;
  final List<Widget>? actions;

  const AppHeader({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.showCartIcon = true,
    this.showNotificationIcon = true,
    this.showWishlistIcon = true,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title:
          title != null
              ? Text(
                title!,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
              : Image.asset(
                'assets/img/HijauLoklogo.png',
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'HijauLoka',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
              : null,
      actions:
          actions ??
          [
            if (showWishlistIcon)
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.black),
                onPressed: () {
                  // Navigate to wishlist screen
                },
              ),
            if (showNotificationIcon)
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Navigate to notifications screen
                },
              ),
            if (showCartIcon)
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            const SizedBox(width: 8),
          ],
    );
  }
}
