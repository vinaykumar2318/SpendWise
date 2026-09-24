import 'package:flutter_test/flutter_test.dart';
import 'package:sw_frontend/features/budgets/data/mock_budget_repository.dart';
import 'package:sw_frontend/features/transactions/data/mock_transaction_repository.dart';

void main() {
  group('SpendWise data layer', () {
    test('transaction repository returns transactions', () async {
      final repository = MockTransactionRepository();

      final transactions = await repository.getTransactions();

      expect(transactions, isNotEmpty);
      expect(transactions.first.amountPaise, greaterThan(0));
    });

    test('budget repository returns budgets', () async {
      final repository = MockBudgetRepository();

      final now = DateTime.now().toUtc();

      final budgets = await repository.getBudgets(
        DateTime.utc(now.year, now.month, 1),
      );

      expect(budgets, isNotEmpty);
      expect(budgets.first.limitPaise, greaterThan(0));
    });

    test('budget calculates progress correctly', () async {
      final repository = MockBudgetRepository();

      final now = DateTime.now().toUtc();

      final budgets = await repository.getBudgets(
        DateTime.utc(now.year, now.month, 1),
      );

      expect(budgets.first.progress, greaterThanOrEqualTo(0));
      expect(budgets.first.progress, lessThanOrEqualTo(1));
    });
  });
}
