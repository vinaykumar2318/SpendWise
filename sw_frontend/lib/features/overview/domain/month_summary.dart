class MonthSummary {
  const MonthSummary({
    required this.month,
    required this.totalPaise,
    required this.byCategory,
    required this.byDay,
    required this.transactionCount,
  });

  final DateTime month;
  final int totalPaise;
  final Map<String, int> byCategory;
  final List<DailySpend> byDay;
  final int transactionCount;

  MonthSummary copyWith({
    DateTime? month,
    int? totalPaise,
    Map<String, int>? byCategory,
    List<DailySpend>? byDay,
    int? transactionCount,
  }) {
    return MonthSummary(
      month: month ?? this.month,
      totalPaise: totalPaise ?? this.totalPaise,
      byCategory: byCategory ?? this.byCategory,
      byDay: byDay ?? this.byDay,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}

class DailySpend {
  const DailySpend({required this.date, required this.amountPaise});

  final DateTime date;
  final int amountPaise;
}
