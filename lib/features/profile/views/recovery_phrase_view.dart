import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the one-time recovery phrase from secure storage, or help when absent.
class RecoveryPhraseView extends StatefulWidget {
  const RecoveryPhraseView({super.key});

  @override
  State<RecoveryPhraseView> createState() => _RecoveryPhraseViewState();
}

class _RecoveryPhraseViewState extends State<RecoveryPhraseView> {
  String _phrase = '';
  bool _loading = true;
  bool _confirmed = false;
  bool _saving = false;

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
      });
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0.5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(
          'Recovery phrase',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _phrase.isEmpty
                            ? 'No recovery phrase is stored on this device. If you already created on-chain wallets, the phrase was only shown once. Contact support if you need help.'
                            : 'Write these words in order and store them offline. Anyone with this phrase can move your funds.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          fontFamily: 'Chirp',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_phrase.isNotEmpty) ...[
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
                              color: AppColors.warning500.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (
                                var i = 0;
                                i < _phrase.split(' ').length;
                                i++
                              )
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
                          onChanged:
                              (v) => setState(() => _confirmed = v ?? false),
                          title: Text(
                            'I have written my phrase down in a safe place',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontFamily: 'Chirp'),
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
                      ] else ...[
                        const SizedBox(height: 24),
                        FutureBuilder<Map<String, dynamic>>(
                          future: localCache.getUser(),
                          builder: (context, snap) {
                            final backed =
                                snap.hasData
                                    ? User.fromJson(snap.data!).isWalletBackedUp
                                    : true;
                            if (backed) {
                              return Text(
                                '',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Chirp',
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                            return Text(
                              'Your profile still shows that a backup is needed. After you secure a new phrase from support or a new wallet setup, return here.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontFamily: 'Chirp',
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
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
