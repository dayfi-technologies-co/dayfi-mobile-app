import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/services/connectivity_service.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';

/// Wrapper widget that displays a persistent banner when internet connection is lost
///
/// This widget wraps the entire app and shows a Material Banner at the top
/// when there's no internet connection. The banner cannot be dismissed by the user
/// and only disappears when connection is restored.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  bool _showRestoredBanner = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();

    // Check initial connectivity
    final isConnected = await _connectivityService.checkConnectivity();
    setState(() {
      _isConnected = isConnected;
    });

    // Listen to connectivity changes
    _connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;

        // Show "Connection Restored" banner briefly
        if (isConnected) {
          _showRestoredBanner = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showRestoredBanner = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,

          // Show banner when offline
          if (!_isConnected)
            Positioned(top: 0, left: 0, right: 0, child: _buildOfflineBanner()),

          // Show "Connection Restored" banner briefly
          if (_showRestoredBanner && _isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildRestoredBanner(),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.error500, AppColors.error600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.error500.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No Internet Connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                     fontFamily: 'CabinetGrotesk',
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Please check your network settings',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Karla',
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoredBanner() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success500, AppColors.success600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success500.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(Icons.wifi_rounded, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Connection Restored',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                 fontFamily: 'CabinetGrotesk',
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/svgs/circle-check.svg',
                color: Colors.white,
                height: 24.sp,
                width: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
