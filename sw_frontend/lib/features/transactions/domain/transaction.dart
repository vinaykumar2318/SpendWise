class Transaction {
  const Transaction({
    required this.id,
    required this.merchantRaw,
    required this.merchantName,
    required this.merchantKey,
    required this.categoryId,
    required this.amountPaise,
    required this.currency,
    required this.occurredAt,
    required this.mode,
  });

  final String id;
  final String merchantRaw;
  final String merchantName;
  final String merchantKey;
  final String categoryId;
  final int amountPaise;
  final String currency;
  final DateTime occurredAt;
  final String mode;

  bool get isRefund => amountPaise < 0;

  Transaction copyWith({
    String? id,
    String? merchantRaw,
    String? merchantName,
    String? merchantKey,
    String? categoryId,
    int? amountPaise,
    String? currency,
    DateTime? occurredAt,
    String? mode,
  }) {
    return Transaction(
      id: id ?? this.id,
      merchantRaw: merchantRaw ?? this.merchantRaw,
      merchantName: merchantName ?? this.merchantName,
      merchantKey: merchantKey ?? this.merchantKey,
      categoryId: categoryId ?? this.categoryId,
      amountPaise: amountPaise ?? this.amountPaise,
      currency: currency ?? this.currency,
      occurredAt: occurredAt ?? this.occurredAt,
      mode: mode ?? this.mode,
    );
  }
}
