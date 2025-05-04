import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.secondaryColor,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Selamat Datang Di HijauLoka',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
              children: [
                TextSpan(text: 'Bring\n'),
                TextSpan(
                  text: 'Nature\n',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
                TextSpan(text: 'Into\n'),
                TextSpan(text: 'Your\n'),
                TextSpan(text: 'Home'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Eksplor Sekarang'),
          ),
        ],
      ),
    );
  }
}