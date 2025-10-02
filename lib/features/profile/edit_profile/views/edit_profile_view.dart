import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/profile/edit_profile/vm/edit_profile_viewmodel.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text controllers
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
  }

  void _initializeControllers() {
    _dateOfBirthController = TextEditingController();
    _countryController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _genderController = TextEditingController();
  }

  void _initializeControllersWithData(EditProfileState state) {
    if (state.user != null) {
      _dateOfBirthController.text = _formatDateForDisplay(state.dateOfBirth);
      _countryController.text = state.country;
      _addressController.text = state.address;
      _postalCodeController.text = state.postalCode;
      _stateController.text = state.state;
      _cityController.text = state.city;
      _genderController.text = state.gender;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

    // Listen for successful updates and initialize controllers
    ref.listen<EditProfileState>(editProfileProvider, (previous, next) {
      // Initialize controllers when user data is first loaded
      if (previous?.user == null && next.user != null) {
        _initializeControllersWithData(next);
      }

      // Show error messages only
      if (next.errorMessage != null) {
        TopSnackbar.show(context, message: next.errorMessage!, isError: true);
        editProfileNotifier.clearError();
      }
    });

    return Scaffold(
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
            size: 20.sp,
          ),
        ),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 28.00,
            fontWeight: FontWeight.w500,
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
                  _buildMiddleNameField(editProfileState, editProfileNotifier),
                  SizedBox(height: 18.h),

                  // Email
                  _buildEmailField(editProfileState, editProfileNotifier),
                  SizedBox(height: 18.h),

                  // Phone Number
                  _buildPhoneNumberField(editProfileState, editProfileNotifier),
                  SizedBox(height: 18.h),

                  // Date of Birth
                  _buildDateOfBirthField(editProfileState, editProfileNotifier),
                  SizedBox(height: 18.h),

                  // Country
                  _buildCountryField(editProfileState, editProfileNotifier),
                  SizedBox(height: 18.h),

                  // Address
                  _buildAddressField(editProfileState, editProfileNotifier),
                  SizedBox(height: 18.h),

                  // Postal Code
                  _buildPostalCodeField(editProfileState, editProfileNotifier),
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
          controller: TextEditingController(text: state.firstName),
          onChanged: notifier.setFirstName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          // validator: (value) {
          //   if (value == null || value.trim().isEmpty) {
          //     return 'First name is required';
          //   }
          //   return null;
          // },
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
          controller: TextEditingController(text: state.lastName),
          onChanged: notifier.setLastName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Last name is required';
            }
            return null;
          },
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
      controller: TextEditingController(text: state.middleName),
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
          controller: TextEditingController(text: state.email),
          onChanged: notifier.setEmail,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
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
          controller: TextEditingController(text: state.phoneNumber),
          onChanged: notifier.setPhoneNumber,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (value.trim().length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
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
                  : AppColors.purple100,
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
      hintText: "Enter your state",
      controller: _stateController,
      onChanged: notifier.setState,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildCityField(EditProfileState state, EditProfileNotifier notifier) {
    return CustomTextField(
      label: "City",
      hintText: "Enter your city",
      controller: _cityController,
      onChanged: notifier.setCity,
      keyboardType: TextInputType.text,
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 7300), // ~20 years ago as default
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        const Duration(days: 6570), // Exactly 18 years ago
      ),
    );

    if (picked != null) {
      // Format date as ISO 8601 (YYYY-MM-DD) for API compatibility
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      notifier.setDateOfBirth(formattedDate);
      _dateOfBirthController.text = _formatDateForDisplay(formattedDate); // Update the controller text
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
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷'},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵'},
    {'name': 'South Korea', 'code': '+82', 'flag': '🇰🇷'},
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
  ];

  List<Map<String, String>> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = _countries;
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries =
          _countries
              .where(
                (country) => country['name']!.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Text(
                  'Select Country',
                  style: AppTypography.headlineSmall.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: TextField(
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          // Countries list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  leading: Text(
                    country['flag']!,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  title: Text(country['name']!),
                  subtitle: Text(country['code']!),
                  onTap: () => widget.onCountrySelected(country['name']!),
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
  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Text(
                  'Select Gender',
                  style: AppTypography.headlineSmall.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Genders list
          Expanded(
            child: ListView.builder(
              itemCount: _genders.length,
              itemBuilder: (context, index) {
                final gender = _genders[index];
                return ListTile(
                  title: Text(gender),
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
