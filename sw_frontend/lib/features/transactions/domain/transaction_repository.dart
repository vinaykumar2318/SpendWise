import 'transaction.dart';

abstract interface class TransactionRepository {
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? query,
    int? minAmountPaise,
    int? maxAmountPaise,
  });

  Future<Transaction?> getTransactionById(String id);

  Future<Transaction> updateTransactionCategory({
    required String transactionId,
    required String categoryId,
    bool applyToMerchant = false,
  });
}
