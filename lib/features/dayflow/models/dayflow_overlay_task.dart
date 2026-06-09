/// How the DayBudget overlay was opened — controls task boundaries in one thread.
enum DayFlowOverlayTask {
  /// Resume prior chat (home, income prompt, generic open).
  general,

  /// Dashboard → Add New Item.
  addItem,

  /// Dashboard → Edit Budget (Ask AI path).
  editBudget,
}
