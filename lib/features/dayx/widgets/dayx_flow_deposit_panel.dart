import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/widgets/dayfi_readonly_copy_field.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/wallet/constants/grey_demo_bank_accounts.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inline add-money details (username / bank / crypto) inside DayX — no navigation.
class DayxFlowDepositPanel extends ConsumerStatefulWidget {
  final DayxFlowDepositData panel;

  const DayxFlowDepositPanel({super.key, required this.panel});

  @override
  ConsumerState<DayxFlowDepositPanel> createState() =>
      _DayxFlowDepositPanelState();
}

class _DayxFlowDepositPanelState extends ConsumerState<DayxFlowDepositPanel> {
  String _tab = 'username';
  Map<String, dynamic>? _crypto;
  bool _loadingCrypto = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.panel.tabs.isNotEmpty ? widget.panel.tabs.first : 'username';
    if (widget.panel.tabs.contains('crypto')) {
      _loadCrypto();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletHubProvider.notifier).load(showLoading: false);
    });
  }

  Future<void> _loadCrypto() async {
    setState(() => _loadingCrypto = true);
    try {
      final data = await walletService.fetchReceiveCrypto();
      if (mounted) setState(() => _crypto = data);
    } catch (_) {
      /* optional */
    } finally {
      if (mounted) setState(() => _loadingCrypto = false);
    }
  }

  String? get _dayfiId {
    final cached = locator<LocalCache>().getFromLocalCache('dayfi_id');
    if (cached != null && cached.toString().isNotEmpty) {
      final t = cached.toString();
      return t.startsWith('@') ? t : '@$t';
    }
    final profile = ref.read(profileViewModelProvider).user;
    final fromUser = profile?.dayfiId;
    if (fromUser != null && fromUser.isNotEmpty) {
      return fromUser.startsWith('@') ? fromUser : '@$fromUser';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.panel.currency.toUpperCase();
    final hub = ref.watch(walletHubProvider).hub;
    final ngnRow = hub?.rowFor('NGN');
    final grey = hub?.greyFor(currency);
    final tabs = widget.panel.tabs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tabs.length > 1)
          Wrap(
            spacing: 8,
            children: tabs.map((t) {
              final label = t == 'username'
                  ? UsernameCopy.label
                  : t == 'bank'
                      ? 'Bank'
                      : 'On-chain';
              final selected = _tab == t;
              return ChoiceChip(
                label: Text(label, style: const TextStyle(fontFamily: 'Chirp')),
                selected: selected,
                onSelected: (_) => setState(() => _tab = t),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        if (_tab == 'username') _usernameTab(),
        if (_tab == 'bank') _bankTab(currency, ngnRow, grey),
        if (_tab == 'crypto') _cryptoTab(currency),
      ],
    );
  }

  Widget _usernameTab() {
    final tag = _dayfiId;
    if (tag == null || tag.isEmpty) {
      return Text(
        UsernameCopy.setInProfile,
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    final raw = tag.startsWith('@') ? tag.substring(1) : tag;
    return DayfiReadonlyCopyField(
      label: UsernameCopy.your,
      value: '@$raw',
      shareText: '@$raw',
      shareSubject: 'My DayFi username',
    );
  }

  Widget _bankTab(String currency, dynamic ngnRow, dynamic grey) {
    final demo = greyDemoBankFor(currency);
    final usesDemo = demo != null && !(grey?.hasBankDisplayDetails ?? false);
    String account = '';
    String bankName = 'Bank';
    if (currency == 'NGN') {
      account = ngnRow?.accountNumber?.toString() ?? '';
      bankName = ngnRow?.bankName?.toString() ?? 'Bank';
    } else if (usesDemo) {
      account = demo.accountNumber;
      bankName = demo.bankName;
    } else if (grey != null) {
      account = grey.accountNumber ?? grey.iban ?? '';
      bankName = grey.bankName ?? 'Grey';
    }

    if (account.isEmpty) {
      return Text(
        currency == 'NGN'
            ? 'Complete identity verification to get your NGN virtual account.'
            : 'Bank details will appear here once your account is ready.',
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Column(
      children: [
        DayfiReadonlyCopyField(
          label: 'Account number',
          value: account,
          shareText: 'Bank: $bankName\nAccount: $account\nCurrency: $currency',
          shareSubject: 'Bank account ($currency)',
        ),
        const SizedBox(height: 8),
        Text(
          bankName,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _cryptoTab(String currency) {
    if (_loadingCrypto) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: DayfiLoadingIndicator(),
      );
    }
    final coin = widget.panel.coinLabel ??
        (currency == 'EUR' ? 'EURC' : 'USDC');
    final stellar = _crypto?['stellarAddress']?.toString() ?? '';
    final eth = _crypto?['ethereumAddress']?.toString() ?? '';
    if (stellar.isEmpty && eth.isEmpty) {
      return Text(
        'Crypto deposit addresses are still setting up. Pull to refresh in Add money later.',
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Send $coin on Stellar (recommended) or Ethereum ERC-20.',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        if (stellar.isNotEmpty) ...[
          const SizedBox(height: 10),
          DayfiReadonlyCopyField(
            label: 'Stellar',
            value: stellar,
            shareText: '$coin (Stellar)\n$stellar',
            maxLines: 3,
          ),
        ],
        if (eth.isNotEmpty) ...[
          const SizedBox(height: 10),
          DayfiReadonlyCopyField(
            label: 'Ethereum',
            value: eth,
            shareText: '$coin (ERC-20)\n$eth',
            maxLines: 3,
          ),
        ],
      ],
    );
  }
}
