/// User-facing copy for DayFlow (powered by DayX).
class DayFlowCopy {
  DayFlowCopy._();

  static const featureName = 'DayFlow';
  static const poweredByDayX = 'Powered by DayX';
  static const tagline = 'Budget & automate your spending';
  static const homeSubtitle = 'Smartly budget & automate payments';

  static const safeToSpend = 'Safe to spend';
  static const freeAfterBudgetLabel = 'Free after budget';
  static const committedLabel = 'Committed';
  static const globalWalletLabel = 'Available balance';
  @Deprecated('Use globalWalletLabel')
  static const ngnWalletLabel = globalWalletLabel;
  static const globalWalletAvailableSuffix = 'available in your wallet';
  static const budgetSummaryTitle = 'After your budget';
  static const budgetNeedsSetupHint =
      'Some payments still need a recipient or bill details.';
  static const upcomingSection = 'Upcoming';
  static const pastSection = 'Past';
  static const tapToAddDetails = 'Tap to add details';
  static const addPaymentDetails = 'Add recipient or bill details';
  static const addDetailsBeforeApprove =
      'Add recipient or bill details for each scheduled payment before you approve.';
  static const missingRecipientOrBill =
      'Add a valid recipient (@username, bank, Opay) or bill account.';
  static const missingUsdAmount =
      'USD wallet amount must be greater than zero.';
  static const missingOtherCurrencyAmount =
      'Include the amount in the delivery currency (e.g. ₦) as well as USD.';
  static const missingScheduleTime =
      'Pick when this should run — date and time (e.g. tomorrow 9am).';
  static const createValidationFailed =
      'A few details are still missing. Finish them in chat before confirming.';
  static const savedRecipients = 'Saved recipients';
  static const createRecipientOnSpot = 'Create a new recipient';
  static const savePaymentDetails = 'Save details';
  static const scheduleDetailsTitle = 'Scheduled payment';
  static const linkScheduleToBudget = 'Link to budget';
  static const scheduleLinkedToBudget = 'Linked to your budget';
  static const statusPaid = 'Paid';
  static const statusFailed = 'Failed';
  static const statusOverdue = 'Overdue';
  static const statusScheduled = 'Scheduled';
  static const noAutomationsYet =
      'No automated items yet. Tap Add New Item to set something up.';
  static const newAutomationIntro =
      'Automate sends and bills on a schedule — DayFlow runs them for you.';
  static const automationUsdNote =
      'Amounts are debited from your USD wallet on each run.';
  static const sendAutomationDescription =
      'Automate repeat sends from your USD balance — pick recipient, amount, and when to run.';
  static const billAutomationDescription =
      'Automate repeat bill payments — provider, package, account, and schedule.';
  static const automatePaymentButton = 'Turn on autopay';
  static const automationCreated =
      'Autopay is on — your payment is scheduled.';
  static const totalBudget = 'Total budget';
  static const totalSpent = 'Total spent';
  static const availableBalance = 'Available balance';
  static const healthScore = 'DayFlow Score';
  static const aiInsights = 'AI Insights';
  static const yourCategories = 'Categories';
  static const yourGoals = 'Goals';
  static const forecast = 'Forecast';
  static const lockedPocket = 'Locked';
  static const incomePrompt = 'Would you like to create a plan for this money?';
  static const incomeDetectedTitle = 'New funds detected';
  static const planThisMoney = 'Plan funds';
  static const notNow = 'Not now';
  static const startAutomatedBudget = 'Create automated budget';
  static const addItemFromIncome = 'Add an item';
  static const allocationTitle = 'Split across categories';
  static const allocationSubtitle =
      'Move each slider when you\'re ready — nothing is pre-filled.';
  static const continueToPlan = 'Continue to plan';

  static String incomeWelcome(String formattedAmount) =>
      '$formattedAmount just landed in your global wallet. '
      'How would you like to plan these new funds? '
      'Add items one at a time, or create an automated budget — set it once and let it run smoothly.';

  static const budgetTypeMonthly = 'Monthly';

