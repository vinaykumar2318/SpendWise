import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../domain/merchant.dart';
import '../../state/merchant_providers.dart';

class MerchantsScreen extends ConsumerWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantsAsync = ref.watch(merchantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Merchants',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: merchantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return _ErrorState(
            onRetry: () {
              ref.invalidate(merchantsProvider);
            },
          );
        },
        data: (merchants) {
          if (merchants.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(merchantsProvider);
              await ref.read(merchantsProvider.future);
            },
            child: _MerchantContent(merchants: merchants),
          );
        },
      ),
    );
  }
}

class _MerchantContent extends StatelessWidget {
  const _MerchantContent({required this.merchants});

  final List<Merchant> merchants;

  @override
  Widget build(BuildContext context) {
    final totalSpent = merchants.fold<int>(
      0,
      (sum, merchant) => sum + merchant.totalSpentPaise,
    );

    final totalTransactions = merchants.fold<int>(
      0,
      (sum, merchant) => sum + merchant.transactionCount,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _SummaryCard(
          totalSpentPaise: totalSpent,
          transactionCount: totalTransactions,
          merchantCount: merchants.length,
        ),

        const SizedBox(height: 20),

        const Text(
          'Top merchants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        ...merchants.map(
          (merchant) => _MerchantCard(
            merchant: merchant,
            categoryName: _categoryName(merchant.categoryId),
            categoryColor: _categoryColor(merchant.categoryId),
            onTap: () {
              context.push('${AppRoutes.merchants}/${merchant.id}');
            },
          ),
        ),

        const SizedBox(height: 12),

        _InsightCard(merchants: merchants),
      ],
    );
  }

  String _categoryName(String categoryId) {
    for (final category in MockData.categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }

    return 'Other';
  }

  Color _categoryColor(String categoryId) {
    for (final category in MockData.categories) {
      if (category.id == categoryId) {
        return Color(category.colorValue);
      }
    }

    return AppTheme.primaryBlue;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalSpentPaise,
    required this.transactionCount,
    required this.merchantCount,
  });

  final int totalSpentPaise;
  final int transactionCount;
  final int merchantCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Merchant spending',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${totalSpentPaise.abs() ~/ 100}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  value: '$merchantCount',
                  label: 'Merchants',
                ),
              ),
              Expanded(
                child: _SummaryValue(
                  value: '$transactionCount',
                  label: 'Transactions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _MerchantCard extends StatelessWidget {
  const _MerchantCard({
    required this.merchant,
    required this.categoryName,
    required this.categoryColor,
    required this.onTap,
  });

  final Merchant merchant;
  final String categoryName;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForCategory(categoryName),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$categoryName • ${merchant.transactionCount} transactions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${merchant.totalSpentPaise.abs() ~/ 100}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills & Utilities':
        return Icons.receipt_long_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Groceries':
        return Icons.local_grocery_store_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.merchants});

  final List<Merchant> merchants;

  @override
  Widget build(BuildContext context) {
    if (merchants.isEmpty) {
      return const SizedBox.shrink();
    }

    final topMerchant = merchants.first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.insights_rounded, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${topMerchant.name} has the highest recorded spending at ₹${topMerchant.totalSpentPaise.abs() ~/ 100}.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No merchants found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Merchant insights will appear here once transactions are available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load merchants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
