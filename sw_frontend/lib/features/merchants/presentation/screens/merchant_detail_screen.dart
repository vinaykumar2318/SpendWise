import 'package:flutter/material.dart';

class MerchantDetailScreen extends StatefulWidget {
  final String merchantId;

  const MerchantDetailScreen({super.key, required this.merchantId});

  @override
  State<MerchantDetailScreen> createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  final List<Map<String, dynamic>> transactions = [
    {'date': 'Today', 'description': 'Food order', 'amount': 420},
    {'date': '18 Sep', 'description': 'Food order', 'amount': 560},
    {'date': '14 Sep', 'description': 'Food order', 'amount': 380},
    {'date': '10 Sep', 'description': 'Food order', 'amount': 740},
    {'date': '05 Sep', 'description': 'Food order', 'amount': 1140},
  ];

  int get totalSpent {
    return transactions.fold(
      0,
      (sum, transaction) => sum + (transaction['amount'] as int),
    );
  }

  double get averageTransaction {
    if (transactions.isEmpty) {
      return 0;
    }

    return totalSpent / transactions.length;
  }

  String _formatAmount(num amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Merchant Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Merchant header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 32,
                    color: Color(0xFF1565C0),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.merchantId,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Food & Dining',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total spent',
                  value: _formatAmount(totalSpent),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  title: 'Transactions',
                  value: transactions.length.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _StatCard(
            title: 'Average transaction',
            value: _formatAmount(averageTransaction),
          ),

          const SizedBox(height: 28),

          const Text(
            'Recent transactions',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          ...transactions.map(
            (transaction) => _TransactionTile(
              date: transaction['date'] as String,
              description: transaction['description'] as String,
              amount: transaction['amount'] as int,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String date;
  final String description;
  final int amount;

  const _TransactionTile({
    required this.date,
    required this.description,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(Icons.receipt_long_outlined, color: Color(0xFF1565C0)),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(date),
        trailing: Text(
          '₹$amount',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
