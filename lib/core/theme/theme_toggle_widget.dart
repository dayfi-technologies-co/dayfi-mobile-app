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

/// Presents theme options in a modal bottom sheet (same shell as delivery method).
Future<void> showThemeSelectionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    backgroundColor: Colors.transparent,
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

    final options = [
      (
        mode: AppThemeMode.light,
        icon: 'assets/icons/svgs/sun.svg',
        title: 'Light',
        subtitle: 'Always use light theme',
      ),
      (
        mode: AppThemeMode.dark,
        icon: 'assets/icons/svgs/moon.svg',
        title: 'Dark',
        subtitle: 'Always use dark theme',
      ),
      (
        mode: AppThemeMode.system,
        icon: 'assets/icons/svgs/sun.svg',
        title: 'System',
        subtitle: 'Follow system theme',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Select theme',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 8),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 28),
            //   child: Text(
            //     'Choose how Dayfi should look.',
            //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //       fontSize: 14,
            //       fontWeight: FontWeight.w500,
            //       fontFamily: 'Chirp',
            //       letterSpacing: -.25,
            //       height: 1.45,
            //       color: onSurface.withValues(alpha: 0.55),
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _ThemeOptionsGroup(
                options: options,
                selected: themeMode,
                primary: primary,
                onPick: pick,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionsGroup extends StatelessWidget {
  const _ThemeOptionsGroup({
    required this.options,
    required this.selected,
    required this.primary,
    required this.onPick,
  });

  final List<({AppThemeMode mode, String icon, String title, String subtitle})>
  options;
  final AppThemeMode selected;
  final Color primary;
  final void Function(AppThemeMode mode) onPick;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = selected == option.mode;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onPick(option.mode),
                  splashColor: Colors.transparent,
                  highlightColor: onSurface.withValues(alpha: 0.04),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SvgPicture.asset(
                              option.icon,
                              height: option.icon.contains('moon') ? 20 : 24,
                              color:
                                  isSelected
                                      ? primary.withValues(alpha: 0.85)
                                      : onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontFamily: 'Chirp',
                                  fontSize: 18,
                                  letterSpacing: -.25,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? primary : onSurface,
                                ),
                              ),
                              // const SizedBox(height: 4),
                              // Text(
                              //   option.subtitle,
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.w500,
                              //     height: 1.2,
                              //     fontFamily: 'Chirp',
                              //     letterSpacing: -.25,
                              //     fontSize: 14,
                              //     color:
                              //         isSelected
                              //             ? primary.withValues(alpha: 0.65)
                              //             : onSurface.withValues(alpha: 0.65),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: onSurface.withValues(alpha: 0.28),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (index < options.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                ),
            ],
          );
        }),
      ),
    );
  }
}
