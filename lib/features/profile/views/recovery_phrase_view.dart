import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/profile/profile_settings_navigation.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows recovery phrase from device storage or server (PIN required), like dayfi.wallet.
class RecoveryPhraseView extends ConsumerStatefulWidget {
  const RecoveryPhraseView({super.key});

  @override
  ConsumerState<RecoveryPhraseView> createState() => _RecoveryPhraseViewState();
}

class _RecoveryPhraseViewState extends ConsumerState<RecoveryPhraseView> {
  String _phrase = '';
  bool _loading = true;
  bool _confirmed = false;
  bool _saving = false;
  bool _unlocked = false;
  bool _unlocking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await secureStorage.read(StorageKeys.walletRecoveryPhrase);
    if (mounted) {
      setState(() {
        _phrase = raw.trim();
        _loading = false;
        _unlocked = _phrase.isNotEmpty;
      });
    }
  }

  Future<void> _unlockPhrase() async {
    setState(() => _unlocking = true);
    try {
      final bioOk = await BiometricService.authenticate(
        reason: 'Confirm your identity to view your recovery phrase',
      );
      if (!bioOk) {
        if (mounted) {
          TopSnackbar.show(
            context,
            message: 'Authentication cancelled',
            isError: true,
          );
        }
        return;
      }

      final pin = await TransactionPinFlow.requestPin(
        context: context,
        ref: ref,
        returnRoute: AppRoute.recoveryPhraseView,
      );
      if (pin == null || !mounted) return;

      final phrase = await walletProvisionService.fetchRecoveryPhraseFromServer(
        pin: pin,
      );
      if (!mounted) return;
      if (phrase == null || phrase.isEmpty) {
        TopSnackbar.show(
          context,
          message: 'No recovery phrase found for this account',
          isError: true,
        );
        return;
      }
      setState(() {
        _phrase = phrase;
        _unlocked = true;
      });
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _unlocking = false);
    }
  }

  Future<void> _confirmBackedUp() async {
    if (!_confirmed) {
      TopSnackbar.show(
        context,
        message: 'Confirm you have written the phrase down',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await walletProvisionService.confirmRecoveryPhraseBackedUp();
      if (mounted) {
        TopSnackbar.show(context, message: 'Backup recorded', isError: false);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Could not save. Try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _copyPhrase() {
    if (_phrase.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _phrase));
    TopSnackbar.show(context, message: 'Copied', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0.5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new, size: 18, color: onSurface),
        ),
        title: Text(
          'Recovery phrase',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const DayfiLoadingCenter()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!_unlocked) ...[
                      Text(
                        'Your 12-word recovery phrase is stored securely. '
                        'Authenticate to view it again.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          fontFamily: 'Chirp',
                          color: onSurface.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: _unlocking ? 'Unlocking…' : 'View recovery phrase',
                        isLoading: _unlocking,
                        enabled: !_unlocking,
                        onPressed: _unlockPhrase,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'If you never saved your phrase, contact support.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'Chirp',
                          color: onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ProfileSettingsNavigation.contactUs(context),
                        child: Text(
                          'Contact support',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            color: AppColors.purple500ForTheme(context),
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Write these words in order and store them offline. '
                        'Anyone with this phrase can move your funds.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          fontFamily: 'Chirp',
                          color: onSurface.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.warning500.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < _phrase.split(' ').length; i++)
                              Chip(
                                label: Text(
                                  '${i + 1}. ${_phrase.split(' ')[i]}',
                                  style: const TextStyle(
                                    fontFamily: 'Chirp',
                                    fontSize: 13,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _copyPhrase,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy phrase'),
                      ),
                      const SizedBox(height: 18),
                      CheckboxListTile(
                        value: _confirmed,
                        onChanged: (v) => setState(() => _confirmed = v ?? false),
                        title: Text(
                          'I have written my phrase down in a safe place',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Chirp',
                            color: onSurface,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'I have backed up my phrase',
                        isLoading: _saving,
                        enabled: !_saving,
                        onPressed: _confirmBackedUp,
                      ),
                    ],
                    if (!_unlocked) ...[
                      const SizedBox(height: 24),
                      FutureBuilder<Map<String, dynamic>>(
                        future: localCache.getUser(),
                        builder: (context, snap) {
                          final backed = snap.hasData
                              ? User.fromJson(snap.data!).isWalletBackedUp
                              : true;
                          if (backed) return const SizedBox.shrink();
                          return Text(
                            'Your profile still shows that a backup is needed.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'Chirp',
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
