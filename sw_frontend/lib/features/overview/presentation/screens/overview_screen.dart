import 'package:flutter/material.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _monthOffset = 0;

  DateTime get _selectedMonth {
    final now = DateTime(2026, 9);
    return DateTime(now.year, now.month + _monthOffset);
  }

  String get _monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  void _changeMonth(int offset) {
    setState(() {
      _monthOffset += offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SpendWise',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildGreeting(context),
            const SizedBox(height: 20),
            _buildMonthSelector(context),
            const SizedBox(height: 20),
            _buildTotalSpentCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Top categories'),
            const SizedBox(height: 12),
            _buildCategoryCard(
              icon: Icons.restaurant_rounded,
              category: 'Food & Dining',
              amount: '₹12,450',
              percentage: 0.36,
            ),
            const SizedBox(height: 10),
            _buildCategoryCard(
              icon: Icons.shopping_bag_rounded,
              category: 'Shopping',
              amount: '₹8,720',
              percentage: 0.25,
            ),
            const SizedBox(height: 10),
            _buildCategoryCard(
              icon: Icons.directions_car_rounded,
              category: 'Transport',
              amount: '₹6,340',
              percentage: 0.18,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Daily spending'),
            const SizedBox(height: 12),
            _buildSpendingChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Budget overview'),
            const SizedBox(height: 12),
            _buildBudgetOverview(),
            const SizedBox(height: 24),
            _buildInsightCard(),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Here is your spending overview.',
          style: TextStyle(color: Color(0xFF667085), fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
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
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
          ),
          Expanded(
            child: Center(
              child: Text(
                _monthName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSpentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total spent',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            '₹34,810',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_down_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                '8% less than last month',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: Color(0xFF172033),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String category,
    required String amount,
    required double percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEAF0F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSpendingChart() {
    const values = [0.35, 0.55, 0.42, 0.70, 0.48, 0.82, 0.60];

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < values.length; i++) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: values[i],
                        child: Container(
                          width: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    const spent = 34810.0;
    const limit = 45000.0;
    const progress = spent / limit;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF1565C0),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Monthly budget',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '77%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFEAF0F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1565C0),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '₹34,810 spent of ₹45,000',
            style: TextStyle(color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF1565C0)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending insight',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Food & Dining is your largest spending category this month.',
                  style: TextStyle(color: Color(0xFF475467), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
