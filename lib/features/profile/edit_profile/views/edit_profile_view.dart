import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/profile/edit_profile/vm/edit_profile_viewmodel.dart';
import 'package:dayfi/common/utils/platform_date_picker.dart';
import 'package:dayfi/common/utils/platform_location_picker.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _genderController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Force reload user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editProfileProvider.notifier).reloadUserData();
    });
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _countryController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _genderController = TextEditingController();
  }

  void _updateControllersWithCurrentData(EditProfileState state) {
    if (state.user != null) {
      // Always update controller text with current state values
      _firstNameController.text = state.firstName;
      _lastNameController.text = state.lastName;
      _middleNameController.text = state.middleName;
      _phoneNumberController.text = state.phoneNumber;
      _emailController.text = state.email;
      _dateOfBirthController.text = _formatDateForDisplay(state.dateOfBirth);
      _countryController.text = state.country;
      _addressController.text = state.address;
      _postalCodeController.text = state.postalCode;
      _stateController.text = state.state;
      _cityController.text = state.city;
      _genderController.text = '';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  String _formatDateForDisplay(String isoDate) {
    if (isoDate.isEmpty) return '';

    try {
      final date = DateTime.parse(isoDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoDate; // Return as-is if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final editProfileState = ref.watch(editProfileProvider);
    final editProfileNotifier = ref.read(editProfileProvider.notifier);

    // Listen for state changes and update controllers
    ref.listen<EditProfileState>(editProfileProvider, (previous, next) {
      // Always update controllers with current data when user data is available
      if (next.user != null) {
        _updateControllersWithCurrentData(next);
      }

      // Show error messages only
      if (next.errorMessage != null) {
        TopSnackbar.show(context, message: next.errorMessage!, isError: true);
        editProfileNotifier.clearError();
      }
    });

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.neutral900,
              // size: 20.sp,
            ),
          ),
          title: Text(
            "Edit Profile",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Subtitle
                    Text(
                      "Update your personal information below.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Karla',
                        letterSpacing: -.6,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 36.h),

                    // First Name
                    _buildFirstNameField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // Last Name
                    _buildLastNameField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // Middle Name (Optional)
                    _buildMiddleNameField(
                      editProfileState,
                      editProfileNotifier,
                    ),
                    SizedBox(height: 18.h),

                    // Email
                    _buildEmailField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // Phone Number
                    _buildPhoneNumberField(
                      editProfileState,
                      editProfileNotifier,
                    ),
                    SizedBox(height: 18.h),

                    // Date of Birth
                    _buildDateOfBirthField(
                      editProfileState,
                      editProfileNotifier,
                    ),
                    SizedBox(height: 18.h),

                    // Country
                    _buildCountryField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // Address
                    _buildAddressField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // Postal Code
                    _buildPostalCodeField(
                      editProfileState,
                      editProfileNotifier,
                    ),
                    SizedBox(height: 18.h),

                    // State
                    _buildStateField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // City
                    _buildCityField(editProfileState, editProfileNotifier),
                    SizedBox(height: 18.h),

                    // Gender
                    _buildGenderField(editProfileState, editProfileNotifier),
                    SizedBox(height: 40.h),

                    // Action Buttons
                    _buildActionButtons(editProfileState, editProfileNotifier),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstNameField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "First Name",
          hintText: "Enter your first name",
          controller: _firstNameController,
          onChanged: notifier.setFirstName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          shouldReadOnly: true, // User cannot directly change first name
          enableInteractiveSelection:
              false, // Disable text selection and context menu
        ),

        if (state.firstNameError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.firstNameError,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'Karla',
                letterSpacing: -.6,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildLastNameField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Last Name",
          hintText: "Enter your last name",
          controller: _lastNameController,
          onChanged: notifier.setLastName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          shouldReadOnly: true, // User cannot directly change last name
          enableInteractiveSelection:
              false, // Disable text selection and context menu
        ),

        if (state.lastNameError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.lastNameError,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'Karla',
                letterSpacing: -.6,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildMiddleNameField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "Middle Name (Optional)",
      hintText: "Enter your middle name",
      controller: _middleNameController,
      onChanged: notifier.setMiddleName,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildEmailField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Email Address",
          hintText: "Enter your email address",
          controller: _emailController,
          onChanged: notifier.setEmail,
          keyboardType: TextInputType.emailAddress,
          shouldReadOnly: true, // User cannot change email address
          enableInteractiveSelection:
              false, // Disable text selection and context menu
        ),
        if (state.emailError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.emailError,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'Karla',
                letterSpacing: -.6,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildPhoneNumberField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Phone Number",
          hintText: "Enter your phone number",
          controller: _phoneNumberController,
          onChanged: notifier.setPhoneNumber,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          shouldReadOnly: true, // User cannot directly change phone number
          enableInteractiveSelection:
              false, // Disable text selection and context menu
        ),

        if (state.phoneNumberError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.phoneNumberError,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'Karla',
                letterSpacing: -.6,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildActionButtons(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return Column(
      children: [
        // Save Button
        PrimaryButton(
          borderRadius: 38,
          text: "Save Changes",
          onPressed:
              state.isFormValid && !state.isLoading && state.isDirty
                  ? () => _handleSave(notifier)
                  : null,
          backgroundColor:
              state.isFormValid && state.isDirty
                  ? AppColors.purple500
                  : AppColors.purple500.withOpacity(.25),
          height: 60.h,
          textColor: AppColors.neutral0,
          fontFamily: 'Karla',
          letterSpacing: -.8,
          fontSize: 18,
          width: double.infinity,
          fullWidth: true,
          isLoading: state.isLoading,
        ),
        SizedBox(height: 12.h),

        // Cancel Button
        SecondaryButton(
          text: "Cancel",
          onPressed: state.isLoading ? null : () => Navigator.pop(context),
          borderColor: AppColors.purple500,
          textColor: AppColors.purple500,
          width: double.infinity,
          fullWidth: true,
          height: 60.h,
          borderRadius: 38,
          fontFamily: 'Karla',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.8,
        ),
      ],
    );
  }

  Future<void> _handleSave(EditProfileNotifier notifier) async {
    if (_formKey.currentState?.validate() ?? false) {
      await notifier.updateProfile();
      // Navigate back after saving is complete
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildDateOfBirthField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "Date of Birth",
      hintText: "Select your date of birth",
      controller: _dateOfBirthController,
      onChanged: notifier.setDateOfBirth,
      suffixIcon: Icon(
        Icons.calendar_today,
        color: AppColors.neutral400,
        size: 20.sp,
      ),
      shouldReadOnly: true,
      onTap: () => _showDatePicker(notifier),
    );
  }

  Widget _buildCountryField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "Country",
      hintText: "Select your country",
      controller: _countryController,
      onChanged: notifier.setCountry,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.neutral400,
        size: 20.sp,
      ),
      shouldReadOnly: true,
      onTap: () => _showCountryBottomSheet(notifier),
    );
  }

  Widget _buildAddressField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "Address",
      hintText: "Enter your address",
      controller: _addressController,
      onChanged: notifier.setAddress,
      suffixIcon: Icon(Icons.search, color: AppColors.neutral400, size: 20.sp),
    );
  }

  Widget _buildPostalCodeField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "Postal Code",
      hintText: "Enter your postal code",
      controller: _postalCodeController,
      onChanged: notifier.setPostalCode,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildStateField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "State",
      hintText: "Select your state",
      controller: _stateController,
      onChanged: notifier.setState,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.neutral400,
        size: 20.sp,
      ),
      shouldReadOnly: true,
      onTap: () => _showStatePicker(notifier),
    );
  }

  Widget _buildCityField(EditProfileState state, EditProfileNotifier notifier) {
    return CustomTextField(
      label: "City",
      hintText:
          state.state.isNotEmpty ? "Select your city" : "Select state first",
      controller: _cityController,
      onChanged: notifier.setCity,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.neutral400,
        size: 20.sp,
      ),
      shouldReadOnly: true,
      onTap: state.state.isNotEmpty ? () => _showCityPicker(notifier) : null,
    );
  }

  Widget _buildGenderField(
    EditProfileState state,
    EditProfileNotifier notifier,
  ) {
    return CustomTextField(
      label: "Gender",
      hintText: "Select your gender",
      controller: _genderController,
      onChanged: notifier.setGender,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.neutral400,
        size: 20.sp,
      ),
      shouldReadOnly: true,
      onTap: () => _showGenderBottomSheet(notifier),
    );
  }

  void _showDatePicker(EditProfileNotifier notifier) async {
    final DateTime? picked = await PlatformDatePicker.showDateOfBirthPicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 7300), // ~20 years ago as default
      ),
      title: 'Select Date of Birth',
    );

    if (picked != null) {
      // Format date as ISO 8601 (YYYY-MM-DD) for API compatibility
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      notifier.setDateOfBirth(formattedDate);
      _dateOfBirthController.text = _formatDateForDisplay(
        formattedDate,
      ); // Update the controller text
    }
  }

  void _showCountryBottomSheet(EditProfileNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CountryBottomSheet(
            onCountrySelected: (country) {
              notifier.setCountry(country);
              _countryController.text = country; // Update the controller text
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showGenderBottomSheet(EditProfileNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _GenderBottomSheet(
            onGenderSelected: (gender) {
              notifier.setGender(gender);
              _genderController.text = gender; // Update the controller text
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showNameChangeRequestDialog(String fieldName, String currentValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Request $fieldName Change',
            style: AppTypography.titleMedium.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current $fieldName: $currentValue',
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'To change your $fieldName, you\'ll need to:',
                style: AppTypography.bodyMedium.copyWith(fontFamily: 'Karla'),
              ),
              SizedBox(height: 12.h),
              _buildRequirementItem('1. Upload a valid ID document'),
              _buildRequirementItem('2. Provide a reason for the change'),
              _buildRequirementItem('3. Wait for manual verification'),
              SizedBox(height: 16.h),
              Text(
                'This process may take 1-3 business days. Your account will be temporarily restricted during verification.',
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Karla',
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                  fontFamily: 'Karla',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showNameChangeForm(fieldName, currentValue);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Continue',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPhoneVerificationDialog(String currentPhone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verify Phone Number Change',
            style: AppTypography.titleMedium.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Phone: $currentPhone',
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'To change your phone number, you\'ll need to:',
                style: AppTypography.bodyMedium.copyWith(fontFamily: 'Karla'),
              ),
              SizedBox(height: 12.h),
              _buildRequirementItem('1. Enter your new phone number'),
              _buildRequirementItem('2. Verify via SMS code'),
              _buildRequirementItem('3. Confirm the change'),
              SizedBox(height: 16.h),
              Text(
                'A verification code will be sent to your new number.',
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Karla',
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                  fontFamily: 'Karla',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPhoneChangeForm(currentPhone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Continue',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.purple500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(fontFamily: 'Karla'),
            ),
          ),
        ],
      ),
    );
  }

  void _showNameChangeForm(String fieldName, String currentValue) {
    // TODO: Implement name change form with ID upload
    TopSnackbar.show(
      context,
      message: 'Name change form coming soon! Please contact support.',
      isError: false,
    );
  }

  void _showPhoneChangeForm(String currentPhone) {
    // TODO: Implement phone change form with SMS verification
    TopSnackbar.show(
      context,
      message: 'Phone verification form coming soon! Please contact support.',
      isError: false,
    );
  }

  void _showStatePicker(EditProfileNotifier notifier) async {
    final currentState = ref.read(editProfileProvider);
    final String? selectedState = await PlatformLocationPicker.showStatePicker(
      context: context,
      selectedState: currentState.state.isNotEmpty ? currentState.state : null,
      title: 'Select State',
    );

    if (selectedState != null) {
      notifier.setState(selectedState);
      _stateController.text = selectedState;
      // Clear city when state changes
      notifier.setCity('');
      _cityController.clear();
    }
  }

  void _showCityPicker(EditProfileNotifier notifier) async {
    final currentState = ref.read(editProfileProvider);
    if (currentState.state.isEmpty) return;

    final String? selectedCity = await PlatformLocationPicker.showCityPicker(
      context: context,
      state: currentState.state,
      selectedCity: currentState.city.isNotEmpty ? currentState.city : null,
      title: 'Select City in ${currentState.state}',
    );

    if (selectedCity != null) {
      notifier.setCity(selectedCity);
      _cityController.text = selectedCity;
    }
  }
}

// Country Bottom Sheet
class _CountryBottomSheet extends StatefulWidget {
  final Function(String) onCountrySelected;

  const _CountryBottomSheet({required this.onCountrySelected});

  @override
  State<_CountryBottomSheet> createState() => _CountryBottomSheetState();
}

class _CountryBottomSheetState extends State<_CountryBottomSheet> {
  final List<Map<String, String>> _countries = [
    {
      'name': 'Nigeria',
      'code': 'NG',
      'flag': 'assets/icons/svgs/world_flags/nigeria.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 22.h, width: 22.w),
                Text(
                  'Select Country',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/icons/pngs/cancelicon.png",
                    height: 22.h,
                    width: 22.w,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  onTap: () => widget.onCountrySelected(country['name']!),
                  title: Row(
                    children: [
                      SvgPicture.asset(country['flag']!, height: 24.000.h),
                      SizedBox(width: 12.w),
                      Text(
                        country['name']!,
                        style: AppTypography.bodyLarge.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    country['code']!,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Gender Bottom Sheet
class _GenderBottomSheet extends StatefulWidget {
  final Function(String) onGenderSelected;

  const _GenderBottomSheet({required this.onGenderSelected});

  @override
  State<_GenderBottomSheet> createState() => _GenderBottomSheetState();
}

class _GenderBottomSheetState extends State<_GenderBottomSheet> {
  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 22.h, width: 22.w),
                Text(
                  'Select Gender',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/icons/pngs/cancelicon.png",
                    height: 22.h,
                    width: 22.w,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: _genders.length,
              itemBuilder: (context, index) {
                final gender = _genders[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  title: Text(
                    gender,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => widget.onGenderSelected(gender),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
