import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayxFlowService {
  DayxFlowService({NetworkService? network})
      : _network = network ?? locator<NetworkService>();

  final NetworkService _network;

  static List<DayxFlowWalletBalance> balancesFromHub(WalletHubSnapshot? hub) {
    if (hub == null) return const [];
    return hub.displayRows
        .map(
          (r) => DayxFlowWalletBalance(
            currency: r.currency,
            balance: r.balance,
          ),
        )
        .toList();
  }

  Future<DayxFlowTurnResult> turn({
    required String flow,
    required String action,
    DayxFlowSession? session,
    String? optionId,
    String? field,
    Object? value,
    String? utterance,
    List<DayxFlowWalletBalance>? walletBalances,
    String? preferredFromCurrency,
    WidgetRef? ref,
  }) async {
    List<DayxFlowWalletBalance>? balances = walletBalances;
    if (balances == null && ref != null) {
      balances = balancesFromHub(ref.read(walletHubProvider).hub);
    }

    final response = await _network.call(
      '${F.baseUrl}/dayx/flow/turn',
      RequestMethod.post,
      data: {
        'flow': flow,
        'action': action,
        if (session != null) 'session': session.toJson(),
        if (optionId != null) 'optionId': optionId,
        if (field != null) 'field': field,
        if (value != null) 'value': value,
        if (utterance != null) 'utterance': utterance,
        if (balances != null && balances.isNotEmpty)
          'walletBalances': balances.map((b) => b.toJson()).toList(),
        if (preferredFromCurrency != null)
          'preferredFromCurrency': preferredFromCurrency.toUpperCase(),
      },
    );
    final root = response.data;
    if (root is! Map<String, dynamic>) {
      throw const DayxFlowException('Invalid DayX flow response');
    }
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    return DayxFlowTurnResult.fromJson(data);
  }
}

class DayxFlowException implements Exception {
  final String message;
  const DayxFlowException(this.message);

  @override
  String toString() => message;
}
