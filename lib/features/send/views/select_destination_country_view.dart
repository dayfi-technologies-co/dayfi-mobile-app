import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/features/send/constants/send_country_metadata.dart';
import 'package:dayfi/features/send/helpers/standard_send_destinations.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/send/constants/send_copy.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';

class SelectDestinationCountryView extends ConsumerStatefulWidget {
  final bool hasBackButton;
  final bool addRecipientOnly;

  const SelectDestinationCountryView({
    super.key,
    this.hasBackButton = true,
    this.addRecipientOnly = false,
  });

  @override
  ConsumerState<SelectDestinationCountryView> createState() =>
      _SelectDestinationCountryViewState();
}

enum _SendDestinationScope { all, global, standard }

class _DestinationListEntry {
  final String? sectionTitle;
  final Channel? channel;

  const _DestinationListEntry.header(this.sectionTitle) : channel = null;
  const _DestinationListEntry.row(this.channel) : sectionTitle = null;

  bool get isHeader => sectionTitle != null;
}

class _SelectDestinationCountryViewState
    extends ConsumerState<SelectDestinationCountryView> {
  final TextEditingController _searchController = TextEditingController();
  _SendDestinationScope _scope = _SendDestinationScope.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = ref.read(sendViewModelProvider.notifier);
      if (!viewModel.isInitialized && !viewModel.isInitializing) {
        await viewModel.initialize();
      }
      analyticsService.trackScreenView(
        screenName: 'SelectDestinationCountryView',
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCountryName(String? countryCode) =>
      sendCountryDisplayName(countryCode);

  List<_DestinationListEntry> _buildDestinationListEntries({
    required List<Channel> globalChannels,
    required List<Channel> standardChannels,
    required bool showSectionHeaders,
  }) {
    final entries = <_DestinationListEntry>[];

    void appendSection({
      required String title,
      required List<Channel> channels,
    }) {
      if (channels.isEmpty) return;
      if (showSectionHeaders) {
        entries.add(_DestinationListEntry.header(title));
      }
      for (final channel in channels) {
        entries.add(_DestinationListEntry.row(channel));
      }
    }

    switch (_scope) {
      case _SendDestinationScope.all:
        appendSection(title: 'Global', channels: globalChannels);
        appendSection(title: 'Standard', channels: standardChannels);
      case _SendDestinationScope.global:
        appendSection(title: 'Global', channels: globalChannels);
      case _SendDestinationScope.standard:
        appendSection(title: 'Standard', channels: standardChannels);
    }

    return entries;
  }

  Widget _buildScopeFilter(BuildContext context, bool isWide) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _scopeChip(context, label: 'All', scope: _SendDestinationScope.all),
          _scopeChip(context, label: 'Global', scope: _SendDestinationScope.global),
          _scopeChip(
            context,
            label: 'Standard',
            scope: _SendDestinationScope.standard,
          ),
        ],
      ),
    );
  }

  Widget _scopeChip(
    BuildContext context, {
    required String label,
    required _SendDestinationScope scope,
  }) {
    final selected = _scope == scope;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => setState(() => _scope = scope),
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  selected
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.2,
                color:
                    selected
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isWide,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 24 : 18,
        14,
        isWide ? 24 : 18,
        6,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
        ),
      ),
    );
  }

  String _getFlagPath(String? countryCode) {
    final code = countryCode?.toUpperCase() ?? '';
    if (code == 'DE') return WalletFlagAssets.eur;
    return sendCountryFlagAsset(countryCode);
  }

  @override
  Widget build(BuildContext context) {
    // Define top 7 African countries for quick send
    // final List<Map<String, String>> topAfricanCountries = [
    //   {'code': 'NG', 'name': 'Nigeria', 'currency': 'NGN'},
    //   {'code': 'GH', 'name': 'Ghana', 'currency': 'GHS'},
    //   {'code': 'KE', 'name': 'Kenya', 'currency': 'KES'},
    //   {'code': 'UG', 'name': 'Uganda', 'currency': 'UGX'},
    //   {'code': 'TZ', 'name': 'Tanzania', 'currency': 'TZS'},
    //   {'code': 'RW', 'name': 'Rwanda', 'currency': 'RWF'},
    //   {'code': 'ZA', 'name': 'South Africa', 'currency': 'ZAR'},
    // ];
    final sendState = ref.watch(sendViewModelProvider);

    // Pin PRD wallets (USD, GBP, EUR, NGN) at top, then Yellow Card corridors.
    final coreChannels = <Channel>[
      for (final d in kCoreSendDestinations)
        Channel(
          country: d.country,
          currency: d.currency,
          rampType: 'withdrawal',
          status: 'active',
          min: 0,
          max: 999999999,
          id: 'core_${d.currency}',
        ),
    ];

    final standardChannels = buildStandardSendDestinations(
      sendState.channels,
    );

    var finalWithdrawalChannels = [...coreChannels, ...standardChannels];

    // If no withdrawal channels, add fallback
    if (finalWithdrawalChannels.isEmpty) {
      final alternativeChannels =
          sendState.channels
              .where(
                (channel) =>
                    channel.status == 'active' &&
                    channel.currency != null &&
                    channel.country != null &&
                    (channel.rampType == 'withdrawal' ||
                        channel.rampType == 'withdraw' ||
                        channel.rampType == 'payout' ||
                        channel.rampType == 'deposit' ||
                        channel.rampType == 'receive'),
              )
              .toList();

      if (alternativeChannels.isNotEmpty) {
        finalWithdrawalChannels = alternativeChannels;
      } else {
        finalWithdrawalChannels = [
          Channel(
            country: 'NG',
            currency: 'NGN',
            rampType: 'withdrawal',
            status: 'active',
            min: 1000.0,
            max: 5000000.0,
          ),
        ];
      }
    }

    return
    // DefaultTabController(
    //   length: 2,
    //   initialIndex: 0,
    //   child:
    Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: widget.addRecipientOnly ? 'Add recipient' : 'Send money',
        showBackButton: widget.hasBackButton,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child:
              // TabBarView(
              //   children: [
              Builder(
                builder: (context) {
                  // Shimmer only while the send flow is actively loading channels.
                  // Do not use `channels.isEmpty` here: after a failed fetch the list
                  // stays empty but `isLoading` is false, which would show skeletons forever.
                  if (sendState.isLoading) {
                    return ShimmerWidgets.recipientListShimmer(
                      context,
                      itemCount: 6,
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 24 : 18,
                        12,
                        isWide ? 24 : 18,
                        112,
                      ),
                    );
                  }

                  // Get all channels
                  final allChannels =
                      finalWithdrawalChannels.isEmpty
                          ? (() {
                            final fallbackChannels =
                                sendState.channels
                                    .where(
                                      (c) =>
                                          c.status == 'active' &&
                                          c.currency != null &&
                                          c.country != null &&
                                          (c.rampType == 'withdrawal' ||
                                              c.rampType == 'withdraw' ||
                                              c.rampType == 'payout' ||
                                              c.rampType == 'deposit' ||
                                              c.rampType == 'receive'),
                                    )
                                    .toList();

                            // Deduplicate fallback channels
                            final uniqueFallbackChannels = <String, Channel>{};
                            for (final channel in fallbackChannels) {
                              final key =
                                  '${channel.country} - ${channel.currency}';
                              if (!uniqueFallbackChannels.containsKey(key) ||
                                  (channel.max ?? 0) >
                                      (uniqueFallbackChannels[key]?.max ?? 0)) {
                                uniqueFallbackChannels[key] = channel;
                              }
                            }

                            return uniqueFallbackChannels.values.toList();
                          })()
                          : finalWithdrawalChannels;

                  // Additional deduplication to ensure no duplicates
                  final uniqueChannels = <String, Channel>{};
                  for (final channel in allChannels) {
                    final key = '${channel.country} - ${channel.currency}';
                    if (!uniqueChannels.containsKey(key)) {
                      uniqueChannels[key] = channel;
                    }
                  }
                  final deduplicatedChannels = uniqueChannels.values.toList();

                  final searchQuery = _searchController.text.toLowerCase();
                  final filteredChannels =
                      deduplicatedChannels.where((channel) {
                        if (searchQuery.isEmpty) return true;

                        final countryName =
                            _getCountryName(channel.country).toLowerCase();
                        final currency = channel.currency?.toLowerCase() ?? '';
                        final countryCode =
                            channel.country?.toLowerCase() ?? '';

                        return countryName.contains(searchQuery) ||
                            currency.contains(searchQuery) ||
                            countryCode.contains(searchQuery);
                      }).toList();

                  final globalChannels =
                      filteredChannels
                          .where(isGlobalSendDestination)
                          .toList();
                  final standardChannels =
                      filteredChannels
                          .where((c) => !isGlobalSendDestination(c))
                          .toList();
                  sortGlobalSendDestinations(globalChannels);
                  sortStandardSendDestinations(standardChannels);

                  final listEntries = _buildDestinationListEntries(
                    globalChannels: globalChannels,
                    standardChannels: standardChannels,
                    showSectionHeaders: searchQuery.isEmpty,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    itemCount: listEntries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 24 : 18,
                              ),
                              child: CustomTextField(
                                isSearch: true,
                                controller: _searchController,
                                label: '',
                                hintText: 'Search',
                                borderRadius: 40,
                                prefixIcon: Container(
                                  width: 40,
                                  alignment: Alignment.centerRight,
                                  constraints:
                                      const BoxConstraints.tightForFinite(),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/svgs/search-normal.svg',
                                      height: 22,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            // const SizedBox(height: 16),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: isWide ? 24 : 18,
                            //   ),
                            //   child: _buildScopeFilter(context, isWide),
                            // ),
                            const SizedBox(height: 14),
                            DayfiScreenDescription(
                              text:
                                  widget.addRecipientOnly
                                      ? SendCopy.chooseRecipientCountry
                                      : SendCopy.chooseDestination,
                              bottomSpacing: 12,
                            ),
                          ],
                        );
                      }

                      final entry = listEntries[index - 1];
                      if (entry.isHeader) {
                        return _buildSectionHeader(
                          context,
                          entry.sectionTitle!,
                          isWide,
                        );
                      }

                      final channel = entry.channel!;
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: isWide ? 24 : 18,
                        ),
                        splashColor: Colors.transparent,
                        onTap: () {
                          final country = channel.country ?? 'NG';
                          final currency = channel.currency ?? 'NGN';
                          if (widget.addRecipientOnly) {
                            handleSaveRecipientDestinationSelected(
                              context,
                              ref,
                              countryCode: country,
                              receiveCurrency: currency,
                            );
                          } else {
                            handleSendDestinationSelected(
                              context,
                              ref,
                              countryCode: country,
                              receiveCurrency: currency,
                            );
                          }
                        },
                        title: Row(
                          children: [
                            SvgPicture.asset(
                              _getFlagPath(channel.country),
                              height: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getCountryName(channel.country),
                                style: AppTypography.bodyLarge.copyWith(
                                  fontFamily: 'Chirp',
                                  fontSize: 16,
                                  letterSpacing: -.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          channel.currency ?? '',
                          style: AppTypography.bodyLarge.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            letterSpacing: -.4,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.55),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Tab 2: Crypto - empty scaffold
              // SendFetchCryptoChannelsView(),
              // ],
              // ),
            ),
          );
        },
      ),
    );
  }
}
