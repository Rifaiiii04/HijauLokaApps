import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hijauloka/config/api_config.dart';
import 'package:hijauloka/widgets/network_error_dialog.dart';

class ConnectionChecker {
  /// Check if the main API server is reachable
  static Future<bool> checkMainServer() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/ping.php'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Handle connection errors and show appropriate dialog
  static void handleConnectionError(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    NetworkErrorDialog.show(
      context,
      message: message,
      onRetry: onRetry,
      onContinue: () {
        // Navigate back to previous screen or handle offline mode
        Navigator.of(context).pop();
      },
    );
  }

  /// Check server connection and retry with a dialog if it fails
  static Future<bool> ensureConnection(
    BuildContext context, {
    required String errorMessage,
    required VoidCallback onRetry,
  }) async {
    final isConnected = await checkMainServer();
    if (!isConnected) {
      if (context.mounted) {
        handleConnectionError(context, errorMessage, onRetry);
      }
    }
    return isConnected;
  }
}
