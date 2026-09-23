import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Search transactions',
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () async {
            final result = await context.push('/filters');

            if (result != null) {
              // Actual transaction filtering will be implemented
              // later when we add the state/data layer.
            }
          },
            tooltip: 'Filter transactions',
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // API refresh will be implemented later.
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildMonthHeader(context),
            const SizedBox(height: 20),
            _buildDaySection(
              context,
              date: 'Today, 23 September',
              transactions: [
                _TransactionData(
                  id: 'txn_001',
                  merchant: 'Swiggy',
                  category: 'Food & Dining',
                  amount: '₹540',
                  icon: Icons.restaurant_rounded,
                  isCredit: false,
                ),
                _TransactionData(
                  id: 'txn_001',
                  merchant: 'Uber',
                  category: 'Transport',
                  amount: '₹280',
                  icon: Icons.directions_car_rounded,
                  isCredit: false,
                ),
                _TransactionData(
                  id: 'txn_003',
                  merchant: 'Amazon',
                  category: 'Shopping',
                  amount: '₹1,299',
                  icon: Icons.shopping_bag_rounded,
                  isCredit: false,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDaySection(
              context,
              date: 'Yesterday, 22 September',
              transactions: [
                _TransactionData(
                  id: 'txn_004',
                  merchant: 'Netflix',
                  category: 'Entertainment',
                  amount: '₹649',
                  icon: Icons.movie_rounded,
                  isCredit: false,
                ),
                _TransactionData(
                  id: 'txn_005',
                  merchant: 'Salary',
                  category: 'Income',
                  amount: '₹75,000',
                  icon: Icons.account_balance_wallet_rounded,
                  isCredit: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDaySection(
              context,
              date: '21 September',
              transactions: [
                _TransactionData(
                  id: 'txn_006',
                  merchant: 'Airtel',
                  category: 'Bills',
                  amount: '₹799',
                  icon: Icons.receipt_long_rounded,
                  isCredit: false,
                ),
                _TransactionData(
                  id: 'txn_007',
                  merchant: 'BigBasket',
                  category: 'Groceries',
                  amount: '₹2,450',
                  icon: Icons.local_grocery_store_rounded,
                  isCredit: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'September 2026',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  '12 transactions shown',
                  style: TextStyle(color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Change month',
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context, {
    required String date,
    required List<_TransactionData> transactions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475467),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                _buildTransactionTile(context, transactions[i]),
                if (i != transactions.length - 1)
                  const Divider(height: 1, indent: 76),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    _TransactionData transaction,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // Transaction detail navigation will be added later.
        context.push('/transactions/${transaction.id}');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(transaction.icon, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction.isCredit
                  ? '+${transaction.amount}'
                  : '-${transaction.amount}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: transaction.isCredit
                    ? const Color(0xFF16803C)
                    : const Color(0xFF172033),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.icon,
    required this.isCredit,
  });

  final String id;
  final String merchant;
  final String category;
  final String amount;
  final IconData icon;
  final bool isCredit;
}
