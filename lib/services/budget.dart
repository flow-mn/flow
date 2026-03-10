class BudgetService {
  static BudgetService? _instance;

  factory BudgetService() => _instance ??= BudgetService._internal();

  BudgetService._internal() {
    // Constructor
  }
}
