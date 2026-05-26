import 'package:dayfi/features/send/send_flow.dart';
import 'package:flutter/material.dart';

/// Shared entry for “Send money” from Home, recipients, transactions, etc.
Future<void> openSendMoneyEntry(BuildContext context) =>
    openSendFromHomeOrTab(context);
