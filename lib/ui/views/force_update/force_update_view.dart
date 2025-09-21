import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/services/app_update_service.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';

class ForceUpdateView extends StatelessWidget {
  final AppUpdateStatus updateStatus;
  
  const ForceUpdateView({
    super.key,
    required this.updateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xff5645F5),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  Icons.update,
                  color: Colors.white,
                  size: 60.w,
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Title
              Text(
                'Update Required',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1A1A1A),
                  fontFamily: 'Karla',
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              // Description
              Text(
                'A new version of DayFi is available and required to continue using the app. Please update to the latest version to access all features and security improvements.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xff666666),
                  fontFamily: 'Karla',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32.h),
              
              // Version Info
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xffE5E5E5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildVersionRow(
                      'Current Version',
                      updateStatus.currentVersion,
                      const Color(0xff666666),
                    ),
                    SizedBox(height: 8.h),
                    _buildVersionRow(
                      'Latest Version',
                      _getLatestVersion(),
                      const Color(0xff5645F5),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () => _handleUpdate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5645F5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Update Now',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Karla',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Additional Info
              Text(
                'The update will be downloaded from your device\'s app store.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xff999999),
                  fontFamily: 'Karla',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVersionRow(String label, String version, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xff666666),
            fontFamily: 'Karla',
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'Karla',
            ),
          ),
        ),
      ],
    );
  }
  
  String _getLatestVersion() {
    if (updateStatus is ForceUpdateRequired) {
      return (updateStatus as ForceUpdateRequired).latestVersion;
    } else if (updateStatus is OptionalUpdateAvailable) {
      return (updateStatus as OptionalUpdateAvailable).latestVersion;
    }
    return updateStatus.currentVersion;
  }
  
  Future<void> _handleUpdate(BuildContext context) async {
    try {
      final appUpdateService = AppUpdateService();
      await appUpdateService.openAppStore();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open app store: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

