import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/domain/transaction.dart';
import '../../transactions/state/transaction_providers.dart';
import '../data/mock_merchant_repository.dart';
import '../domain/merchant.dart';
import '../domain/merchant_repository.dart';
import '../domain/merchant_rule.dart';

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MockMerchantRepository();
});

final merchantsProvider = FutureProvider.autoDispose<List<Merchant>>((
  ref,
) async {
  final repository = ref.watch(merchantRepositoryProvider);

  return repository.getMerchants();
});

final merchantByIdProvider = FutureProvider.autoDispose
    .family<Merchant?, String>((ref, merchantId) async {
      final repository = ref.watch(merchantRepositoryProvider);

      return repository.getMerchantById(merchantId);
    });

final merchantRulesProvider = FutureProvider.autoDispose<List<MerchantRule>>((
  ref,
) async {
  final repository = ref.watch(merchantRepositoryProvider);

  return repository.getRules();
});

final merchantTransactionsProvider = FutureProvider.autoDispose
    .family<List<Transaction>, String>((ref, merchantKey) async {
      final repository = ref.watch(transactionRepositoryProvider);

      final transactions = await repository.getTransactions();

      return transactions
          .where((transaction) => transaction.merchantKey == merchantKey)
          .toList();
    });
