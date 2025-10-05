import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/send/views/send_view.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RecipientsView extends ConsumerStatefulWidget {
  const RecipientsView({super.key});

  @override
  ConsumerState<RecipientsView> createState() => _RecipientsViewState();
}

class _RecipientsViewState extends ConsumerState<RecipientsView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipientsProvider.notifier).loadBeneficiaries();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh recipients when app comes back to foreground
      _refreshRecipients();
    }
  }

  void _refreshRecipients() {
    ref.read(recipientsProvider.notifier).loadBeneficiaries();
  }

  @override
  Widget build(BuildContext context) {
    final recipientsState = ref.watch(recipientsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Recipients",
            style: AppTypography.titleLarge.copyWith(
            fontFamily: 'CabinetGrotesk',
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     icon: Container(
          //       width: 32.w,
          //       height: 32.w,
          //       decoration: BoxDecoration(
          //         color: AppColors.purple500,
          //         shape: BoxShape.circle,
          //       ),
          //       child: Icon(
          //         Icons.add,
          //         color: AppColors.neutral0,
          //         size: 20.sp,
          //       ),
          //     ),
          //     onPressed: () => _navigateToAddRecipient(),
          //   ),
          //   SizedBox(width: 16.w),
          // ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _refreshRecipients();
          },
          child: Column(
            children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: CustomTextField(
                controller: _searchController,
                label: '',
                hintText: 'Search...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  size: 20.sp,
                ),
                onChanged: (value) {
                  ref
                      .read(recipientsProvider.notifier)
                      .searchBeneficiaries(value);
                },
              ),
            ),

            // Recipients List
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 0.h),
                child:
                    recipientsState.isLoading
                        ? Center(
                          child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: AppColors.purple500,
                            size: 20,
                          ),
                        )
                        : recipientsState.errorMessage != null
                        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                              // Icon(
                              //   Icons.error_outline,
                              //   size: 48.sp,
                              //   color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              // ),
                              // SizedBox(height: 16.h),
                              Text(
                                'Failed to load recipients',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
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
                              SizedBox(height: 8.h),
          Text(
                                recipientsState.errorMessage!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  letterSpacing: -.6,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
          ),
        ],
      ),
                        )
                        : recipientsState.filteredBeneficiaries.isEmpty
                        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                              // Icon(
                              //   Icons.person_outline,
                              //   size: 48.sp,
                              //   color: Theme.of(
                              //     context,
                              //   ).colorScheme.onSurface.withOpacity(0.6),
                              // ),
                              // SizedBox(height: 16.h),
          Text(
                                'No recipients found',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
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
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          itemCount:
                              recipientsState.filteredBeneficiaries.length,
                          itemBuilder: (context, index) {
                            final beneficiary =
                                recipientsState.filteredBeneficiaries[index];
                            return _buildRecipientCard(beneficiary);
                          },
              ),
            ),
          ),
        ],
      ),
          ),
      ),
    );
  }

  Widget _buildRecipientCard(Beneficiary beneficiary) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.purple500,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(beneficiary.name),
                style: TextStyle(
                  color: AppColors.neutral0,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Karla',
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Beneficiary Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiary.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_getAccountType(beneficiary)} - ${_getAccountNumber(beneficiary)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (beneficiary.country.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    '${beneficiary.country} • ${beneficiary.phone.isNotEmpty ? beneficiary.phone : 'No phone'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Send Button
          PrimaryButton(
            text: 'Send',
            onPressed: () => _navigateToSend(beneficiary),
            height: 36.h,
            width: 80.w,
            backgroundColor: AppColors.purple500,
            textColor: AppColors.neutral0,
            fontFamily: 'Karla',
            fontSize: 14.sp,
            borderRadius: 20.r,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  String _getAccountType(Beneficiary beneficiary) {
    // Use actual account type from beneficiary data
    return beneficiary.idType.isNotEmpty ? beneficiary.idType : 'Bank Account';
  }

  String _getAccountNumber(Beneficiary beneficiary) {
    // Use actual account number from beneficiary data
    if (beneficiary.idNumber.isNotEmpty) {
      return beneficiary.idNumber;
    } else if (beneficiary.phone.isNotEmpty) {
      return beneficiary.phone;
    } else {
      return 'N/A';
    }
  }

  void _navigateToSend(Beneficiary beneficiary) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendView()),
    );
  }
}
