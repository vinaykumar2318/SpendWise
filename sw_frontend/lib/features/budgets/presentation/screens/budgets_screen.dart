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
            onPressed: () {},
            tooltip: 'Add budget',
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // API refresh will be implemented later.
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildMonthHeader(context),

            const SizedBox(height: 20),

            _buildOverallBudgetCard(context),

            const SizedBox(height: 24),

            Text(
              'Category budgets',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Center(
            child: Text(
              'September 2026',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  Widget _buildOverallBudgetCard(BuildContext context) {
    const spent = 34810;
    const limit = 45000;
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
        // Budget detail navigation will be added later.
        context.push(
          '/budgets/${Uri.encodeComponent(category)}',
        );
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
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFF1565C0)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF667085),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE4E7EC),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.round()}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  '₹${_formatAmount(spent)} spent',
                  style: const TextStyle(fontWeight: FontWeight.w600),
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

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
