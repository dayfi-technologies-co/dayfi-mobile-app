import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/recipients/models/recipient_model.dart';

class RecipientsView extends ConsumerStatefulWidget {
  const RecipientsView({super.key});

  @override
  ConsumerState<RecipientsView> createState() => _RecipientsViewState();
}

class _RecipientsViewState extends ConsumerState<RecipientsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipientsViewModelProvider.notifier).loadRecipients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipientsState = ref.watch(recipientsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recipients',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showAddRecipientDialog();
            },
            icon: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primary500,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: AppColors.neutral0,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.neutral0,
            padding: EdgeInsets.all(16.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.neutral400,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: (value) {
                  ref.read(recipientsViewModelProvider.notifier).searchRecipients(value);
                },
              ),
            ),
          ),
          
          // Recipients List
          Expanded(
            child: recipientsState.isLoading
                ? _buildLoadingState()
                : recipientsState.filteredRecipients.isEmpty
                    ? _buildEmptyState()
                    : _buildRecipientsList(recipientsState),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary500,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading recipients...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              color: AppColors.neutral400,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No recipients yet',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add recipients to send money quickly',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => _showAddRecipientDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.neutral0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Add Recipient',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.neutral0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsList(RecipientsState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(8.w),
        itemCount: state.filteredRecipients.length,
        itemBuilder: (context, index) {
          final recipient = state.filteredRecipients[index];
          return _buildRecipientCard(recipient);
        },
      ),
    );
  }

  Widget _buildRecipientCard(Recipient recipient) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                recipient.name.substring(0, 2).toUpperCase(),
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.primary600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Recipient Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${recipient.bankName} - ${recipient.accountNumber}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          
          // Send Button
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to send money with pre-filled recipient
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.neutral0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              'Send',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.neutral0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecipientDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.neutral0,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => AddRecipientDialog(),
    );
  }
}

class AddRecipientDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddRecipientDialog> createState() => _AddRecipientDialogState();
}

class _AddRecipientDialogState extends ConsumerState<AddRecipientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Title
          Text(
            'Add Recipient',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24.h),
          
          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter recipient\'s full name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter recipient name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                
                _buildTextField(
                  controller: _bankNameController,
                  label: 'Bank Name',
                  hint: 'Enter bank name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bank name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                
                _buildTextField(
                  controller: _accountNumberController,
                  label: 'Account Number',
                  hint: 'Enter account number',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account number';
                    }
                    if (value.length < 10) {
                      return 'Account number must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email (Optional)',
                  hint: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 32.h),
                
                // Add Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _addRecipient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.neutral0,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Add Recipient',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.neutral0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary500),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  void _addRecipient() {
    if (_formKey.currentState!.validate()) {
      final recipient = Recipient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        email: _emailController.text.trim().isNotEmpty 
            ? _emailController.text.trim() 
            : null,
        createdAt: DateTime.now(),
      );
      
      ref.read(recipientsViewModelProvider.notifier).addRecipient(recipient);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipient added successfully',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral0,
            ),
          ),
          backgroundColor: AppColors.success500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }
}
