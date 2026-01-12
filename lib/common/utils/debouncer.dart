import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class for debouncing function calls
/// 
/// Debouncing ensures that a function is only called after a specified duration
/// has passed since the last call attempt. This is useful for search fields,
/// text inputs, and other scenarios where you want to wait for the user to
/// finish typing before processing the input.
/// 
/// Usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
/// 
/// // In onChanged callback:
/// debouncer.run(() {
///   // This will only execute 500ms after user stops typing
///   performSearch(searchQuery);
/// });
/// 
/// // Don't forget to dispose when done:
/// debouncer.dispose();
/// ```
class Debouncer {
  /// The duration to wait before calling the function
  final int milliseconds;
  
  /// Internal timer for tracking debounce
  Timer? _timer;

  /// Creates a debouncer with the specified delay in milliseconds
  Debouncer({required this.milliseconds});

  /// Runs the provided function after the debounce duration
  /// 
  /// If called multiple times, only the last call will be executed
  /// after the debounce duration has passed since the last call.
  void run(VoidCallback action) {
    // Cancel any existing timer
    _timer?.cancel();
    
    // Create a new timer
    _timer = Timer(
      Duration(milliseconds: milliseconds),
      action,
    );
  }

  /// Cancels any pending debounced function call
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending calls
  /// 
  /// Should be called in the dispose() method of your widget
  void dispose() {
    _timer?.cancel();
  }
}

/// A specialized debouncer for search functionality
/// 
/// Provides a default 300ms delay which is optimal for search-as-you-type
class SearchDebouncer extends Debouncer {
  SearchDebouncer({int milliseconds = 300}) : super(milliseconds: milliseconds);
}
