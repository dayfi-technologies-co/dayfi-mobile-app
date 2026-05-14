import 'package:dayfi/features/send/views/digital_dollar_send_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **Send** digital dollar on-chain: network + asset pickers, recipient, amount, memo.
class SendScreen extends ConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DigitalDollarSendView();
  }
}