  static const introTitle = 'Budget & automate payments';
  static const introSubtitle =
      'Tell DayFlow what you need — allowance every week, rent split with roommates, bills on autopilot.';

  static const talkToDayX = 'Talk to DayX';
  static const createThisMonthBudget = "Create This Month's Budget";
  static const addNewItem = 'Add new item';
  static const editBudget = 'Edit Budget';
  static const editThisBudget = 'Edit This Budget';
  static const askAi = 'Ask AI';
  static const totalIncomeLabel = 'total income';
  static const editBudgetHint =
      'Scheduled payments show recipient or bill details. Tap a row to view or finish setup, '
      'or use Ask AI — "Reduce mom to 40k" or "Add gym at 15k every month".';
  static const spendingCategoriesSection = 'Spending categories';
  static const spendingPocketHint = 'Spending pocket · tap to adjust';
  static const automatedSpending = 'Automated spending';
  static const myFlows = 'Active budget';
  static const cancelFlow = 'Stop automation';
  static const cancelFlowConfirm =
      'Unused money will return to your wallet. Scheduled payments will stop.';
  static const startOver = 'Start over';
  static const startOverConfirm =
      'This stops all automations and clears your DayFlow plan. '
      'You can set up a fresh budget anytime.';
  static const startOverDone =
      'DayFlow cleared. Tap + or create a new budget when you\'re ready.';
  static const editPayment = 'Edit payment';
  static const flowActivated =
      'Your budget is live — recurring payments are scheduled.';
  static const flowCancelled =
      'Automation stopped. Refund sent to your wallet.';
  static const automateThisBudget = 'Automate This Budget';
  static const saveAsTemplate = 'Save as Template';
  static const templateSaved = 'Saved as your template for next month.';
  static const templateReuseOffer =
      'You have a saved budget template. Use it as a starting point for this month?';
  static const useSavedTemplate = 'Use saved template';
  static const approveAndActivate = automateThisBudget;
  static const editPlan = editBudget;
  static const createNewPlan = createThisMonthBudget;
  static const moveToDayEarn = 'Move to DayEarn';

  static const emptyTitle = 'No budget this month yet';
  static const emptyMessage =
      'Tell DayX how much you have and what you need to cover — mom, bills, data, subscriptions, and more.';

  static const budgetChatWelcome =
      'Hey there! 👋 Ready to plan your month? Tell me your income and what '
      'you need to cover — rent, family sends, bills, subscriptions — and '
      'we\'ll build a budget that fits.';

  /// Shown when user taps Add new item with no saved plan yet.
  static const addItemTaskOpener =
      'What would you like to add? Amount and schedule — '
      'e.g. "Send \$4 to Jane tomorrow" or "Gym \$15/month". '
      'I\'ll ask how they should receive it before we schedule.';

  static const editBudgetTaskOpener =
      'What would you like to change? '
      'You can say things like "Reduce gym to \$10" or "Add savings \$20".';

  static const addItemWithPlanOpener =
      'What should we add? Amount and schedule — '
      'e.g. "Netflix \$50 every Saturday" or "Send \$20 to mom every Friday". '
      'I\'ll walk you through recipient details in chat before we schedule.';

  static const editBudgetWithPlanOpener =
      'Tell me what to change — amounts, categories, or scheduled payments.';

  static const chatTaskDividerAddItem = 'Add new item';
  static const chatTaskDividerEditBudget = 'Edit budget';

  static const chatComposerHintAddItem = 'e.g. Send \$4 to Jane tomorrow';
  static const chatComposerHintEditBudget = 'Describe your change…';

  static const chatWelcome = budgetChatWelcome;

  static const quickPromptBudgetSalary = 'I have my salary this month';
  static const quickPromptRecurring = 'Automate sends to family';
  static const quickPromptThisMonth = 'Plan for this month';

  static const onTrackSummary = "You're on track this month";

  static const mainDescription =
      'Your monthly budget and scheduled payments in one place.';
  static const editBudgetDescription =
      'Scheduled payments show recipient or bill details. Tap a row to view or finish setup.';
}
