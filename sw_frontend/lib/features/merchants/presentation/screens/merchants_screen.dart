import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MerchantsScreen extends StatefulWidget {
  const MerchantsScreen({super.key});

  @override
  State<MerchantsScreen> createState() => _MerchantsScreenState();
}

class _MerchantsScreenState extends State<MerchantsScreen> {
  final List<Map<String, dynamic>> merchants = [
    {
      'id': 'Swiggy',
      'name': 'Swiggy',
      'category': 'Food & Dining',
      'transactions': 8,
      'spent': 3240,
    },
    {
      'id': 'Amazon',
      'name': 'Amazon',
      'category': 'Shopping',
      'transactions': 5,
      'spent': 4890,
    },
    {
      'id': 'Uber',
      'name': 'Uber',
      'category': 'Transport',
      'transactions': 6,
      'spent': 2180,
    },
    {
      'id': 'Netflix',
      'name': 'Netflix',
      'category': 'Entertainment',
      'transactions': 1,
      'spent': 649,
    },
    {
      'id': 'BigBasket',
      'name': 'BigBasket',
      'category': 'Groceries',
      'transactions': 4,
      'spent': 2860,
    },
    {
      'id': 'Airtel',
      'name': 'Airtel',
      'category': 'Bills',
      'transactions': 2,
      'spent': 1598,
    },
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {});
  }

  String _formatAmount(int amount) {
    return '₹${amount.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Merchants',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Merchant insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            Text(
              'See where you spend the most.',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            ...merchants.map(
              (merchant) => _MerchantCard(
                id: merchant['id'] as String,
                name: merchant['name'] as String,
                category: merchant['category'] as String,
                transactions: merchant['transactions'] as int,
                spent: merchant['spent'] as int,
                formattedAmount: _formatAmount(merchant['spent'] as int),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final int transactions;
  final int spent;
  final String formattedAmount;

  const _MerchantCard({
    required this.id,
    required this.name,
    required this.category,
    required this.transactions,
    required this.spent,
    required this.formattedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/merchants/$id');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFF1565C0),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '$transactions transactions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
