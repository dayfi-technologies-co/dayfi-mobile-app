import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme_provider.dart';

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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Light',
                    style: TextStyle(
                      color:
                          themeMode == AppThemeMode.light
                              ? Theme.of(context).colorScheme.primary
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dark',
                    style: TextStyle(
                      color:
                          themeMode == AppThemeMode.dark
                              ? Theme.of(context).colorScheme.primary
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'System',
                    style: TextStyle(
                      color:
                          themeMode == AppThemeMode.system
                              ? Theme.of(context).colorScheme.primary
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
        showThemeSelectionSheet(context);
      },
    );
  }
}

/// Presents theme options in a modal bottom sheet (same shell as Send money).
Future<void> showThemeSelectionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (ctx) => const _ThemeSelectionSheet(),
  );
}

class _ThemeSelectionSheet extends ConsumerWidget {
  const _ThemeSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    void pick(AppThemeMode mode) {
      themeNotifier.setThemeMode(mode);
      Navigator.of(context).pop();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40, width: 40),
                Text(
                  'Select theme',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svgs/notificationn.svg',
                        height: 40,
                        // ignore: deprecated_member_use
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Image.asset(
                            'assets/icons/pngs/cancelicon.png',
                            height: 20,
                            width: 20,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Opacity(
              opacity: 0.7,
              child: Text(
                'Choose how Dayfi should look.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Chirp',
                  letterSpacing: -0.20,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              children: [
                _ThemeOptionTile(
                  selected: themeMode == AppThemeMode.light,
                  icon: "assets/icons/svgs/sun.svg",
                  title: 'Light',
                  subtitle: 'Always use light theme',
                  primary: primary,
                  onTap: () => pick(AppThemeMode.light),
                ),
                const SizedBox(height: 12),
                _ThemeOptionTile(
                  selected: themeMode == AppThemeMode.dark,
                  icon: "assets/icons/svgs/moon.svg",
                  title: 'Dark',
                  subtitle: 'Always use dark theme',
                  primary: primary,
                  onTap: () => pick(AppThemeMode.dark),
                ),
                const SizedBox(height: 12),
                _ThemeOptionTile(
                  selected: themeMode == AppThemeMode.system,
                  icon: "assets/icons/svgs/sun.svg",
                  title: 'System',
                  subtitle: 'Follow system theme',
                  primary: primary,
                  onTap: () => pick(AppThemeMode.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.onTap,
  });

  final bool selected;
  final String icon;
  final String title;
  final String subtitle;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              selected
                  ? Border.all(
                    color: AppColors.purple500.withValues(alpha: 0.55),
                    width: 1,
                  )
                  : null,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: icon == "assets/icons/svgs/moon.svg" ? 24 : 26,
              color: selected ? AppColors.purple500 : onSurface.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 18,
                      letterSpacing: -0.20,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? AppColors.purple500 : onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      fontFamily: 'Chirp',
                      letterSpacing: -0.20,
                      fontSize: 14,
                      color: onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            selected
                ? SvgPicture.asset(
                  "assets/icons/svgs/circle-check.svg",
                  color: AppColors.purple500,
                  height: 22,
                  width: 22,
                )
                : Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral400,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
