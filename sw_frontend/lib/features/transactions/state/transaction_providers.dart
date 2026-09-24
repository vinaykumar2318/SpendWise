import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_transaction_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return MockTransactionRepository();
});

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
      TransactionFilterNotifier.new,
    );

final transactionsProvider = FutureProvider.autoDispose<List<Transaction>>((
  ref,
) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterProvider);

  return repository.getTransactions(
    startDate: filter.startDate,
    endDate: filter.endDate,
    categoryId: filter.categoryId,
    query: filter.query,
    minAmountPaise: filter.minAmountPaise,
    maxAmountPaise: filter.maxAmountPaise,
  );
});

final transactionByIdProvider = FutureProvider.autoDispose
    .family<Transaction?, String>((ref, id) async {
      final repository = ref.watch(transactionRepositoryProvider);

      return repository.getTransactionById(id);
    });

class TransactionFilter {
  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.query,
    this.minAmountPaise,
    this.maxAmountPaise,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final String? query;
  final int? minAmountPaise;
  final int? maxAmountPaise;

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? query,
    int? minAmountPaise,
    int? maxAmountPaise,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategory = false,
    bool clearQuery = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return TransactionFilter(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      query: clearQuery ? null : (query ?? this.query),
      minAmountPaise: clearMinAmount
          ? null
          : (minAmountPaise ?? this.minAmountPaise),
      maxAmountPaise: clearMaxAmount
          ? null
          : (maxAmountPaise ?? this.maxAmountPaise),
    );
  }

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        categoryId != null ||
        minAmountPaise != null ||
        maxAmountPaise != null ||
        (query != null && query!.trim().isNotEmpty);
  }
}

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() {
    return const TransactionFilter();
  }

  void setFilter(TransactionFilter filter) {
    state = filter;
  }

  void update({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? query,
    int? minAmountPaise,
    int? maxAmountPaise,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategory = false,
    bool clearQuery = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      query: query,
      minAmountPaise: minAmountPaise,
      maxAmountPaise: maxAmountPaise,
      clearStartDate: clearStartDate,
      clearEndDate: clearEndDate,
      clearCategory: clearCategory,
      clearQuery: clearQuery,
      clearMinAmount: clearMinAmount,
      clearMaxAmount: clearMaxAmount,
    );
  }

  void clear() {
    state = const TransactionFilter();
  }
}
