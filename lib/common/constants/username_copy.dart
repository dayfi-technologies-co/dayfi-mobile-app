/// User-facing copy for Dayfi usernames (@handle).
/// Use these everywhere instead of "Dayfi Tag", "Dayfi ID", or mixed labels.
class UsernameCopy {
  UsernameCopy._();

  /// Short label for tabs, delivery methods, and filters.
  static const String label = 'Username';

  static const String your = 'Your username';
  static const String recipient = "Recipient's username";
  static const String create = 'Create your username';
  static const String createTitle = 'Create Your Username';
  static const String meetYour = 'Meet your username';
  static const String transfer = 'Username transfer';
  static const String via = 'Via username';
  static const String sendVia = 'Send via username';
  static const String details = 'Username details';
  static const String notFound = 'Username not found';
  static const String enterValid = 'Please enter a valid username';
  static const String copiedToClipboard = 'Username copied to clipboard';
  static const String copied = 'Username copied';
  static const String myUsername = 'My username';
  static const String validationError = 'Error validating username';
  static const String saveError = 'Could not save your username. Please try again.';
  static const String verifyError = 'Failed to verify username. Please try again.';
  static const String setInProfile = 'Set your username in profile';
  static const String setOrChange = 'Set or change your username';
  static const String allSet = 'Your username is all set';
  static const String shareInstant =
      'Share your username to receive money';
  static const String shareInstantNgn =
      'Share your username for instant transfers.';
  static const String sendInstantSubtitle = 'Send instantly using a username';
  static const String sendToInstant = 'Send to a username — instant';
  static const String addRecipientSubtitle =
      'Add a recipient via username to proceed with your transfer';
  static const String createExplanation =
      'Create a unique username — this is how others can find and pay you on Dayfi.';
  static const String successExplanation =
      'is your username. You can find it on your profile and copy it anytime.';
  static const String recipientOrAddress = 'Recipient address or username';
  static const String sendIntro =
      'Send via bank, mobile money, username, or crypto — many countries and currencies.';
  static const String recipientsIntro =
      'Saved recipients — bank, mobile money, username, and crypto.';

  static const String mustStartWithAt = 'Your username should start with @';
  static const String minLength = 'Your username needs at least 3 characters';
  static const String alreadyTaken =
      'This username is already taken. Try something different.';
  static const String available = 'Perfect! This username is available';
  static const String couldNotVerify =
      'Could not verify this username. Try again.';
  static const String createButton = 'Create username';

  static String belongsTo(String accountName) =>
      'This username belongs to $accountName';

  static String shareInvite(String username) =>
      'Send me money on DayFi! My username is $username\n\nDownload DayFi: https://dayfi.co';
}
