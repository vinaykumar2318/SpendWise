class Merchant {
  const Merchant({
    required this.id,
    required this.name,
    required this.merchantKey,
    required this.categoryId,
    required this.transactionCount,
    required this.totalSpentPaise,
  });

  final String id;
  final String name;
  final String merchantKey;
  final String categoryId;
  final int transactionCount;
  final int totalSpentPaise;

  int get averageSpendPaise {
    if (transactionCount <= 0) {
      return 0;
    }

    return totalSpentPaise ~/ transactionCount;
  }

  Merchant copyWith({
    String? id,
    String? name,
    String? merchantKey,
    String? categoryId,
    int? transactionCount,
    int? totalSpentPaise,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      merchantKey: merchantKey ?? this.merchantKey,
      categoryId: categoryId ?? this.categoryId,
      transactionCount: transactionCount ?? this.transactionCount,
      totalSpentPaise: totalSpentPaise ?? this.totalSpentPaise,
    );
  }
}
