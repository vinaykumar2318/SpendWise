import '../../../core/utils/mock_data.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/budget.dart';
import '../domain/budget_repository.dart';

class MockBudgetRepository implements BudgetRepository {
  @override
  Future<List<Budget>> getBudgets(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final monthStart = DateTime.utc(month.year, month.month, 1);

    final monthTransactions = MockData.transactions.where((transaction) {
      return transaction.occurredAt.year == month.year &&
          transaction.occurredAt.month == month.month &&
          !_isIncome(transaction);
    }).toList();

    final result = <Budget>[];

    for (final budget in MockData.budgets.where((budget) {
      return budget.month.year == month.year &&
          budget.month.month == month.month;
    })) {
      final spentPaise = _calculateSpent(monthTransactions, budget.categoryId);

      result.add(budget.copyWith(month: monthStart, spentPaise: spentPaise));
    }

    return result;
  }

  @override
  Future<Budget> saveBudget(Budget budget) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final monthStart = DateTime.utc(budget.month.year, budget.month.month, 1);

    final monthTransactions = MockData.transactions.where((transaction) {
      return transaction.occurredAt.year == budget.month.year &&
          transaction.occurredAt.month == budget.month.month &&
          !_isIncome(transaction);
    }).toList();

    final spentPaise = _calculateSpent(monthTransactions, budget.categoryId);

    final updatedBudget = budget.copyWith(
      month: monthStart,
      spentPaise: spentPaise,
    );

    final index = MockData.budgets.indexWhere(
      (existing) =>
          existing.categoryId == updatedBudget.categoryId &&
          existing.month.year == updatedBudget.month.year &&
          existing.month.month == updatedBudget.month.month,
    );

    if (index == -1) {
      MockData.budgets.add(updatedBudget);
    } else {
      MockData.budgets[index] = updatedBudget;
    }

    return updatedBudget;
  }

  int _calculateSpent(List<Transaction> transactions, String categoryId) {
    return transactions
        .where((transaction) => transaction.categoryId == categoryId)
        .fold<int>(0, (sum, transaction) => sum + transaction.amountPaise);
  }

  bool _isIncome(Transaction transaction) {
    return transaction.merchantKey == 'SALARY';
  }
}
