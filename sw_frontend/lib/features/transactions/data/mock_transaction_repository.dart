import '../../../core/utils/mock_data.dart';
import '../../merchants/domain/merchant_rule.dart';
import '../domain/transaction.dart';
import '../domain/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  @override
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? query,
    int? minAmountPaise,
    int? maxAmountPaise,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final normalizedQuery = query?.trim().toLowerCase();

    final result = MockData.transactions.where((transaction) {
      if (startDate != null &&
          transaction.occurredAt.isBefore(startDate.toUtc())) {
        return false;
      }

      if (endDate != null && transaction.occurredAt.isAfter(endDate.toUtc())) {
        return false;
      }

      if (categoryId != null &&
          categoryId.isNotEmpty &&
          transaction.categoryId != categoryId) {
        return false;
      }

      if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
        final matchesMerchant = transaction.merchantName.toLowerCase().contains(
          normalizedQuery,
        );

        final matchesRaw = transaction.merchantRaw.toLowerCase().contains(
          normalizedQuery,
        );

        if (!matchesMerchant && !matchesRaw) {
          return false;
        }
      }

      final absoluteAmount = transaction.amountPaise.abs();

      if (minAmountPaise != null && absoluteAmount < minAmountPaise) {
        return false;
      }

      if (maxAmountPaise != null && absoluteAmount > maxAmountPaise) {
        return false;
      }

      return true;
    }).toList();

    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return result;
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 75));

    for (final transaction in MockData.transactions) {
      if (transaction.id == id) {
        return transaction;
      }
    }

    return null;
  }

  @override
  Future<Transaction> updateTransactionCategory({
    required String transactionId,
    required String categoryId,
    bool applyToMerchant = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final index = MockData.transactions.indexWhere(
      (transaction) => transaction.id == transactionId,
    );

    if (index == -1) {
      throw StateError('Transaction not found.');
    }

    final transaction = MockData.transactions[index];

    if (applyToMerchant) {
      final ruleIndex = MockData.merchantRules.indexWhere(
        (rule) => rule.merchantKey == transaction.merchantKey,
      );

      final rule = MerchantRule(
        merchantKey: transaction.merchantKey,
        categoryId: categoryId,
      );

      if (ruleIndex == -1) {
        MockData.merchantRules.add(rule);
      } else {
        MockData.merchantRules[ruleIndex] = rule;
      }

      for (var i = 0; i < MockData.transactions.length; i++) {
        final current = MockData.transactions[i];

        if (current.merchantKey == transaction.merchantKey) {
          MockData.transactions[i] = current.copyWith(categoryId: categoryId);
        }
      }
    } else {
      MockData.transactions[index] = transaction.copyWith(
        categoryId: categoryId,
      );
    }

    return MockData.transactions[index];
  }
}
