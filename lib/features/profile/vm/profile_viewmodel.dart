import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class ProfileState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final String? profileImageUrl;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.profileImageUrl,
  });

  // Computed properties for easy access
  String get userName {
    if (user == null) return 'Loading...';
    
    final firstName = user!.firstName.trim();
    final middleName = user!.middleName?.trim();
    final lastName = user!.lastName.trim();
    
    // Build name parts, only including non-empty parts
    final nameParts = <String>[];
    if (firstName.isNotEmpty) nameParts.add(firstName);
    if (middleName != null && middleName.isNotEmpty) nameParts.add(middleName);
    if (lastName.isNotEmpty) nameParts.add(lastName);
    
    final fullName = nameParts.join(' ');
    return fullName.isEmpty ? 'User' : fullName;
  }

  String get userEmail => user?.email ?? 'Loading...';
  String get userPhone => user?.phoneNumber ?? 'Not provided';
  String get tier {
    if (user?.level == null || user!.level!.isEmpty) return 'Tier 1';
    return user!.level!.replaceAll('level-', 'Tier ');
  }
  String get userStatus => user?.status ?? 'Unknown';

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    String? profileImageUrl,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel() : super(const ProfileState());

  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      AppLogger.info('Loading user profile from storage...');
      
      // Get user data from secure storage
      final userData = await localCache.getUser();
      
      if (userData.isNotEmpty) {
        // Parse user data to User model
        final user = User.fromJson(userData);
        AppLogger.info('User profile loaded successfully: ${user.firstName} ${user.lastName}');
        
        state = state.copyWith(
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        AppLogger.warning('No user data found in storage');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No user data found. Please login again.',
        );
      }
    } catch (e) {
      AppLogger.error('Error loading user profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile. Please try again.',
      );
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? phoneNumber,
  }) async {
    if (state.user == null) {
      AppLogger.warning('Cannot update profile: No user data available');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      AppLogger.info('Updating user profile...');
      
      // Create updated user object
      final updatedUser = User(
        userId: state.user!.userId,
        email: email ?? state.user!.email,
        password: state.user!.password, // Keep existing password
        userType: state.user!.userType,
        firstName: firstName ?? state.user!.firstName,
        lastName: lastName ?? state.user!.lastName,
        middleName: middleName ?? state.user!.middleName,
        gender: state.user!.gender,
        dateOfBirth: state.user!.dateOfBirth,
        country: state.user!.country,
        state: state.user!.state,
        city: state.user!.city,
        street: state.user!.street,
        postalCode: state.user!.postalCode,
        address: state.user!.address,
        phoneNumber: phoneNumber ?? state.user!.phoneNumber,
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

      // Save updated user to storage
      localCache.setUser = updatedUser.toJson();
      
      AppLogger.info('User profile updated successfully');
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile. Please try again.',
      );
    }
  }

  Future<void> uploadProfileImage(String imagePath) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to upload image
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        profileImageUrl: imagePath,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> upgradeTier() async {
    if (state.user == null) {
      AppLogger.warning('Cannot upgrade tier: No user data available');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      AppLogger.info('Upgrading user tier...');
      
      // Simulate API call to upgrade tier
      await Future.delayed(const Duration(seconds: 1));
      
      // Create updated user with new tier
      final currentLevel = state.user!.level ?? 'level-0';
      final newLevel = currentLevel == 'level-0' ? 'level-1' : 'level-2';
      
      final updatedUser = User(
        userId: state.user!.userId,
        email: state.user!.email,
        password: state.user!.password,
        userType: state.user!.userType,
        firstName: state.user!.firstName,
        lastName: state.user!.lastName,
        middleName: state.user!.middleName,
        gender: state.user!.gender,
        dateOfBirth: state.user!.dateOfBirth,
        country: state.user!.country,
        state: state.user!.state,
        city: state.user!.city,
        street: state.user!.street,
        postalCode: state.user!.postalCode,
        address: state.user!.address,
        phoneNumber: state.user!.phoneNumber,
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
        updatedAt: DateTime.now().toIso8601String(),
        token: state.user!.token,
        expires: state.user!.expires,
        level: newLevel,
        transactionPin: state.user!.transactionPin,
      );

      // Save updated user to storage
      localCache.setUser = updatedUser.toJson();
      
      AppLogger.info('User tier upgraded successfully to $newLevel');
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      AppLogger.error('Error upgrading tier: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upgrade tier. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      AppLogger.info('User logging out...');
      
      // Clear all user data from storage
      await localCache.clearAllUserData();
      
      // Reset profile state to initial state
      state = const ProfileState();
      
      // Navigate to login screen (hide back button)
      appRouter.pushNamedAndRemoveAllBehind('/loginView', arguments: false);
      
      AppLogger.info('User logged out successfully');
    } catch (e) {
      AppLogger.error('Error during logout: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error during logout. Please try again.',
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    
    try {
      AppLogger.info('Deleting user account...');
      
      // Simulate API call to delete account
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear all user data from storage
      await localCache.clearAllUserData();
      
      // Reset profile state to initial state
      state = const ProfileState();
      
      // Navigate to login screen (hide back button)
      appRouter.pushNamedAndRemoveAllBehind('/loginView', arguments: false);
      
      AppLogger.info('User account deleted successfully');
    } catch (e) {
      AppLogger.error('Error deleting account: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error deleting account. Please try again.',
      );
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to change password
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> enableTwoFactorAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to enable 2FA
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> disableTwoFactorAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to disable 2FA
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel();
});
