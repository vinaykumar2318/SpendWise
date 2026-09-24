class MerchantRule {
  const MerchantRule({required this.merchantKey, required this.categoryId});

  final String merchantKey;
  final String categoryId;

  MerchantRule copyWith({String? merchantKey, String? categoryId}) {
    return MerchantRule(
      merchantKey: merchantKey ?? this.merchantKey,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
