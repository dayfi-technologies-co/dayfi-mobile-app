/// User-facing copy for DayEarn.
class DayEarnCopy {
  DayEarnCopy._();

  static const featureName = 'DayEarn';
  static const createCta = 'Create DayEarn';
  static const addMoreCta = 'Add More';
  static const addToCta = 'Add to DayEarn';
  static const totalBalanceLabel = 'Total DayEarn Balance';
  static const withdrawCta = 'Withdraw';
  static const emptyTitle = 'No DayEarn pots yet';
  static const emptyMessage =
      'Create a named pot to earn daily interest. Withdraw anytime with no penalty.';
  static const accrualNote =
      'Interest starts tomorrow at midnight. Keep your money in for a full day to earn interest.';

  static const createDescription =
      'Name your pot and add a starting amount from your USD wallet to begin earning daily interest.';

  static String potCreated(String name) =>
      '$name is ready. Interest starts tomorrow at midnight.';
  static String withdrawSuccessful(String formattedAmount) =>
      'Withdrawal successful. $formattedAmount returned to your USD balance.';
  static String fundsAdded(String potName, String formattedAmount) =>
      '$formattedAmount added to $potName.';
  static const addMoreDescription =
      'Add funds from your USD wallet to grow this pot.';
  static const withdrawDescription =
      'Move funds back to your wallet instantly — no penalty.';
  static const withdrawAgreement =
      'I understand and agree with all the Terms & Conditions for withdrawing from DayEarn on dayfi.';
  static const amountRequired = 'Enter an amount';
  static const amountInvalid = 'Enter a valid amount';
  static const insufficientWalletBalance = 'Insufficient wallet balance';
  static const insufficientPotBalance = 'Amount exceeds available balance';
  static const agreementRequired =
      'Please agree to the terms to continue';
  static const mainDescription =
      'Named savings pots with daily interest. Withdraw anytime.';
}
