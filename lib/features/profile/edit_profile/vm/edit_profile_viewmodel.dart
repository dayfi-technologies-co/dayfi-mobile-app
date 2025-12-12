import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/common/utils/connectivity_utils.dart';

class EditProfileState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isFormValid;
  final bool isDirty; // Track if form has changes

  // Form fields
  final String firstName;
  final String lastName;
  final String middleName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String country;
  final String address;
  final String postalCode;
  final String state;
  final String city;
  final String gender;

  // Field-specific errors
  final String firstNameError;
  final String lastNameError;
  final String emailError;
  final String phoneNumberError;

  const EditProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isFormValid = false,
    this.isDirty = false,
    this.firstName = '',
    this.lastName = '',
    this.middleName = '',
    this.email = '',
    this.phoneNumber = '',
    this.dateOfBirth = '',
    this.country = '',
    this.address = '',
    this.postalCode = '',
    this.state = '',
    this.city = '',
    this.gender = '',
    this.firstNameError = '',
    this.lastNameError = '',
    this.emailError = '',
    this.phoneNumberError = '',
  });

  EditProfileState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isFormValid,
    bool? isDirty,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? country,
    String? address,
    String? postalCode,
    String? state,
    String? city,
    String? gender,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? phoneNumberError,
  }) {
    return EditProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
      isDirty: isDirty ?? this.isDirty,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      emailError: emailError ?? this.emailError,
      phoneNumberError: phoneNumberError ?? this.phoneNumberError,
    );
  }
}

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final AuthService _authService;

  EditProfileNotifier({AuthService? authService})
    : _authService = authService ?? _getAuthService(),
      super(const EditProfileState()) {
    _loadUserData();
  }

  static AuthService _getAuthService() {
    try {
      return locator<AuthService>();
    } catch (e) {
      AppLogger.error('Failed to get AuthService from locator: $e');
      return AuthService(networkService: NetworkService());
    }
  }

  void _loadUserData() async {
    try {
      AppLogger.info('Loading user data for edit profile...');
      
      final userData = await localCache.getUser();
      
      if (userData.isNotEmpty) {
        final user = User.fromJson(userData);
        AppLogger.info('User data loaded successfully for editing');
        
        state = state.copyWith(
          user: user,
          firstName: user.firstName,
          lastName: user.lastName,
          middleName: user.middleName ?? '',
          email: user.email,
          phoneNumber: user.phoneNumber ?? '',
          dateOfBirth: user.dateOfBirth ?? '',
          country: user.country ?? '',
          address: user.address ?? '',
          postalCode: user.postalCode ?? '',
          state: user.state ?? '',
          city: user.city ?? '',
          gender: user.gender ?? '',
          isFormValid: _validateForm(
            user.firstName,
            user.lastName,
            user.email,
            user.phoneNumber ?? '',
          ),
        );
      } else {
        AppLogger.warning('No user data found for editing');
        state = state.copyWith(
          errorMessage: 'No user data found. Please login again.',
        );
      }
    } catch (e) {
      AppLogger.error('Error loading user data for editing: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load profile data. Please try again.',
      );
    }
  }

  // Force reload user data (useful when switching users)
  Future<void> reloadUserData() async {
    AppLogger.info('Force reloading user data for edit profile...');
    _loadUserData();
  }

  void setFirstName(String value) {
    final firstNameError = _validateName(value, 'First name');
    state = state.copyWith(
      firstName: value,
      firstNameError: firstNameError,
      isDirty: true,
      isFormValid: _validateForm(
        value,
        state.lastName,
        state.email,
        state.phoneNumber,
      ),
    );
  }

  void setLastName(String value) {
    final lastNameError = _validateName(value, 'Last name');
    state = state.copyWith(
      lastName: value,
      lastNameError: lastNameError,
      isDirty: true,
      isFormValid: _validateForm(
        state.firstName,
        value,
        state.email,
        state.phoneNumber,
      ),
    );
  }

  void setMiddleName(String value) {
    state = state.copyWith(
      middleName: value,
      isDirty: true,
    );
  }

  void setEmail(String value) {
    final emailError = _validateEmail(value);
    state = state.copyWith(
      email: value,
      emailError: emailError,
      isDirty: true,
      isFormValid: _validateForm(
        state.firstName,
        state.lastName,
        value,
        state.phoneNumber,
      ),
    );
  }

  void setPhoneNumber(String value) {
    final phoneNumberError = _validatePhoneNumber(value);
    state = state.copyWith(
      phoneNumber: value,
      phoneNumberError: phoneNumberError,
      isDirty: true,
      isFormValid: _validateForm(
        state.firstName,
        state.lastName,
        state.email,
        value,
      ),
    );
  }

  void setDateOfBirth(String value) {
    state = state.copyWith(
      dateOfBirth: value,
      isDirty: true,
    );
  }

  void setCountry(String value) {
    state = state.copyWith(
      country: value,
      isDirty: true,
    );
  }

  void setAddress(String value) {
    state = state.copyWith(
      address: value,
      isDirty: true,
    );
  }

  void setPostalCode(String value) {
    state = state.copyWith(
      postalCode: value,
      isDirty: true,
    );
  }

  void setState(String value) {
    state = state.copyWith(
      state: value,
      isDirty: true,
    );
  }

  void setCity(String value) {
    state = state.copyWith(
      city: value,
      isDirty: true,
    );
  }

  void setGender(String value) {
    state = state.copyWith(
      gender: value,
      isDirty: true,
    );
  }

  bool _validateForm(String firstName, String lastName, String email, String phoneNumber) {
    return firstName.trim().isNotEmpty &&
           lastName.trim().isNotEmpty &&
           email.trim().isNotEmpty &&
           _isValidEmail(email) &&
           phoneNumber.trim().isNotEmpty;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _validateName(String value, String fieldName) {
    if (value.isEmpty) return 'Please enter your $fieldName';
    if (value.trim().length < 2) {
      return 'Please enter a valid $fieldName';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
      return 'Please use only letters, spaces, hyphens, and apostrophes';
    }
    return '';
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email address';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return '';
  }

  String _validatePhoneNumber(String value) {
    if (value.isEmpty) return 'Please enter your phone number';
    
    final trimmed = value.trim();
    // If starts with 0, require 11 digits, otherwise require 10 digits
    if (trimmed.startsWith('0')) {
      if (trimmed.length != 11) return 'Please enter a valid 11-digit phone number';
    } else {
      if (trimmed.length != 10) return 'Please enter a valid 10-digit phone number';
    }
    
    return '';
  }

  String _normalizeGender(String gender) {
    if (gender.isEmpty) return '';
    
    final lowerGender = gender.toLowerCase();
    switch (lowerGender) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'other':
        return 'non-binary';
      case 'prefer not to say':
        return 'prefer-not-to-say';
      default:
        return lowerGender; // Return as-is if it doesn't match
    }
  }

  Future<void> updateProfile({Function()? onSuccess, Function(String)? onError}) async {
    if (!state.isFormValid || state.user == null) {
      AppLogger.warning('Cannot update profile: Form invalid or no user data');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      AppLogger.info('Updating user profile via API...');
      
      // Remove leading 0 from phone number if present
      final phoneNumber = state.phoneNumber.startsWith('0') 
          ? state.phoneNumber.substring(1) 
          : state.phoneNumber;
      
      // Call the API to update profile
      final response = await _authService.updateProfile(
        country: state.country.isNotEmpty ? state.country : (state.user!.country?.isNotEmpty == true ? state.user!.country! : 'Nigeria'),
        state: state.state.isNotEmpty ? state.state : (state.user!.state?.isNotEmpty == true ? state.user!.state! : 'Lagos'),
        street: state.user!.street?.isNotEmpty == true ? state.user!.street! : 'Not provided',
        city: state.city.isNotEmpty ? state.city : (state.user!.city?.isNotEmpty == true ? state.user!.city! : 'Lagos'),
        // postalCode: state.postalCode.isNotEmpty ? state.postalCode : (state.user!.postalCode?.isNotEmpty == true ? state.user!.postalCode! : '100001'),
        address: state.address.isNotEmpty ? state.address : (state.user!.address?.isNotEmpty == true ? state.user!.address! : 'Not provided'),
        gender: _normalizeGender(state.gender.isNotEmpty ? state.gender : (state.user!.gender?.isNotEmpty == true ? state.user!.gender! : 'male')),
        dob: state.dateOfBirth.isNotEmpty ? state.dateOfBirth : (state.user!.dateOfBirth?.isNotEmpty == true ? state.user!.dateOfBirth! : '1990-01-01'),
        phoneNumber: phoneNumber,
        userId: state.user!.userId,
        bvn: state.user!.idNumber?.isNotEmpty == true ? state.user!.idNumber! : '00000000000', // Provide default BVN if empty
      );

      AppLogger.info('UpdateProfile API response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}');

      if (response.statusCode == 200 && !response.error) {
        AppLogger.info('Profile updated successfully via API');
        
        // Create updated user object with API response data
        final updatedUser = User(
          userId: response.data?.user?.userId ?? state.user!.userId,
          email: response.data?.user?.email ?? state.email,
          password: state.user!.password, // Keep existing password
          userType: response.data?.user?.userType ?? state.user!.userType,
          firstName: response.data?.user?.firstName ?? state.firstName,
          lastName: response.data?.user?.lastName ?? state.lastName,
          middleName: response.data?.user?.middleName ?? (state.middleName.isEmpty ? null : state.middleName),
          gender: response.data?.user?.gender ?? state.gender,
          dateOfBirth: response.data?.user?.dateOfBirth ?? state.dateOfBirth,
          country: response.data?.user?.country ?? state.country,
          state: response.data?.user?.state ?? state.state,
          city: response.data?.user?.city ?? state.city,
          street: response.data?.user?.street ?? state.user!.street,
          postalCode: response.data?.user?.postalCode ?? state.postalCode,
          address: response.data?.user?.address ?? state.address,
          phoneNumber: response.data?.user?.phoneNumber ?? state.phoneNumber,
          idType: response.data?.user?.idType ?? state.user!.idType,
          idNumber: response.data?.user?.idNumber ?? state.user!.idNumber,
          status: response.data?.user?.status ?? state.user!.status,
          refreshToken: response.data?.user?.refreshToken ?? state.user!.refreshToken,
          isDeleted: response.data?.user?.isDeleted ?? state.user!.isDeleted,
          verificationToken: response.data?.user?.verificationToken ?? state.user!.verificationToken,
          verificationTokenExpiryTime: response.data?.user?.verificationTokenExpiryTime ?? state.user!.verificationTokenExpiryTime,
          passwordResetToken: response.data?.user?.passwordResetToken ?? state.user!.passwordResetToken,
          passwordResetTokenExpiryTime: response.data?.user?.passwordResetTokenExpiryTime ?? state.user!.passwordResetTokenExpiryTime,
          verificationEmail: response.data?.user?.verificationEmail ?? state.user!.verificationEmail,
          createdAt: response.data?.user?.createdAt ?? state.user!.createdAt,
          updatedAt: response.data?.user?.updatedAt ?? DateTime.now().toIso8601String(),
          token: state.user!.token, // Keep existing token
          expires: state.user!.expires, // Keep existing expires
          level: response.data?.user?.level ?? state.user!.level,
          transactionPin: response.data?.user?.transactionPin ?? state.user!.transactionPin,
          isIdVerified: response.data?.user?.isIdVerified ?? state.user!.isIdVerified,
          isBiometricsSetup: response.data?.user?.isBiometricsSetup ?? state.user!.isBiometricsSetup,
        );

        // Save updated user to local storage
        localCache.setUser = updatedUser.toJson();
        
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
          errorMessage: null,
          isDirty: false,
        );
        
        // Call success callback
        onSuccess?.call();
      } else {
        AppLogger.error('Profile update failed: ${response.message}');
        final errorMessage = response.message.isNotEmpty ? response.message : 'Failed to update profile. Please try again.';
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        );
        onError?.call(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      
      // Get user-friendly error message
      final errorMessage = await ConnectivityUtils.getErrorMessage(e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      onError?.call(errorMessage);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Reset form to initial state
  void resetForm() {
    state = const EditProfileState();
  }
}

final editProfileProvider = StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier();
});
