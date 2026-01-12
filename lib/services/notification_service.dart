// Conditional export: on web we export a stub (no-op) implementation; on other
// platforms we export the mobile implementation. Keep this file as a simple
// re-export so callers import `package:dayfi/services/notification_service.dart`.
export 'notification_service_mobile.dart'
  if (dart.library.html) 'notification_service_stub.dart';
