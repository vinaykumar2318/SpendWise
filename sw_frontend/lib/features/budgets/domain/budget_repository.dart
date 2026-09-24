import 'budget.dart';

abstract interface class BudgetRepository {
  Future<List<Budget>> getBudgets(DateTime month);

  Future<Budget> saveBudget(Budget budget);
}
