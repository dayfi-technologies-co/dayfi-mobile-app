/// Bridges nav-orb press-and-hold release to the active [DayxVoiceOverlay].
class DayxVoiceHoldBridge {
  DayxVoiceHoldBridge._();

  static void Function()? onHoldReleased;

  static void notifyHoldReleased() {
    onHoldReleased?.call();
  }

  static void clear() {
    onHoldReleased = null;
  }
}
