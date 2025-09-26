import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/models/user_model.dart';

/// Google Firebase Analytics Service Provider
FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver analyticsObserver = FirebaseAnalyticsObserver(
  analytics: _analytics,
);

class AnalyticsService {
  ///get instance of FirebaseAnalytics [analytics]
  FirebaseAnalytics get analytics => _analytics;

  AnalyticsService() {
    try {
      _setAnalyticUserData();
    } catch (err) {
      AppLogger.error(err);
    }
  }

  void _setAnalyticUserData() async {
    User user = User.fromJson(await localCache.getUser());
    _analytics.setUserId(id: user.userId);
    _analytics.setUserProperty(
      name: "Name",
      value: '${user.lastName} ${user.firstName}',
    );
    _analytics.setUserProperty(name: "Email", value: user.email);
    _analytics.setUserProperty(name: "Mobile", value: user.phoneNumber ?? '');
  }

  ///Log analytics event with name of the event [name] and event data [parameters]
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters = const {},
  }) async {
    try {
      User user = User.fromJson(await localCache.getUser());
      parameters?.addAll({
        "email": user.email,
        "Name": '${user.lastName} ${user.firstName}',
      });
      _analytics.logEvent(name: name, parameters: parameters);
    } catch (err) {
      AppLogger.error(err);
    }
  }
}
