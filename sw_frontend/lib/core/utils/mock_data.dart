import '../../features/budgets/domain/budget.dart';
import '../../features/merchants/domain/merchant.dart';
import '../../features/merchants/domain/merchant_rule.dart';
import '../../features/overview/domain/month_summary.dart';
import '../../features/transactions/domain/category.dart';
import '../../features/transactions/domain/transaction.dart';

class MockData {
  MockData._();

  static final List<Category> categories = [
    const Category(
      id: 'cat_food',
      name: 'Food & Dining',
      icon: 'fastfood',
      colorValue: 0xFFFF9800,
    ),
    const Category(
      id: 'cat_shopping',
      name: 'Shopping',
      icon: 'shopping_bag',
      colorValue: 0xFFE91E63,
    ),
    const Category(
      id: 'cat_bills',
      name: 'Bills & Utilities',
      icon: 'receipt_long',
      colorValue: 0xFF2196F3,
    ),
    const Category(
      id: 'cat_transport',
      name: 'Transport',
      icon: 'directions_car',
      colorValue: 0xFF9C27B0,
    ),
    const Category(
      id: 'cat_entertainment',
      name: 'Entertainment',
      icon: 'movie',
      colorValue: 0xFF4CAF50,
    ),
    const Category(
      id: 'cat_groceries',
      name: 'Groceries',
      icon: 'local_grocery_store',
      colorValue: 0xFF00897B,
    ),
  ];

