import 'package:dayfi/features/send/views/digital_dollar_receive_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Receive **via digital dollar**: USDC (Stellar / Ethereum) or USDT (Ethereum).
class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DigitalDollarReceiveView();
  }
}
