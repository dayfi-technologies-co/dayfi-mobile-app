import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/common/data/nigeria_locations.dart';
import 'package:dayfi/core/theme/app_colors.dart';

/// Platform-specific location picker utility
/// 
/// This utility provides a consistent interface for showing location pickers
/// while using the native platform UI:
/// - iOS: CupertinoPicker in a bottom sheet
/// - Android: Material bottom sheet with searchable lists
class PlatformLocationPicker {
  /// Shows a platform-appropriate state picker
  static Future<String?> showStatePicker({
    required BuildContext context,
    String? selectedState,
    String? title,
  }) async {
    if (Platform.isIOS) {
      return _showIOSStatePicker(
        context: context,
        selectedState: selectedState,
        title: title,
      );
    } else {
      return _showAndroidStatePicker(
        context: context,
        selectedState: selectedState,
        title: title,
      );
    }
  }

  /// Shows a platform-appropriate city picker for a specific state
  static Future<String?> showCityPicker({
    required BuildContext context,
    required String state,
    String? selectedCity,
    String? title,
  }) async {
    if (Platform.isIOS) {
      return _showIOSCityPicker(
        context: context,
        state: state,
        selectedCity: selectedCity,
        title: title,
      );
    } else {
      return _showAndroidCityPicker(
        context: context,
        state: state,
        selectedCity: selectedCity,
        title: title,
      );
    }
  }

  /// Shows iOS-style state picker using CupertinoPicker
  static Future<String?> _showIOSStatePicker({
    required BuildContext context,
    String? selectedState,
    String? title,
  }) async {
    final states = NigeriaLocations.states;
    int selectedIndex = selectedState != null 
        ? states.indexOf(selectedState) 
        : 0;

    return material.showModalBottomSheet<String>(
      context: context,
      backgroundColor: material.Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: material.Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: material.Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Title
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    title,
                    style: material.Theme.of(context).textTheme.titleLarge?.copyWith(
                   fontFamily: 'CabinetGrotesk',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              // State picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40.h,
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: states.map((state) => 
                    Center(
                      child: Text(
                        state,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Karla',
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              
              // Action buttons
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: material.Colors.grey[600],
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).pop(states[selectedIndex]);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.purple500,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
      },
    );
  }

  /// Shows iOS-style city picker using CupertinoPicker
  static Future<String?> _showIOSCityPicker({
    required BuildContext context,
    required String state,
    String? selectedCity,
    String? title,
  }) async {
    final cities = NigeriaLocations.getCitiesForState(state);
    int selectedIndex = selectedCity != null 
        ? cities.indexOf(selectedCity) 
        : 0;

    return material.showModalBottomSheet<String>(
      context: context,
      backgroundColor: material.Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: material.Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: material.Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Title
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    title,
                    style: material.Theme.of(context).textTheme.titleLarge?.copyWith(
                   fontFamily: 'CabinetGrotesk',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              // City picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40.h,
                  onSelectedItemChanged: (int index) {
                    selectedIndex = index;
                  },
                  children: cities.map((city) => 
                    Center(
                      child: Text(
                        city,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Karla',
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              
              // Action buttons
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: material.Colors.grey[600],
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).pop(cities[selectedIndex]);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.purple500,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
      },
    );
  }

  /// Shows Android-style state picker using Material bottom sheet
  static Future<String?> _showAndroidStatePicker({
    required BuildContext context,
    String? selectedState,
    String? title,
  }) async {
    return material.showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: material.Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: material.Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: material.Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Title
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  title ?? 'Select State',
                  style: material.Theme.of(context).textTheme.titleLarge?.copyWith(
                 fontFamily: 'CabinetGrotesk',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Search field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: material.TextField(
                  decoration: material.InputDecoration(
                    hintText: 'Search states...',
                    prefixIcon: material.Icon(material.Icons.search),
                    border: material.OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (query) {
                    // This would trigger a rebuild with filtered results
                    // For now, we'll show all states
                  },
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // States list
              Expanded(
                child: ListView.builder(
                  itemCount: NigeriaLocations.states.length,
                  itemBuilder: (context, index) {
                    final state = NigeriaLocations.states[index];
                    final isSelected = state == selectedState;
                    
                    return material.ListTile(
                      title: Text(
                        state,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                              ? material.Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      trailing: isSelected 
                          ? material.Icon(
                              material.Icons.check,
                              color: material.Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(state),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows Android-style city picker using Material bottom sheet
  static Future<String?> _showAndroidCityPicker({
    required BuildContext context,
    required String state,
    String? selectedCity,
    String? title,
  }) async {
    final cities = NigeriaLocations.getCitiesForState(state);
    
    return material.showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: material.Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: material.Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: material.Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Title
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  title ?? 'Select City in $state',
                  style: material.Theme.of(context).textTheme.titleLarge?.copyWith(
                 fontFamily: 'CabinetGrotesk',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Search field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: material.TextField(
                  decoration: material.InputDecoration(
                    hintText: 'Search cities...',
                    prefixIcon: material.Icon(material.Icons.search),
                    border: material.OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (query) {
                    // This would trigger a rebuild with filtered results
                    // For now, we'll show all cities
                  },
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Cities list
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = city == selectedCity;
                    
                    return material.ListTile(
                      title: Text(
                        city,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                              ? material.Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      trailing: isSelected 
                          ? material.Icon(
                              material.Icons.check,
                              color: material.Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(city),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
