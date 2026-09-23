import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SpendWise',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // API refresh will be added later.
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildGreeting(context),

            const SizedBox(height: 24),

            _buildMonthSelector(context),

            const SizedBox(height: 20),

            _buildTotalSpentCard(context),

            const SizedBox(height: 20),

            _buildCategorySection(context),

            const SizedBox(height: 20),

            _buildDailySpendCard(context),

            const SizedBox(height: 20),

            _buildBudgetPreview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: const Color(0xFF667085)),
        ),
        const SizedBox(height: 4),
        Text(
          'Your financial overview',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
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

  Widget _buildTotalSpentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total spent',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '₹42,580',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.trending_down_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                '8.4% less than last month',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Top categories',
      child: Column(
        children: [
          _buildCategoryRow(
            icon: Icons.restaurant_rounded,
            name: 'Food & Dining',
            amount: '₹12,450',
            percentage: '29%',
          ),
          const Divider(height: 24),
          _buildCategoryRow(
            icon: Icons.shopping_bag_rounded,
            name: 'Shopping',
            amount: '₹8,720',
            percentage: '20%',
          ),
          const Divider(height: 24),
          _buildCategoryRow(
            icon: Icons.directions_car_rounded,
            name: 'Transport',
            amount: '₹6,340',
            percentage: '15%',
          ),
          const Divider(height: 24),
          _buildCategoryRow(
            icon: Icons.receipt_long_rounded,
            name: 'Bills',
            amount: '₹5,820',
            percentage: '14%',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required IconData icon,
    required String name,
    required String amount,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                percentage,
                style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDailySpendCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Daily spending',
      child: SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Daily spend chart',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chart will be connected later',
                style: TextStyle(color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetPreview(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Budget progress',
      child: Column(
        children: [
          _buildBudgetRow(
            category: 'Food & Dining',
            spent: '₹12,450',
            limit: '₹15,000',
            progress: 0.83,
          ),
          const SizedBox(height: 20),
          _buildBudgetRow(
            category: 'Shopping',
            spent: '₹8,720',
            limit: '₹12,000',
            progress: 0.73,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow({
    required String category,
    required String spent,
    required String limit,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$spent / $limit',
              style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
