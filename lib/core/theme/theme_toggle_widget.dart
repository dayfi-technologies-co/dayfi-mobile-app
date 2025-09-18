import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';
import 'app_colors.dart';

/// Theme Toggle Widget
///
/// A widget that allows users to toggle between light and dark themes
/// This widget demonstrates the theming system in action
class ThemeToggleWidget extends ConsumerWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return PopupMenuButton<AppThemeMode>(
      icon: Icon(
        themeMode == AppThemeMode.light
            ? Icons.light_mode
            : themeMode == AppThemeMode.dark
            ? Icons.dark_mode
            : Icons.brightness_auto,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: 'Toggle theme',
      onSelected: (AppThemeMode mode) {
        themeNotifier.setThemeMode(mode);
      },
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem<AppThemeMode>(
              value: AppThemeMode.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color:
                        themeMode == AppThemeMode.light
                            ? AppColors.primary500
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Light',
                    style: TextStyle(
                      color:
                          themeMode == AppThemeMode.light
                              ? AppColors.primary500
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          themeMode == AppThemeMode.light
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppThemeMode>(
              value: AppThemeMode.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color:
                        themeMode == AppThemeMode.dark
                            ? AppColors.primary500
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dark',
                    style: TextStyle(
                      color:
                          themeMode == AppThemeMode.dark
                              ? AppColors.primary500
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          themeMode == AppThemeMode.dark
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppThemeMode>(
              value: AppThemeMode.system,
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_auto,
                    color:
                        themeMode == AppThemeMode.system
                            ? AppColors.primary500
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'System',
                    style: TextStyle(
                      color:
                          themeMode == AppThemeMode.system
                              ? AppColors.primary500
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          themeMode == AppThemeMode.system
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
    );
  }
}

/// Simple Theme Toggle Button
///
/// A simple button that toggles between light and dark themes
class SimpleThemeToggleButton extends ConsumerWidget {
  const SimpleThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return IconButton(
      onPressed: () {
        themeNotifier.toggleTheme();
      },
      icon: Icon(
        themeMode == AppThemeMode.light ? Icons.dark_mode : Icons.light_mode,
      ),
      tooltip: 'Toggle theme',
    );
  }
}

/// Theme Toggle Switch
///
/// A switch widget that toggles between light and dark themes
class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Switch(
      value: themeMode == AppThemeMode.dark,
      onChanged: (bool value) {
        themeNotifier.setThemeMode(
          value ? AppThemeMode.dark : AppThemeMode.light,
        );
      },
    );
  }
}

/// Theme Toggle List Tile
///
/// A list tile that shows theme options
class ThemeToggleListTile extends ConsumerWidget {
  const ThemeToggleListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return ListTile(
      leading: Icon(
        themeMode == AppThemeMode.light
            ? Icons.light_mode
            : themeMode == AppThemeMode.dark
            ? Icons.dark_mode
            : Icons.brightness_auto,
      ),
      title: const Text('Theme'),
      subtitle: Text(
        themeMode == AppThemeMode.light
            ? 'Light'
            : themeMode == AppThemeMode.dark
            ? 'Dark'
            : 'System',
      ),
      trailing: Switch(
        value: themeMode == AppThemeMode.dark,
        onChanged: (bool value) {
          themeNotifier.setThemeMode(
            value ? AppThemeMode.dark : AppThemeMode.light,
          );
        },
      ),
      onTap: () {
        // Show theme selection dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const ThemeSelectionDialog();
          },
        );
      },
    );
  }
}

/// Theme Selection Dialog
///
/// A dialog that allows users to select their preferred theme
class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<AppThemeMode>(
            title: const Text('Light'),
            subtitle: const Text('Always use light theme'),
            value: AppThemeMode.light,
            groupValue: themeMode,
            onChanged: (AppThemeMode? value) {
              if (value != null) {
                themeNotifier.setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Dark'),
            subtitle: const Text('Always use dark theme'),
            value: AppThemeMode.dark,
            groupValue: themeMode,
            onChanged: (AppThemeMode? value) {
              if (value != null) {
                themeNotifier.setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Follow system theme'),
            value: AppThemeMode.system,
            groupValue: themeMode,
            onChanged: (AppThemeMode? value) {
              if (value != null) {
                themeNotifier.setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
