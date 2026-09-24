import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_budget_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return MockBudgetRepository();
});

final budgetsProvider = FutureProvider.autoDispose
    .family<List<Budget>, DateTime>((ref, month) async {
      final repository = ref.watch(budgetRepositoryProvider);

      return repository.getBudgets(month);
    });
