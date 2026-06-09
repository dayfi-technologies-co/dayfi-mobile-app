import 'package:flutter/material.dart';

/// Emoji prefix for DayFlow budget category labels.
String dayFlowCategoryEmoji(String categoryName) {
  final n = categoryName.trim().toLowerCase();
  if (n.contains('food') || n.contains('dining') || n.contains('drink')) {
    return '🍔';
  }
  if (n.contains('transport') || n.contains('travel') || n.contains('fuel')) {
    return '🚗';
  }
  if (n.contains('bill') || n.contains('rent') || n.contains('utility')) {
    return '🧾';
  }
  if (n.contains('saving') || n.contains('invest')) {
    return '💰';
  }
  if (n.contains('flex') || n.contains('misc') || n.contains('other')) {
    return '✨';
  }
  if (n.contains('airtime') || n.contains('data') || n.contains('phone')) {
    return '📱';
  }
  if (n.contains('entertain') || n.contains('fun')) {
    return '🎬';
  }
  if (n.contains('health') || n.contains('medical')) {
    return '🏥';
  }
  if (n.contains('education') || n.contains('school')) {
    return '📚';
  }
  if (n.contains('shopping') || n.contains('clothes')) {
    return '🛍️';
  }
  return '📌';
}

String dayFlowCategoryLabel(String categoryName) {
  return '${dayFlowCategoryEmoji(categoryName)} $categoryName';
}

/// Dominant hue of each category emoji — used for allocation split bars, etc.
Color dayFlowCategoryAccentColor(String categoryName) {
  final n = categoryName.trim().toLowerCase();
  if (n.contains('food') || n.contains('dining') || n.contains('drink')) {
    return const Color(0xFFF4A442); // 🍔 bun / patty orange
  }
  if (n.contains('transport') || n.contains('travel') || n.contains('fuel')) {
    return const Color(0xFFE53935); // 🚗 red body
  }
  if (n.contains('bill') || n.contains('rent') || n.contains('utility')) {
    return const Color(0xFF90A4AE); // 🧾 paper grey-blue
  }
  if (n.contains('saving') || n.contains('invest')) {
    return const Color(0xFFFFC107); // 💰 gold bag
  }
  if (n.contains('flex') || n.contains('misc') || n.contains('other')) {
    return const Color(0xFFFFD54F); // ✨ sparkle gold
  }
  if (n.contains('airtime') || n.contains('data') || n.contains('phone')) {
    return const Color(0xFF42A5F5); // 📱 screen blue
  }
  if (n.contains('entertain') || n.contains('fun')) {
    return const Color(0xFFAB47BC); // 🎬 clapper purple
  }
  if (n.contains('health') || n.contains('medical')) {
    return const Color(0xFFEF5350); // 🏥 cross red
  }
  if (n.contains('education') || n.contains('school')) {
    return const Color(0xFF5C6BC0); // 📚 book indigo
  }
  if (n.contains('shopping') || n.contains('clothes')) {
    return const Color(0xFFEC407A); // 🛍️ bag pink
  }
  return const Color(0xFF9E9E9E); // 📌 neutral pin
}
