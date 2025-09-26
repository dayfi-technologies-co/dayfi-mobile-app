import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';

class ProfileState {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String tier;
  final bool isLoading;
  final String? profileImageUrl;

  const ProfileState({
    this.userName = 'Kolawole Paul Oluwafemi',
    this.userEmail = 'kolawole.paul@email.com',
    this.userPhone = '+234 812 345 6789',
    this.tier = 'Tier 1',
    this.isLoading = false,
    this.profileImageUrl,
  });

  ProfileState copyWith({
    String? userName,
    String? userEmail,
    String? userPhone,
    String? tier,
    bool? isLoading,
    String? profileImageUrl,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel() : super(const ProfileState());

  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to load user profile
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would come from the API or local storage
      // For now, we'll use the default values from the initial state
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> updateProfile({
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to update profile
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        userName: userName ?? state.userName,
        userEmail: userEmail ?? state.userEmail,
        userPhone: userPhone ?? state.userPhone,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
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
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to upgrade tier
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        tier: 'Tier 2',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Clear user data from local storage
      await localCache.deleteToken();
      await localCache.removeFromLocalCache(StorageKeys.user);
      
      // Navigate to login screen (hide back button)
      appRouter.pushNamedAndRemoveAllBehind('/loginView', arguments: false);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simulate API call to delete account
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear all data and navigate to login (hide back button)
      await localCache.deleteToken();
      await localCache.removeFromLocalCache(StorageKeys.user);
      appRouter.pushNamedAndRemoveAllBehind('/loginView', arguments: false);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
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
