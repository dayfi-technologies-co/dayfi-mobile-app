/// Crypto network metadata for receive + send (mirrors backend `cryptoNetworks.ts`).
class CryptoNetworkOption {
  final String key;
  final String name;
  final String subtitle;
  final String rail;
  final bool recommended;
  final bool enabled;
  final List<String> assets;
  final String address;
  final double estimatedNetworkFeeUsd;
  final double platformFeeUsd;
  final String feeLabel;

  const CryptoNetworkOption({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.rail,
    this.recommended = false,
    this.enabled = true,
    this.assets = const ['USDC'],
    this.address = '',
    this.estimatedNetworkFeeUsd = 0,
    this.platformFeeUsd = 0.05,
    this.feeLabel = '',
  });

  factory CryptoNetworkOption.fromJson(Map<String, dynamic> json) {
    final assetsRaw = json['assets'];
    final networkFee =
        double.tryParse(json['estimatedNetworkFeeUsd']?.toString() ?? '') ?? 0;
    final platform =
        double.tryParse(json['platformFeeUsd']?.toString() ?? '') ?? 0.05;
    final feeLabelRaw = json['feeLabel']?.toString().trim() ?? '';
    return CryptoNetworkOption(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      rail: json['rail']?.toString() ?? 'evm',
      recommended: json['recommended'] == true,
      enabled: json['enabled'] != false,
      assets:
          assetsRaw is List
              ? assetsRaw.map((e) => e.toString()).toList()
              : const ['USDC'],
      address: json['address']?.toString() ?? '',
      estimatedNetworkFeeUsd: networkFee,
      platformFeeUsd: platform,
      feeLabel:
          feeLabelRaw.isNotEmpty
              ? feeLabelRaw
              : CryptoNetworkCatalog.formatFeeUsd(networkFee),
    );
  }

  double get totalFeeUsd => estimatedNetworkFeeUsd + platformFeeUsd;

  String get totalFeeLabel => CryptoNetworkCatalog.formatFeeUsd(totalFeeUsd);

  bool supportsAsset(String assetCode) {
    return assets.map((a) => a.toUpperCase()).contains(assetCode.toUpperCase());
  }
}

class CryptoNetworkCatalog {
  CryptoNetworkCatalog._();

  static const stellarIcon = 'assets/icons/svgs/brand-stellar.svg';
  static const evmIcon = 'assets/icons/svgs/currency-ethereum.svg';
  static const genericIcon = 'assets/icons/svgs/coin.svg';
  static const defaultPlatformFeeUsd = 0.05;

  /// Shown in receive/send network pickers (Stellar + top EVM rails).
  static const topNetworkKeys = [
    'stellar',
    'ethereum',
    'bsc',
    'arbitrum',
  ];

  static List<CryptoNetworkOption> topNetworks(List<CryptoNetworkOption> all) {
    final picked = <CryptoNetworkOption>[];
    for (final key in topNetworkKeys) {
      final match = find(all, key);
      if (match != null) picked.add(match);
    }
    return picked;
  }

  static String formatFeeUsd(double amount) {
    if (amount < 0.01) return '≈ \$0.01';
    return '≈ \$${amount.toStringAsFixed(2)}';
  }

  static List<CryptoNetworkOption> defaultsForReceive({
    String stellarAddress = '',
    String evmAddress = '',
  }) {
    return [
      CryptoNetworkOption(
        key: 'stellar',
        name: 'Stellar',
        subtitle: 'Recommended',
        rail: 'stellar',
        recommended: true,
        assets: const ['USDC', 'EURC'],
        address: stellarAddress,
        estimatedNetworkFeeUsd: 0.01,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(0.01),
      ),
      CryptoNetworkOption(
        key: 'ethereum',
        name: 'Ethereum',
        subtitle: 'ERC-20',
        rail: 'evm',
        assets: const ['USDC', 'EURC'],
        address: evmAddress,
        estimatedNetworkFeeUsd: 2.5,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(2.5),
      ),
      CryptoNetworkOption(
        key: 'bsc',
        name: 'BNB Smart Chain',
        subtitle: 'BEP-20',
        rail: 'evm',
        assets: const ['USDC'],
        address: evmAddress,
        estimatedNetworkFeeUsd: 0.15,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(0.15),
      ),
      CryptoNetworkOption(
        key: 'arbitrum',
        name: 'Arbitrum One',
        subtitle: 'ERC-20',
        rail: 'evm',
        assets: const ['USDC'],
        address: evmAddress,
        estimatedNetworkFeeUsd: 0.2,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(0.2),
      ),
      CryptoNetworkOption(
        key: 'mantle',
        name: 'Mantle Network',
        subtitle: 'ERC-20',
        rail: 'evm',
        assets: const ['USDC'],
        address: evmAddress,
        estimatedNetworkFeeUsd: 0.05,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(0.05),
      ),
      CryptoNetworkOption(
        key: 'sonic',
        name: 'Sonic',
        subtitle: 'ERC-20',
        rail: 'evm',
        assets: const ['USDC'],
        address: evmAddress,
        estimatedNetworkFeeUsd: 0.02,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(0.02),
      ),
      CryptoNetworkOption(
        key: 'xdc',
        name: 'XDC Network',
        subtitle: 'XRC-20',
        rail: 'evm',
        assets: const ['USDC'],
        address: evmAddress,
        estimatedNetworkFeeUsd: 0.02,
        platformFeeUsd: defaultPlatformFeeUsd,
        feeLabel: formatFeeUsd(0.02),
      ),
    ];
  }

