/// User-facing copy for standalone budgets (no DayFlow).
abstract final class BudgetCopy {
  BudgetCopy._();

  static const newBudgetIntro =
      'Set a spending cap, schedule repeat sends or bills, auto-save to Daily Earn, or set a one-time reminder.';

  static const usdBalanceNote =
      'Amounts are in USD from your Dayfi balance.';

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
