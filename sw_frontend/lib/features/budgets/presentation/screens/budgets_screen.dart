import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budgets',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showAddBudgetMessage(context);
            },
            tooltip: 'Add budget',
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _buildMonthHeader(context),
            const SizedBox(height: 20),
            _buildOverallBudgetCard(context),
            const SizedBox(height: 24),
            const Text(
              'Category budgets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 12),
            _buildBudgetCard(
              context,
              category: 'Food & Dining',
              icon: Icons.restaurant_rounded,
              spent: 12450,
              limit: 15000,
            ),
            const SizedBox(height: 12),
            _buildBudgetCard(
              context,
              category: 'Shopping',
              icon: Icons.shopping_bag_rounded,
              spent: 8720,
              limit: 12000,
            ),
            const SizedBox(height: 12),
            _buildBudgetCard(
              context,
              category: 'Transport',
              icon: Icons.directions_car_rounded,
              spent: 6340,
              limit: 6000,
            ),
            const SizedBox(height: 12),
            _buildBudgetCard(
              context,
              category: 'Entertainment',
              icon: Icons.movie_rounded,
              spent: 3200,
              limit: 5000,
            ),
            const SizedBox(height: 12),
            _buildBudgetCard(
              context,
              category: 'Groceries',
              icon: Icons.local_grocery_store_rounded,
              spent: 4100,
              limit: 7000,
            ),
            const SizedBox(height: 24),
            _buildAlertCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'September 2026',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallBudgetCard(BuildContext context) {
    const spent = 34810.0;
    const limit = 45000.0;
    const progress = spent / limit;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly spending',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹34,810',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ₹45,000',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '77% of your overall budget used',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context, {
    required String category,
    required IconData icon,
    required int spent,
    required int limit,
  }) {
    final progress = spent / limit;
    final percentage = progress * 100;

    final bool isOverBudget = percentage >= 100;
    final bool isAtRisk = percentage >= 80;

    final Color statusColor;

    if (isOverBudget) {
      statusColor = const Color(0xFFD92D20);
    } else if (isAtRisk) {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = const Color(0xFF16803C);
    }

    final String statusText;

    if (isOverBudget) {
      statusText = 'Over budget';
    } else if (isAtRisk) {
      statusText = 'Approaching limit';
    } else {
      statusText = 'On track';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.push('/budgets/${Uri.encodeComponent(category)}');
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: const Color(0xFF1565C0)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '₹${_formatAmount(spent)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFEAF0F6),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${_formatAmount(limit)} limit',
                  style: const TextStyle(color: Color(0xFF667085)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget alert',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Your Transport spending has exceeded its monthly budget.',
                  style: TextStyle(color: Color(0xFF475467), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Budget creation will be connected to the data layer later.',
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
