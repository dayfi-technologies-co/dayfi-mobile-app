import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/constants/analytics_events.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/flavors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Google Firebase Analytics Service Provider
FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver analyticsObserver = FirebaseAnalyticsObserver(
  analytics: _analytics,
);

class AnalyticsService {
  late Mixpanel _mixpanel;
  bool _isInitialized = false;
  String? _currentUserId;
  Map<String, dynamic> _deviceInfo = {};
  String? _networkType;

  ///get instance of FirebaseAnalytics [analytics]
  FirebaseAnalytics get analytics => _analytics;

  ///get instance of Mixpanel [mixpanel]
  Mixpanel get mixpanel => _mixpanel;

  AnalyticsService() {
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    try {
      // Initialize Mixpanel with project token based on flavor
      final mixpanelToken = _getMixpanelToken();
      AppLogger.debug('Initializing Mixpanel with token prefix: ${mixpanelToken.substring(0, 8)}');
      _mixpanel = await Mixpanel.init(mixpanelToken, trackAutomaticEvents: true);
      
      // Get device information
      await _getDeviceInfo();
      
      // Get network type
      await _getNetworkType();
      
      _isInitialized = true;
      AppLogger.info('Analytics initialized successfully');
    } catch (err) {
      AppLogger.error('Failed to initialize analytics: $err');
    }
  }

  String _getMixpanelToken() {
    switch (F.appFlavor) {
      case Flavor.dev:
        return 'b6ddb1b7694a492fd9911932510fef3a'; // Dev environment
      case Flavor.pilot:
        return 'b6ddb1b7694a492fd9911932510fef3a'; // Pilot environment
      case Flavor.prod:
        return 'b6ddb1b7694a492fd9911932510fef3a'; // Production environment - TODO: Use separate production token
    }
  }

