import 'package:flutter/material.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

/// Centralized error handling utility for the app
class ErrorHandler {
  /// Handle API errors with user-friendly messages
  static String handleApiError(dynamic error) {
    AppLogger.error('API Error: $error');
    
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (error.toString().contains('FormatException')) {
      return 'Invalid data format received. Please try again.';
    }
    
    if (error.toString().contains('Unauthorized') || 
        error.toString().contains('401')) {
      return 'Session expired. Please login again.';
    }
    
    if (error.toString().contains('Forbidden') || 
        error.toString().contains('403')) {
      return 'Access denied. Please contact support.';
    }
    
    if (error.toString().contains('Not Found') || 
        error.toString().contains('404')) {
      return 'Requested resource not found.';
    }
    
    if (error.toString().contains('Server Error') || 
        error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    // Default error message
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Show error message to user
  static void showError(BuildContext context, String message) {
    TopSnackbar.show(
      context,
      message: message,
      isError: true,
    );
  }
  
  /// Show success message to user
  static void showSuccess(BuildContext context, String message) {
    TopSnackbar.show(
      context,
      message: message,
      isError: false,
    );
  }
  
  /// Handle and log errors with fallback
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final errorMessage = customMessage ?? handleApiError(error);
    
    AppLogger.error('Error handled: $error');
    
    showError(context, errorMessage);
    
    // Log additional context if available
    if (onRetry != null) {
      AppLogger.info('Retry callback available for error');
    }
  }
  
  /// Safe async operation with error handling
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      AppLogger.error('Safe async operation failed: $e');
      return fallbackValue;
    }
  }
  
  /// Validate required fields
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
}

