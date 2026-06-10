/// User-facing copy for standalone budgets (no DayFlow).
abstract final class BudgetCopy {
  BudgetCopy._();

  static const newBudgetIntro =
      'Set a spending cap, auto-save to Daily Earn, or set a one-time reminder. '
      'For recurring send or bill autopay, use DayFlow.';

  static const automateInDayFlowNote =
      'Repeat sends and bill autopay live in DayFlow — not standalone budgets.';

  static const usdBalanceNote =
      'Amounts are in USD from your Dayfi balance.';

  static const managedInDayFlow = 'Managed in DayFlow';

  static const viewScheduledPayment = 'View scheduled payment';

  static const spendingCategories = [
    'Food & Dining',
    'Groceries',
    'Transport',
    'Bills',
    'Rent & Housing',
    'Shopping',
    'Entertainment',
    'Health & Wellness',
    'Education',
    'Subscriptions',
    'Personal Care',
    'Travel',
    'Gifts & Donations',
    'Pets',
    'Kids & Family',
    'Savings',
    'Flex Money',
  ];
}
