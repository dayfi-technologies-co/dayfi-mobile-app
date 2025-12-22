import 'dart:developer';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_typography.dart';

class AddWalletAddressView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final String networkKey;
  final String networkName;
  final bool requiresMemo;

  const AddWalletAddressView({
    super.key,
    required this.selectedData,
    required this.networkKey,
    required this.networkName,
    this.requiresMemo = false,
  });

  @override
  ConsumerState<AddWalletAddressView> createState() => _AddWalletAddressViewState();
}

class _AddWalletAddressViewState extends ConsumerState<AddWalletAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _walletAddressController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _walletAddressController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'walletAddress': _walletAddressController.text.trim(),
        if (widget.requiresMemo) 'memo': _memoController.text.trim(),
        'networkKey': widget.networkKey,
        'networkName': widget.networkName,
      });
    } else {
      TopSnackbar.show(context, message: 'Please fill all required fields', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => {
              Navigator.pop(context),
              FocusScope.of(context).unfocus(),
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          title: Text(
            'Add Wallet Address',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 18, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Enter the recipient's wallet address for ${widget.networkName}.",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Chirp',
                              letterSpacing: -.25,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 32),
                        CustomTextField(
                          controller: _walletAddressController,
                          label: 'Wallet Address',
                          hintText: 'Enter wallet address',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Wallet address is required';
                            }
                            return null;
                          },
                        ),
                        if (widget.requiresMemo) ...[
                          SizedBox(height: 24),
                          CustomTextField(
                            controller: _memoController,
                            label: 'Memo',
                            hintText: 'Enter memo',
                            validator: (value) {
                              if (widget.requiresMemo && (value == null || value.trim().isEmpty)) {
                                return 'Memo is required for this network';
                              }
                              return null;
                            },
                          ),
                        ],
                        SizedBox(height: 32),
                        PrimaryButton(
                          text: 'Continue',
                          onPressed: _onContinue,
                          enabled: true,
                          height: 48.0,
                          backgroundColor: AppColors.purple500,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Chirp',
                          letterSpacing: -.70,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          borderRadius: 40,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
