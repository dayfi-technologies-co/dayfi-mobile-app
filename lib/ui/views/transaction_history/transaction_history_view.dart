import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'transaction_history_viewmodel.dart';

class TransactionHistoryView extends StackedView<TransactionHistoryViewModel> {
  const TransactionHistoryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TransactionHistoryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("TransactionHistoryView")),
      ),
    );
  }

  @override
  TransactionHistoryViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TransactionHistoryViewModel();
}
