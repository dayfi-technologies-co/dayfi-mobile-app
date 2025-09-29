import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

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
    if (value.trim().length < 10) {
      return 'Please enter a valid phone number';
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

  Future<void> updateProfile() async {
    if (!state.isFormValid || state.user == null) {
      AppLogger.warning('Cannot update profile: Form invalid or no user data');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      AppLogger.info('Updating user profile via API...');
      
      // Call the API to update profile
      final response = await _authService.updateProfile(
        country: state.country.isEmpty ? state.user!.country ?? '' : state.country,
        state: state.state.isEmpty ? state.user!.state ?? '' : state.state,
        street: state.user!.street ?? '',
        city: state.city.isEmpty ? state.user!.city ?? '' : state.city,
        postalCode: state.postalCode.isEmpty ? state.user!.postalCode ?? '' : state.postalCode,
        address: state.address.isEmpty ? state.user!.address ?? '' : state.address,
        gender: _normalizeGender(state.gender.isEmpty ? state.user!.gender ?? '' : state.gender),
        dob: state.dateOfBirth.isEmpty ? state.user!.dateOfBirth ?? '' : state.dateOfBirth,
        phoneNumber: state.phoneNumber,
        userId: state.user!.userId,
        bvn: state.user!.idNumber?.isNotEmpty == true ? state.user!.idNumber! : '00000000000', // Provide default BVN if empty
      );

      AppLogger.info('UpdateProfile API response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}');

      if (response.statusCode == 200 && !response.error) {
        AppLogger.info('Profile updated successfully via API');
        
        // Create updated user object with API response data
        final updatedUser = User(
          userId: state.user!.userId,
          email: state.email,
          password: state.user!.password, // Keep existing password
          userType: state.user!.userType,
          firstName: state.firstName,
          lastName: state.lastName,
          middleName: state.middleName.isEmpty ? null : state.middleName,
          gender: state.gender.isEmpty ? state.user!.gender : state.gender,
          dateOfBirth: state.dateOfBirth.isEmpty ? state.user!.dateOfBirth : state.dateOfBirth,
          country: state.country.isEmpty ? state.user!.country : state.country,
          state: state.state.isEmpty ? state.user!.state : state.state,
          city: state.city.isEmpty ? state.user!.city : state.city,
          street: state.user!.street,
          postalCode: state.postalCode.isEmpty ? state.user!.postalCode : state.postalCode,
          address: state.address.isEmpty ? state.user!.address : state.address,
          phoneNumber: state.phoneNumber,
          idType: state.user!.idType,
          idNumber: state.user!.idNumber,
          status: state.user!.status,
          refreshToken: state.user!.refreshToken,
          isDeleted: state.user!.isDeleted,
          verificationToken: state.user!.verificationToken,
          verificationTokenExpiryTime: state.user!.verificationTokenExpiryTime,
          passwordResetToken: state.user!.passwordResetToken,
          passwordResetTokenExpiryTime: state.user!.passwordResetTokenExpiryTime,
          verificationEmail: state.user!.verificationEmail,
          createdAt: state.user!.createdAt,
          updatedAt: DateTime.now().toIso8601String(), // Update timestamp
          token: state.user!.token,
          expires: state.user!.expires,
          level: state.user!.level,
          transactionPin: state.user!.transactionPin,
        );

        // Save updated user to local storage
        localCache.setUser = updatedUser.toJson();
        
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
          errorMessage: null,
          isDirty: false,
        );
      } else {
        AppLogger.error('Profile update failed: ${response.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message.isNotEmpty ? response.message : 'Failed to update profile. Please try again.',
        );
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile. Please try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final editProfileProvider = StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier();
});
