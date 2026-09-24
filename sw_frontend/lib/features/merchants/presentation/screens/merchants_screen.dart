import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MerchantsScreen extends StatelessWidget {
  const MerchantsScreen({super.key});

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
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            const Text(
              'Top merchants',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 12),
            _buildMerchantCard(
              context,
              id: 'swiggy',
              merchant: 'Swiggy',
              category: 'Food & Dining',
              spent: '₹5,420',
              transactions: 12,
              icon: Icons.restaurant_rounded,
            ),
            const SizedBox(height: 12),
            _buildMerchantCard(
              context,
              id: 'amazon',
              merchant: 'Amazon',
              category: 'Shopping',
              spent: '₹4,890',
              transactions: 6,
              icon: Icons.shopping_bag_rounded,
            ),
            const SizedBox(height: 12),
            _buildMerchantCard(
              context,
              id: 'uber',
              merchant: 'Uber',
              category: 'Transport',
              spent: '₹3,280',
              transactions: 9,
              icon: Icons.directions_car_rounded,
            ),
            const SizedBox(height: 12),
            _buildMerchantCard(
              context,
              id: 'netflix',
              merchant: 'Netflix',
              category: 'Entertainment',
              spent: '₹1,947',
              transactions: 3,
              icon: Icons.movie_rounded,
            ),
            const SizedBox(height: 24),
            _buildInsightCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merchant spending',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  '₹15,537',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Across top merchants',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard(
    BuildContext context, {
    required String id,
    required String merchant,
    required String category,
    required String spent,
    required int transactions,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.push('/merchants/$id');
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFF1565C0), size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$transactions transactions',
                    style: const TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  spent,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF98A2B3),
                ),
              ],
            ),
          ],
        ),
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
          Icon(Icons.insights_rounded, color: Color(0xFF1565C0)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merchant insight',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Swiggy is currently your most frequent merchant this month.',
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
