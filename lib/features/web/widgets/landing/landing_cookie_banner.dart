import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/web/constants/landing_copy.dart';
import 'package:dayfi/features/web/widgets/landing/landing_copyable_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cookieConsentKey = 'web_cookie_consent';

enum CookieConsent { accepted, rejected }

/// Bumped when stored consent is cleared so [LandingCookieBanner] can show again.
final cookieConsentRevision = ValueNotifier<int>(0);

Future<void> resetWebCookieConsent() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_cookieConsentKey);
  cookieConsentRevision.value++;
}

/// Bottom cookie consent bar for the public web landing shell.
class LandingCookieBanner extends StatefulWidget {
  const LandingCookieBanner({super.key});

  @override
  State<LandingCookieBanner> createState() => _LandingCookieBannerState();
}

class _LandingCookieBannerState extends State<LandingCookieBanner> {
  CookieConsent? _consent;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    cookieConsentRevision.addListener(_onConsentRevision);
    _loadConsent();
  }

  @override
  void dispose() {
    cookieConsentRevision.removeListener(_onConsentRevision);
    super.dispose();
  }

  void _onConsentRevision() => _loadConsent();

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_cookieConsentKey);
    if (!mounted) return;
    setState(() {
      _consent = switch (stored) {
        'accepted' => CookieConsent.accepted,
        'rejected' => CookieConsent.rejected,
        _ => null,
      };
      _loaded = true;
    });
  }

  Future<void> _saveConsent(CookieConsent value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cookieConsentKey,
      value == CookieConsent.accepted ? 'accepted' : 'rejected',
    );
    if (!mounted) return;
    setState(() => _consent = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _consent != null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 12,
      color: isDark ? AppColors.neutral900 : AppColors.neutral0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final content = [
                Expanded(
                  child: Text(
                    LandingCopy.cookieMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Chirp',
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (isMobile) const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => _saveConsent(CookieConsent.rejected),
                      child: Text(LandingCopy.cookieReject),
                    ),
                    FilledButton(
                      onPressed: () => _saveConsent(CookieConsent.accepted),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orange500,
                        foregroundColor: AppColors.neutral0,
                      ),
                      child: Text(LandingCopy.cookieAccept),
                    ),
                  ],
                ),
              ];

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LandingCopyableText(
                      LandingCopy.cookieMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Chirp',
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _saveConsent(CookieConsent.rejected),
                            child: Text(LandingCopy.cookieReject),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _saveConsent(CookieConsent.accepted),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.orange500,
                              foregroundColor: AppColors.neutral0,
                            ),
                            child: Text(LandingCopy.cookieAccept),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: content,
              );
            },
          ),
        ),
      ),
    );
  }
}
