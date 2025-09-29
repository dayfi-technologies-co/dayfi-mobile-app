import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/auth/complete_personal_information/vm/complete_personal_information_viewmodel.dart';

class CompletePersonalInformationView extends ConsumerStatefulWidget {
  const CompletePersonalInformationView({super.key});

  @override
  ConsumerState<CompletePersonalInformationView> createState() =>
      _CompletePersonalInformationViewState();
}

class _CompletePersonalInformationViewState
    extends ConsumerState<CompletePersonalInformationView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text controllers
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _referralCodeController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _referralCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  void _updateControllers(CompletePersonalInfoState state) {
    if (_phoneNumberController.text != state.phoneNumber) {
      _phoneNumberController.text = state.phoneNumber;
    }
    if (_addressController.text != state.address) {
      _addressController.text = state.address;
    }
    if (_postalCodeController.text != state.postalCode) {
      _postalCodeController.text = state.postalCode;
    }
    if (_stateController.text != state.state) {
      _stateController.text = state.state;
    }
    if (_cityController.text != state.city) {
      _cityController.text = state.city;
    }
    if (_referralCodeController.text != state.referralCode) {
      _referralCodeController.text = state.referralCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalInfoState = ref.watch(completePersonalInfoProvider);
    final personalInfoNotifier = ref.read(
      completePersonalInfoProvider.notifier,
    );

    // Update controllers when state changes
    _updateControllers(personalInfoState);

    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  automaticallyImplyLeading: false, // Remove back button
                  title: Text(
                    "Complete Your Profile",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 28.00,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 4.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle
                        Text(
                          "Please provide your personal information to complete your account setup.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Karla',
                            letterSpacing: -.6,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 36.h),

                        // Date of Birth
                        _buildDateOfBirthField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // Country
                        _buildCountryField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // Phone Number
                        _buildPhoneNumberField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // Address
                        _buildAddressField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // Postal Code
                        _buildPostalCodeField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // State
                        _buildStateField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // City
                        _buildCityField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // Occupation
                        _buildOccupationField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 18.h),

                        // Referral Code (Optional)
                        _buildReferralCodeField(
                          personalInfoState,
                          personalInfoNotifier,
                        ),
                        SizedBox(height: 40.h),

                        // Submit Button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Complete Profile",
                          onPressed:
                              personalInfoState.isFormValid &&
                                      !personalInfoState.isBusy
                                  ? () => personalInfoNotifier
                                      .submitPersonalInfo(context)
                                  : null,
                          backgroundColor:
                              personalInfoState.isFormValid
                                  ? AppColors.purple500
                                  : AppColors.purple200,
                          height: 60.h,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          isLoading: personalInfoState.isBusy,
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Date of Birth",
          hintText: "Select your date of birth",
          controller: TextEditingController(
            text: _formatDateForDisplay(state.dateOfBirth),
          ),
          onChanged: notifier.setDateOfBirth,
          suffixIcon: Icon(
            Icons.calendar_today,
            color: AppColors.neutral400,
            size: 20.sp,
          ),
          shouldReadOnly: true,
          onTap: () => _showDatePicker(notifier),
        ),
        if (state.dateOfBirthError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.dateOfBirthError,
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

  Widget _buildCountryField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Country",
          hintText: "Select your country",
          controller: TextEditingController(text: state.country),
          onChanged: notifier.setCountry,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.neutral400,
            size: 20.sp,
          ),
          shouldReadOnly: true,
          onTap: () => _showCountryBottomSheet(notifier),
        ),
        if (state.countryError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.countryError,
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
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
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

  Widget _buildAddressField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Address",
          hintText: "Enter your address",
          controller: _addressController,
          onChanged: notifier.setAddress,
          suffixIcon: Icon(
            Icons.search,
            color: AppColors.neutral400,
            size: 20.sp,
          ),
        ),
        if (state.addressError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.addressError,
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

  Widget _buildPostalCodeField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Postal Code",
          hintText: "Enter your postal code",
          controller: _postalCodeController,
          onChanged: notifier.setPostalCode,
          keyboardType: TextInputType.text,
        ),
        if (state.postalCodeError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.postalCodeError,
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

  Widget _buildStateField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "State",
          hintText: "Enter your state",
          controller: _stateController,
          onChanged: notifier.setState,
          keyboardType: TextInputType.text,
        ),
        if (state.stateError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.stateError,
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

  Widget _buildCityField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "City",
          hintText: "Enter your city",
          controller: _cityController,
          onChanged: notifier.setCity,
          keyboardType: TextInputType.text,
        ),
        if (state.cityError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.cityError,
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

  Widget _buildOccupationField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Occupation",
          hintText: "Select your occupation",
          controller: TextEditingController(text: state.occupation),
          onChanged: notifier.setOccupation,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.neutral400,
            size: 20.sp,
          ),
          shouldReadOnly: true,
          onTap: () => _showOccupationBottomSheet(notifier),
        ),
        if (state.occupationError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.occupationError,
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

  Widget _buildReferralCodeField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Referral Code (Optional)",
          hintText: "Enter referral code if you have one",
          controller: _referralCodeController,
          onChanged: notifier.setReferralCode,
          keyboardType: TextInputType.text,
        ),
        if (state.referralCodeError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.referralCodeError,
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

  String _formatDateForDisplay(String isoDate) {
    if (isoDate.isEmpty) return '';

    try {
      final date = DateTime.parse(isoDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoDate; // Return as-is if parsing fails
    }
  }

  void _showDatePicker(CompletePersonalInfoNotifier notifier) async {
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
    }
  }

  void _showCountryBottomSheet(CompletePersonalInfoNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CountryBottomSheet(
            onCountrySelected: (country) {
              notifier.setCountry(country);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showOccupationBottomSheet(CompletePersonalInfoNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _OccupationBottomSheet(
            onOccupationSelected: (occupation) {
              notifier.setOccupation(occupation);
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

// Occupation Bottom Sheet
class _OccupationBottomSheet extends StatefulWidget {
  final Function(String) onOccupationSelected;

  const _OccupationBottomSheet({required this.onOccupationSelected});

  @override
  State<_OccupationBottomSheet> createState() => _OccupationBottomSheetState();
}

class _OccupationBottomSheetState extends State<_OccupationBottomSheet> {
  final List<String> _occupations = [
    'Marketing',
    'Manufacturing',
    'Media',
    'Healthcare',
    'Education',
    'Technology',
    'Finance',
    'Real Estate',
    'Retail',
    'Transportation',
    'Government',
    'Non-profit',
    'Consulting',
    'Legal',
    'Engineering',
    'Sales',
    'Customer Service',
    'Human Resources',
    'Other',
  ];

  List<String> _filteredOccupations = [];

  @override
  void initState() {
    super.initState();
    _filteredOccupations = _occupations;
  }

  void _filterOccupations(String query) {
    setState(() {
      _filteredOccupations =
          _occupations
              .where(
                (occupation) =>
                    occupation.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                  'Select Occupation',
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
              onChanged: _filterOccupations,
              decoration: InputDecoration(
                hintText: 'Search occupations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          // Occupations list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredOccupations.length,
              itemBuilder: (context, index) {
                final occupation = _filteredOccupations[index];
                return ListTile(
                  title: Text(occupation),
                  onTap: () => widget.onOccupationSelected(occupation),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