  static final List<Transaction> transactions = [
    Transaction(
      id: 'tx_001',
      merchantRaw: 'SWIGGY*9482_BANGALORE',
      merchantName: 'Swiggy',
      merchantKey: 'SWIGGY',
      categoryId: 'cat_food',
      amountPaise: 54000,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 23, 12, 30),
      mode: 'UPI',
    ),
    Transaction(
      id: 'tx_002',
      merchantRaw: 'AMAZON*RETAIL_IND',
      merchantName: 'Amazon',
      merchantKey: 'AMAZON',
      categoryId: 'cat_shopping',
      amountPaise: 129900,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 23, 15, 15),
      mode: 'CARD',
    ),
    Transaction(
      id: 'tx_003',
      merchantRaw: 'UBER*TRIP_MUMBAI',
      merchantName: 'Uber',
      merchantKey: 'UBER',
      categoryId: 'cat_transport',
      amountPaise: 28000,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 23, 9, 15),
      mode: 'UPI',
    ),
    Transaction(
      id: 'tx_004',
      merchantRaw: 'NETFLIX.COM',
      merchantName: 'Netflix',
      merchantKey: 'NETFLIX',
      categoryId: 'cat_entertainment',
      amountPaise: 64900,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 22, 20, 10),
      mode: 'CARD',
    ),
    Transaction(
      id: 'tx_005',
      merchantRaw: 'SALARY_SEPTEMBER',
      merchantName: 'Salary',
      merchantKey: 'SALARY',
      categoryId: 'cat_bills',
      amountPaise: 7500000,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 22, 8, 30),
      mode: 'BANK_TRANSFER',
    ),
    Transaction(
      id: 'tx_006',
      merchantRaw: 'AIRTEL_POSTPAID',
      merchantName: 'Airtel',
      merchantKey: 'AIRTEL',
      categoryId: 'cat_bills',
      amountPaise: 79900,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 21, 10, 20),
      mode: 'UPI',
    ),
    Transaction(
      id: 'tx_007',
      merchantRaw: 'BIGBASKET_ORDER_1002',
      merchantName: 'BigBasket',
      merchantKey: 'BIGBASKET',
      categoryId: 'cat_groceries',
      amountPaise: 245000,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 21, 18, 40),
      mode: 'CARD',
    ),
    Transaction(
      id: 'tx_008',
      merchantRaw: 'SWIGGY_REFUND_TX9482',
      merchantName: 'Swiggy',
      merchantKey: 'SWIGGY',
      categoryId: 'cat_food',
      amountPaise: -15000,
      currency: 'INR',
      occurredAt: DateTime.utc(2026, 9, 21, 9, 15),
      mode: 'UPI',
    ),
  ];

  static final List<Budget> budgets = [
    Budget(
      categoryId: 'cat_food',
      month: DateTime.utc(2026, 9, 1),
      limitPaise: 1500000,
      spentPaise: 39000,
    ),
    Budget(
      categoryId: 'cat_transport',
      month: DateTime.utc(2026, 9, 1),
      limitPaise: 800000,
      spentPaise: 28000,
    ),
    Budget(
      categoryId: 'cat_shopping',
      month: DateTime.utc(2026, 9, 1),
      limitPaise: 1000000,
      spentPaise: 129900,
    ),
    Budget(
      categoryId: 'cat_entertainment',
      month: DateTime.utc(2026, 9, 1),
      limitPaise: 700000,
      spentPaise: 64900,
    ),
    Budget(
      categoryId: 'cat_groceries',
      month: DateTime.utc(2026, 9, 1),
      limitPaise: 1200000,
      spentPaise: 245000,
    ),
    Budget(
      categoryId: 'cat_bills',
      month: DateTime.utc(2026, 9, 1),
      limitPaise: 1000000,
      spentPaise: 79900,
    ),
  ];

  static final List<MerchantRule> merchantRules = [];

  static List<Merchant> get merchants {
    final merchantMap = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      merchantMap
          .putIfAbsent(transaction.merchantKey, () => [])
          .add(transaction);
    }

    final result = <Merchant>[];

    for (final entry in merchantMap.entries) {
      final merchantTransactions = entry.value;

      if (merchantTransactions.isEmpty) {
        continue;
      }

      final first = merchantTransactions.first;

      // Merchant spending uses signed amounts.
      // Therefore refunds reduce total spending.
      final total = merchantTransactions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.amountPaise,
      );

      result.add(
        Merchant(
          id: 'merchant_${entry.key.toLowerCase()}',
          name: first.merchantName,
          merchantKey: entry.key,
          categoryId: first.categoryId,
          transactionCount: merchantTransactions.length,
          totalSpentPaise: total,
        ),
      );
    }

    // Salary/income should not be treated as merchant spending.
    result.removeWhere((merchant) => merchant.merchantKey == 'SALARY');

    result.sort((a, b) => b.totalSpentPaise.compareTo(a.totalSpentPaise));

    return result;
  }

  static MonthSummary buildSummary(DateTime month) {
    final monthTransactions = transactions.where((transaction) {
      return transaction.occurredAt.year == month.year &&
          transaction.occurredAt.month == month.month &&
          !_isIncome(transaction);
    }).toList();

    final byCategory = <String, int>{};
    final byDay = <String, int>{};

    var totalPaise = 0;

    for (final transaction in monthTransactions) {
      // Signed amounts are intentional:
      // positive = expense
      // negative = refund
      totalPaise += transaction.amountPaise;

      byCategory[transaction.categoryId] =
          (byCategory[transaction.categoryId] ?? 0) + transaction.amountPaise;

      final dayKey = transaction.occurredAt.toUtc().toIso8601String().substring(
        0,
        10,
      );

      byDay[dayKey] = (byDay[dayKey] ?? 0) + transaction.amountPaise;
    }

    final daily = byDay.entries.map((entry) {
      return DailySpend(
        date: DateTime.parse('${entry.key}T00:00:00Z'),
        amountPaise: entry.value,
      );
    }).toList();

    daily.sort((a, b) => a.date.compareTo(b.date));

    return MonthSummary(
      month: DateTime.utc(month.year, month.month, 1),
      totalPaise: totalPaise,
      byCategory: Map.unmodifiable(byCategory),
      byDay: List.unmodifiable(daily),
      transactionCount: monthTransactions.length,
    );
  }

  static bool _isIncome(Transaction transaction) {
    return transaction.merchantKey == 'SALARY';
  }
}
