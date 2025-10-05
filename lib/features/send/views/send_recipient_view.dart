import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/views/send_add_recipients_view.dart';

class SendRecipientView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendRecipientView({super.key, required this.selectedData});

  @override
  ConsumerState<SendRecipientView> createState() => _SendRecipientViewState();
}

class _SendRecipientViewState extends ConsumerState<SendRecipientView> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  bool _isResolving = false;
  String? _resolvedAccountName;
  String? _resolveError;

  @override
  void initState() {
    super.initState();
    _loadSelectedData();
  }

  void _loadSelectedData() {
    print('📋 Selected Data: ${widget.selectedData}');
  }

  Future<void> _resolveAccount() async {
    if (_accountNumberController.text.trim().isEmpty) {
      setState(() {
        _resolveError = 'Please enter an account number';
        _resolvedAccountName = null;
      });
      return;
    }

    setState(() {
      _isResolving = true;
      _resolveError = null;
      _resolvedAccountName = null;
    });

    try {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.resolveBank(
        accountNumber: _accountNumberController.text.trim(),
        networkId: widget.selectedData['networkId'] ?? '',
      );

      if (response.statusCode == 200 && !response.error) {

        setState(() {
          _resolvedAccountName = 'Account Resolved Successfully';
          _resolveError = null;
        });
      } else {
        setState(() {
          _resolveError = response.message;
          _resolvedAccountName = null;
        });
      }
    } catch (e) {
      setState(() {
        _resolveError = 'Error resolving account: $e';
        _resolvedAccountName = null;
      });
    } finally {
      setState(() {
        _isResolving = false;
      });
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
                scrolledUnderElevation: 0,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            // size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recipients',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 28.00,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    final country = widget.selectedData['receiveCountry'] ?? 'Unknown';
    final currency = widget.selectedData['receiveCurrency'] ?? 'Unknown';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state image
            // Container(
            //   width: 120.w,
            //   height: 120.w,
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.surfaceVariant,
            //     shape: BoxShape.circle,
            //   ),
            //   child: Icon(
            //     Icons.person_add_outlined,
            //     size: 60.sp,
            //     color: Theme.of(context).colorScheme.onSurfaceVariant,
            //   ),
            // ),

            // SizedBox(height: 32.h),

            // // Title
            // Text(
            //   'No Recipients Yet',
            //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //     fontFamily: 'CabinetGrotesk',
            //     fontSize: 24.sp,
            //     fontWeight: FontWeight.w600,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 16.h),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Text(
                'You do not have any Recipients yet for $country ($currency)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'CabinetGrotesk',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  height: 1.4,
                  letterSpacing: -.4,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 48.h),

            // Create Recipients Button
            PrimaryButton(
              borderRadius: 38,
              text: 'Create Recipients',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SendAddRecipientsView(
                          selectedData: widget.selectedData,
                        ),
                  ),
                );
              },
              backgroundColor: AppColors.purple500,
              height: 60.h,
              textColor: AppColors.neutral0,
              fontFamily: 'Karla',
              letterSpacing: -.8,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
              // isLoading: state.isLoading,
            ),

            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}
