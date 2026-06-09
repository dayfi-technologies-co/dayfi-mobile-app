import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/services/connectivity_service.dart';
import 'package:flutter/material.dart';

/// Wraps the app and surfaces connectivity changes via [TopSnackbar].
class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();

    final isConnected = await _connectivityService.checkConnectivity();
    if (!mounted) return;

    setState(() => _isConnected = isConnected);

    if (!isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        TopSnackbar.showSafe(
          context,
          message:
              'No internet connection. Please check your network settings.',
          isError: true,
        );
      });
    }

    _connectivityService.connectionStatus.listen(_onConnectionStatusChanged);
  }

  void _onConnectionStatusChanged(bool isConnected) {
    if (!mounted) return;

    if (isConnected && !_isConnected) {
      TopSnackbar.showSafe(
        context,
        message: 'Connection restored',
        isError: false,
      );
    } else if (!isConnected && _isConnected) {
      TopSnackbar.showSafe(
        context,
        message: 'Internet connection lost. Please check your network.',
        isError: true,
      );
    }

    setState(() => _isConnected = isConnected);
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
