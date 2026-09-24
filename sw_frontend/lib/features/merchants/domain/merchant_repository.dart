import 'merchant.dart';
import 'merchant_rule.dart';

abstract interface class MerchantRepository {
  Future<List<Merchant>> getMerchants();

  Future<Merchant?> getMerchantById(String id);

  Future<List<MerchantRule>> getRules();

  Future<MerchantRule> saveRule(MerchantRule rule);
}
