import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';

class NetworkErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onContinue;

  const NetworkErrorDialog({
    Key? key,
    required this.message,
    required this.onRetry,
    this.onContinue,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => NetworkErrorDialog(
            message: message,
            onRetry: onRetry,
            onContinue: onContinue,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 28),
          const SizedBox(width: 12),
          const Text('Connection Error'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text(
            'The application is having trouble connecting to the server. This might be due to:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• Server maintenance'),
                Text('• Internet connection issues'),
                Text('• Temporary server downtime'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (onContinue != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue!();
            },
            child: const Text('Continue Offline'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
