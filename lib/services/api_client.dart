import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hijauloka/config/api_config.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class ApiClient {
  static const int maxRetries = 2;
  static const Duration timeoutDuration = Duration(seconds: 15);
  static const Duration retryDelay = Duration(seconds: 2);

  // Get request with retry mechanism
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? converter,
    bool showErrorMessage = true,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/$endpoint',
    ).replace(queryParameters: queryParams);

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(uri).timeout(timeoutDuration);
        return _handleResponse(response, converter);
      } catch (e) {
        if (attempt == maxRetries) {
          debugPrint('API Error ($endpoint): ${e.toString()}');
          return ApiResponse(
            success: false,
            message: 'Network error: ${_getErrorMessage(e)}',
            data: null,
          );
        }

        await Future.delayed(retryDelay);
      }
    }

    // This should never be reached but is required for type safety
    return ApiResponse(
      success: false,
      message: 'Unknown error occurred',
      data: null,
    );
  }

  // Post request with retry mechanism
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? body,
    T Function(dynamic)? converter,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/$endpoint');

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(uri, body: body)
            .timeout(timeoutDuration);
        return _handleResponse(response, converter);
      } catch (e) {
        if (attempt == maxRetries) {
          return ApiResponse(
            success: false,
            message: 'Network error: ${_getErrorMessage(e)}',
            data: null,
          );
        }

        await Future.delayed(retryDelay);
      }
    }

    // This should never be reached
    return ApiResponse(
      success: false,
      message: 'Unknown error occurred',
      data: null,
    );
  }

  // Handle response parsing
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? converter,
  ) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);

        // Check if the response has a standard format
        if (jsonData is Map && jsonData.containsKey('success')) {
          final bool success = jsonData['success'] == true;
          final String message = jsonData['message'] ?? '';

          if (success && converter != null && jsonData.containsKey('data')) {
            final T convertedData = converter(jsonData['data']);
            return ApiResponse(
              success: success,
              message: message,
              data: convertedData,
            );
          }

          return ApiResponse(
            success: success,
            message: message,
            data: jsonData['data'] as T?,
          );
        }

        // Non-standard response format, try to convert directly
        if (converter != null) {
          return ApiResponse(
            success: true,
            message: 'Success',
            data: converter(jsonData),
          );
        }

        return ApiResponse(
          success: true,
          message: 'Success',
          data: jsonData as T?,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error parsing response: $e',
        data: null,
      );
    }
  }

  // Get a user-friendly error message
  static String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Cannot connect to the server. Please check your internet connection.';
    } else if (error is TimeoutException) {
      return 'Connection timed out. Please try again later.';
    } else if (error is HttpException) {
      return 'HTTP error occurred. Please try again later.';
    } else if (error is FormatException) {
      return 'Invalid response format. Please try again later.';
    } else {
      return error.toString();
    }
  }

  // Show error as a SnackBar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