  Future<void> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          AnalyticsProperties.platform: 'Android',
          AnalyticsProperties.deviceModel: androidInfo.model,
          AnalyticsProperties.osVersion: 'Android ${androidInfo.version.release}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          AnalyticsProperties.platform: 'iOS',
          AnalyticsProperties.deviceModel: iosInfo.model,
          AnalyticsProperties.osVersion: 'iOS ${iosInfo.systemVersion}',
        };
      }
    } catch (err) {
      AppLogger.error('Failed to get device info: $err');
    }
  }

  Future<void> _getNetworkType() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _networkType = connectivityResult.toString();
    } catch (err) {
      AppLogger.error('Failed to get network type: $err');
    }
  }

  Future<void> _setAnalyticUserData() async {
    if (!_isInitialized) return;
    
    try {
      final userData = await localCache.getUser();
      
      final user = User.fromJson(userData);
      _currentUserId = user.userId;
      
      // Firebase Analytics
      _analytics.setUserId(id: user.userId);
      _analytics.setUserProperty(
        name: "Name",
        value: '${user.lastName} ${user.firstName}',
      );
      _analytics.setUserProperty(name: "Email", value: user.email);
      _analytics.setUserProperty(name: "Mobile", value: user.phoneNumber ?? '');
      
      // Mixpanel
      _mixpanel.identify(user.userId);
      _mixpanel.getPeople().set(AnalyticsProperties.userEmail, user.email);
      _mixpanel.getPeople().set(AnalyticsProperties.userName, '${user.lastName} ${user.firstName}');
      _mixpanel.getPeople().set(AnalyticsProperties.userPhone, user.phoneNumber ?? '');
      
      // Set super properties for all events
      _mixpanel.registerSuperProperties({
        AnalyticsProperties.userId: user.userId,
        AnalyticsProperties.userEmail: user.email,
        AnalyticsProperties.appVersion: F.appVersion,
        ..._deviceInfo,
        if (_networkType != null) AnalyticsProperties.networkType: _networkType,
      });
      
    } catch (err) {
      AppLogger.error('Failed to set user data: $err');
    }
  }

  /// Log analytics event with name of the event [name] and event data [parameters]
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters = const {},
  }) async {
    if (!_isInitialized) {
      AppLogger.warning('Analytics not initialized, skipping event: $name');
      return;
    }
    
    try {
      final enrichedParameters = <String, Object>{
        ...?parameters,
        AnalyticsProperties.timestamp: DateTime.now().millisecondsSinceEpoch,
        AnalyticsProperties.appVersion: F.appVersion,
        ..._deviceInfo,
        if (_networkType != null) AnalyticsProperties.networkType: _networkType!,
      };

      // Add user data if available
      if (_currentUserId != null) {
        enrichedParameters[AnalyticsProperties.userId] = _currentUserId!;
      }

      AppLogger.debug('Sending event: $name');

      // Log to Firebase Analytics
      await _analytics.logEvent(name: name, parameters: enrichedParameters);
      
      // Log to Mixpanel
      _mixpanel.track(name, properties: enrichedParameters);
      
      // Force immediate sending
      _mixpanel.flush();
      AppLogger.info('Event sent successfully: $name');
      
    } catch (err) {
      AppLogger.error('Failed to log event $name: $err');
    }
  }

  /// Track screen view
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreen,
    Map<String, Object>? parameters,
  }) async {
    await logEvent(
      name: AnalyticsEvents.screenViewed,
      parameters: {
        AnalyticsProperties.screenName: screenName,
        if (previousScreen != null) AnalyticsProperties.previousScreen: previousScreen,
        ...?parameters,
      },
    );
  }

  /// Track user identification
  Future<void> identifyUser(String userId) async {
    if (!_isInitialized) return;
    
    try {
      _currentUserId = userId;
      _mixpanel.identify(userId);
      await _setAnalyticUserData();
    } catch (err) {
      AppLogger.error('Failed to identify user: $err');
    }
  }

  /// Track transaction events
  Future<void> trackTransaction({
    required String event,
    required String transactionId,
    double? amount,
    String? status,
    String? recipientName,
    String? paymentMethod,
    Map<String, Object>? additionalProperties,
  }) async {
    await logEvent(
      name: event,
      parameters: {
        AnalyticsProperties.transactionId: transactionId,
        if (amount != null) AnalyticsProperties.transactionAmount: amount,
        if (status != null) AnalyticsProperties.transactionStatus: status,
        if (recipientName != null) AnalyticsProperties.recipientName: recipientName,
        if (paymentMethod != null) AnalyticsProperties.paymentMethod: paymentMethod,
        AnalyticsProperties.transactionCurrency: 'NGN',
        ...?additionalProperties,
      },
    );
  }

  /// Track API calls
  Future<void> trackApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    int? responseTime,
    String? errorMessage,
  }) async {
    final event = statusCode >= 200 && statusCode < 300 
        ? AnalyticsEvents.apiCallCompleted 
        : AnalyticsEvents.apiCallFailed;
        
    await logEvent(
      name: event,
      parameters: {
        AnalyticsProperties.apiEndpoint: endpoint,
        AnalyticsProperties.apiMethod: method,
        AnalyticsProperties.apiStatusCode: statusCode,
        if (responseTime != null) AnalyticsProperties.apiResponseTime: responseTime,
        if (errorMessage != null) AnalyticsProperties.errorMessage: errorMessage,
      },
    );
  }

  /// Track errors
  Future<void> trackError({
    required String errorCode,
    required String errorMessage,
    String? stackTrace,
    Map<String, Object>? additionalProperties,
  }) async {
    await logEvent(
      name: AnalyticsEvents.errorOccurred,
      parameters: {
        AnalyticsProperties.errorCode: errorCode,
        AnalyticsProperties.errorMessage: errorMessage,
        if (stackTrace != null) AnalyticsProperties.errorStack: stackTrace,
        ...?additionalProperties,
      },
    );
  }

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized) return;
    
    try {
      for (final entry in properties.entries) {
        _mixpanel.getPeople().set(entry.key, entry.value);
      }
    } catch (err) {
      AppLogger.error('Failed to set user properties: $err');
    }
  }

  /// Reset user data (for logout)
  Future<void> resetUser() async {
    if (!_isInitialized) return;
    
    try {
      _currentUserId = null;
      _mixpanel.reset();
    } catch (err) {
      AppLogger.error('Failed to reset user: $err');
    }
  }
}
