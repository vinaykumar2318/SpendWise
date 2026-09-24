import '../../../core/utils/mock_data.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/merchant.dart';
import '../domain/merchant_rule.dart';
import '../domain/merchant_repository.dart';

class MockMerchantRepository implements MerchantRepository {
  @override
  Future<List<Merchant>> getMerchants() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return _buildMerchantsFromTransactions();
  }

  @override
  Future<Merchant?> getMerchantById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 75));

    final merchants = _buildMerchantsFromTransactions();

    for (final merchant in merchants) {
      if (merchant.id == id) {
        return merchant;
      }
    }

    return null;
  }

  @override
  Future<List<MerchantRule>> getRules() async {
    await Future<void>.delayed(const Duration(milliseconds: 75));

    return List<MerchantRule>.from(MockData.merchantRules);
  }

  @override
  Future<MerchantRule> saveRule(MerchantRule rule) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final index = MockData.merchantRules.indexWhere(
      (existing) => existing.merchantKey == rule.merchantKey,
    );

    if (index == -1) {
      MockData.merchantRules.add(rule);
    } else {
      MockData.merchantRules[index] = rule;
    }

    // Also update existing transactions for this merchant.
    //
    // This makes the merchant rule immediately visible
    // throughout the local mock application.
    for (var i = 0; i < MockData.transactions.length; i++) {
      final transaction = MockData.transactions[i];

      if (transaction.merchantKey == rule.merchantKey) {
        MockData.transactions[i] = transaction.copyWith(
          categoryId: rule.categoryId,
        );
      }
    }

    return rule;
  }

  List<Merchant> _buildMerchantsFromTransactions() {
    final merchants = <Merchant>[];

    for (final merchant in MockData.merchants) {
      final merchantTransactions = MockData.transactions
          .where(
            (transaction) => transaction.merchantKey == merchant.merchantKey,
          )
          .toList();

      if (merchantTransactions.isEmpty) {
        merchants.add(
          merchant.copyWith(transactionCount: 0, totalSpentPaise: 0),
        );

        continue;
      }

      final totalSpentPaise = merchantTransactions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.amountPaise,
      );

      final categoryId = _categoryForMerchant(
        merchant.merchantKey,
        merchantTransactions,
      );

      merchants.add(
        merchant.copyWith(
          categoryId: categoryId,
          transactionCount: merchantTransactions.length,
          totalSpentPaise: totalSpentPaise,
        ),
      );
    }

    merchants.sort((a, b) => b.totalSpentPaise.compareTo(a.totalSpentPaise));

    return merchants;
  }

  String _categoryForMerchant(
    String merchantKey,
    List<Transaction> transactions,
  ) {
    for (final rule in MockData.merchantRules) {
      if (rule.merchantKey == merchantKey) {
        return rule.categoryId;
      }
    }

    return transactions.first.categoryId;
  }
}