  static List<CryptoNetworkOption> parseReceiveNetworks(
    Map<String, dynamic>? payload, {
    String stellarAddress = '',
    String evmAddress = '',
  }) {
    final raw = payload?['networks'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((e) => CryptoNetworkOption.fromJson(Map<String, dynamic>.from(e)))
          .map((n) {
            if (n.address.trim().isNotEmpty) return n;
            if (n.rail == 'stellar') {
              return CryptoNetworkOption(
                key: n.key,
                name: n.name,
                subtitle: n.subtitle,
                rail: n.rail,
                recommended: n.recommended,
                enabled: n.enabled,
                assets: n.assets,
                address: stellarAddress,
                estimatedNetworkFeeUsd: n.estimatedNetworkFeeUsd,
                platformFeeUsd: n.platformFeeUsd,
                feeLabel: n.feeLabel,
              );
            }
            if (n.rail == 'evm') {
              return CryptoNetworkOption(
                key: n.key,
                name: n.name,
                subtitle: n.subtitle,
                rail: n.rail,
                recommended: n.recommended,
                enabled: n.enabled,
                assets: n.assets,
                address: evmAddress,
                estimatedNetworkFeeUsd: n.estimatedNetworkFeeUsd,
                platformFeeUsd: n.platformFeeUsd,
                feeLabel: n.feeLabel,
              );
            }
            return n;
          })
          .where((n) => n.key.isNotEmpty)
          .toList();
    }
    return topNetworks(
      defaultsForReceive(
        stellarAddress: stellarAddress,
        evmAddress: evmAddress,
      ),
    );
  }

  static List<CryptoNetworkOption> parseSendNetworks(Map<String, dynamic>? config) {
    final raw = config?['networks'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((e) => CryptoNetworkOption.fromJson(Map<String, dynamic>.from(e)))
          .where((n) => n.key.isNotEmpty)
          .toList();
    }
    return topNetworks(defaultsForReceive());
  }

  static CryptoNetworkOption? find(List<CryptoNetworkOption> list, String key) {
    for (final n in list) {
      if (n.key == key) return n;
    }
    return null;
  }

  static String networkName(List<CryptoNetworkOption> networks, String key) {
    return find(networks, key)?.name ??
        (key.isEmpty ? key : key[0].toUpperCase() + key.substring(1));
  }

  static String iconAsset(String key) {
    switch (key) {
      case 'stellar':
        return stellarIcon;
      case 'ethereum':
      case 'bsc':
      case 'arbitrum':
      case 'mantle':
      case 'sonic':
      case 'xdc':
        return evmIcon;
      default:
        return genericIcon;
    }
  }

  static String displayNetworkLabel(CryptoNetworkOption network) {
    if (network.key == 'ethereum') return 'Ethereum (ERC-20)';
    if (network.rail == 'stellar') return 'Stellar Network';
    return network.name;
  }

  static String recipientHint(CryptoNetworkOption network) {
    switch (network.rail) {
      case 'stellar':
        return 'Stellar address (G…)';
      case 'evm':
        return 'Wallet address (0x…)';
      default:
        return 'Wallet address';
    }
  }

  static bool isValidRecipientAddress(CryptoNetworkOption network, String raw) {
    final value = raw.trim();
    if (value.isEmpty) return false;
    switch (network.rail) {
      case 'stellar':
        return RegExp(r'^G[A-Z0-9]{55}$').hasMatch(value);
      case 'evm':
        return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(value);
      default:
        return value.isNotEmpty;
    }
  }

  static List<String> sendNetworkKeysForAsset(
    Map<String, dynamic>? assetsMap,
    String assetCode,
    List<CryptoNetworkOption> networks,
  ) {
    final raw = assetsMap?[assetCode];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).toList();
    }
    return networks
        .where((n) => n.supportsAsset(assetCode))
        .map((n) => n.key)
        .toList();
  }
}
