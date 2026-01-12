import 'package:flutter/material.dart';

import 'package:dayfi/services/connectivity_service.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

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

    // Show TopSnackbar if no connection (after frame is built)
    if (!isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          TopSnackbar.show(
            context,
            message:
                'No internet connection. Please check your network settings.',
            isError: true,
          );
        }
      });
    }

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
        } else {
          // Show TopSnackbar when connection is lost
          TopSnackbar.show(
            context,
            message: 'Internet connection lost. Please check your network.',
            isError: true,
          );
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.error500),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Text(
              'No internet connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: -.4,
                fontWeight: FontWeight.w500,
                fontFamily: 'Chirp',
              ),
            ),
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.success500),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Text(
              'Connection restored',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: -.4,
                fontWeight: FontWeight.w500,
                fontFamily: 'Chirp',
              ),
            ),
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
