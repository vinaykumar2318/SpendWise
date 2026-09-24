import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../transactions/domain/category.dart';
import '../../domain/merchant.dart';
import '../../domain/merchant_rule.dart';
import '../../state/merchant_providers.dart';
import '../../../transactions/domain/transaction.dart';

class MerchantDetailScreen extends ConsumerWidget {
  const MerchantDetailScreen({super.key, required this.merchantId});

  final String merchantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantAsync = ref.watch(merchantByIdProvider(merchantId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Merchant',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: merchantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          onRetry: () {
            ref.invalidate(merchantByIdProvider(merchantId));
          },
        ),
        data: (merchant) {
          if (merchant == null) {
            return const _NotFoundState();
          }

          return _MerchantDetailContent(merchant: merchant);
        },
      ),
    );
  }
}

class _MerchantDetailContent extends ConsumerWidget {
  const _MerchantDetailContent({required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = _categoryFor(merchant.categoryId);

    final transactionsAsync = ref.watch(
      merchantTransactionsProvider(merchant.merchantKey),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _HeaderCard(merchant: merchant, category: category),

        const SizedBox(height: 16),

        _StatsCard(merchant: merchant),

        const SizedBox(height: 16),

        _CategoryCard(category: category),

        const SizedBox(height: 16),

        _RuleCard(merchant: merchant),

        const SizedBox(height: 16),

        _ActivityCard(transactionsAsync: transactionsAsync),
      ],
    );
  }

  Category? _categoryFor(String categoryId) {
    for (final category in MockData.categories) {
      if (category.id == categoryId) {
        return category;
      }
    }

    return null;
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.merchant, required this.category});

  final Merchant merchant;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            merchant.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            merchant.merchantKey,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 14),

          Text(
            category?.name ?? 'Other',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                icon: Icons.payments_outlined,
                label: 'Total',
                value: '₹${merchant.totalSpentPaise.abs() ~/ 100}',
              ),
            ),

            Expanded(
              child: _Stat(
                icon: Icons.receipt_long_outlined,
                label: 'Transactions',
                value: '${merchant.transactionCount}',
              ),
            ),

            Expanded(
              child: _Stat(
                icon: Icons.calculate_outlined,
                label: 'Average',
                value: '₹${merchant.averageSpendPaise.abs() ~/ 100}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 21),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category? category;

  @override
  Widget build(BuildContext context) {
    final color = category == null
        ? AppTheme.primaryBlue
        : Color(category!.colorValue);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.category_rounded, color: color),

            const SizedBox(width: 12),

            const Text(
              'Current category',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            const Spacer(),

            Text(
              category?.name ?? 'Other',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends ConsumerStatefulWidget {
  const _RuleCard({required this.merchant});

  final Merchant merchant;

  @override
  ConsumerState<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends ConsumerState<_RuleCard> {
  bool saving = false;

  Future<void> _changeCategory() async {
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choose category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: MockData.categories.map((category) {
                return ListTile(
                  leading: Icon(
                    Icons.category_outlined,
                    color: Color(category.colorValue),
                  ),
                  title: Text(category.name),
                  onTap: () {
                    Navigator.of(dialogContext).pop(category.id);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCategory == null) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final repository = ref.read(merchantRepositoryProvider);

      await repository.saveRule(
        MerchantRule(
          merchantKey: widget.merchant.merchantKey,
          categoryId: selectedCategory,
        ),
      );

      ref.invalidate(merchantRulesProvider);
      ref.invalidate(merchantByIdProvider(widget.merchant.id));
      ref.invalidate(merchantsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merchant category rule saved.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save merchant rule.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merchant rule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            const Text(
              'Choose a category to use for future '
              'transactions from this merchant.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: saving ? null : _changeCategory,
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.transactionsAsync});

  final AsyncValue<List<Transaction>> transactionsAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            transactionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => const Text(
                'Unable to load transaction activity.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Text(
                    'No transactions found for this merchant.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  );
                }

                return Column(
                  children: transactions.take(5).map((transaction) {
                    final amount = transaction.amountPaise.abs() ~/ 100;

                    final isRefund = transaction.amountPaise < 0;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.lightBlue,
                        child: Icon(
                          isRefund
                              ? Icons.undo_rounded
                              : Icons.receipt_long_rounded,
                          color: isRefund
                              ? AppTheme.success
                              : AppTheme.primaryBlue,
                        ),
                      ),
                      title: Text(
                        isRefund ? '+₹$amount' : '₹$amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isRefund
                              ? AppTheme.success
                              : AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(_formatDate(transaction.occurredAt)),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day}/${local.month}/${local.year}';
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Merchant not found',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
      child: ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }
}
