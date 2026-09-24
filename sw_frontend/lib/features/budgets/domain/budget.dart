class Budget {
  const Budget({
    required this.categoryId,
    required this.month,
    required this.limitPaise,
    required this.spentPaise,
  });

  final String categoryId;
  final DateTime month;
  final int limitPaise;
  final int spentPaise;

  int get remainingPaise => limitPaise - spentPaise;

  double get progress {
    if (limitPaise <= 0) {
      return 0;
    }

    final value = spentPaise / limitPaise;

    return value.clamp(0.0, 1.0);
  }

  bool get isOverBudget => spentPaise >= limitPaise && limitPaise > 0;

  bool get isApproachingLimit =>
      !isOverBudget && limitPaise > 0 && spentPaise >= limitPaise * 0.8;

  Budget copyWith({
    String? categoryId,
    DateTime? month,
    int? limitPaise,
    int? spentPaise,
  }) {
    return Budget(
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      limitPaise: limitPaise ?? this.limitPaise,
      spentPaise: spentPaise ?? this.spentPaise,
    );
  }
}
