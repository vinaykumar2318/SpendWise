import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../domain/transaction.dart';
import '../../state/transaction_providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(transactionsProvider);
    await ref.read(transactionsProvider.future);
  }

  void _onSearchChanged(String value) {
    final query = value.trim();

    ref
        .read(transactionFilterProvider.notifier)
        .update(query: query.isEmpty ? null : query, clearQuery: query.isEmpty);
  }

  void _clearSearch() {
    _searchController.clear();

    ref.read(transactionFilterProvider.notifier).update(clearQuery: true);

    setState(() {});
  }

  Future<void> _openFilters() async {
    final result = await context.push<Map<String, dynamic>>(AppRoutes.filters);

    if (!mounted || result == null) {
      return;
    }

    ref
        .read(transactionFilterProvider.notifier)
        .setFilter(
          TransactionFilter(
            categoryId: result['categoryId'] as String?,
            startDate: result['startDate'] as DateTime?,
            endDate: result['endDate'] as DateTime?,
            query: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final filter = ref.watch(transactionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: filter.hasActiveFilters && filter.query == null,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                return _buildErrorState();
              },
              data: (transactions) {
                if (transactions.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildTransactionList(transactions),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search transactions',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final date = transaction.occurredAt.toLocal();

      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final transactionsForDay = grouped[key]!;

        final date = transactionsForDay.first.occurredAt.toLocal();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ...transactionsForDay.map(
              (transaction) => _TransactionTile(
                transaction: transaction,
                categoryName: _categoryName(transaction.categoryId),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'No transactions found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'Try changing your search or filters.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.cloud_off_rounded, size: 56, color: AppTheme.error),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Unable to load transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Pull down to try again.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ElevatedButton(
              onPressed: _refresh,
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.categoryName,
  });

  final Transaction transaction;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final isRefund = transaction.amountPaise < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('${AppRoutes.transactions}/${transaction.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForCategory(categoryName),
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$categoryName • ${transaction.mode}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatAmount(transaction.amountPaise),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isRefund ? AppTheme.success : AppTheme.textPrimary,
                ),
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
        return Icons.payments_rounded;
    }
  }

  String _formatAmount(int paise) {
    final rupees = paise.abs() ~/ 100;
    final sign = paise < 0 ? '+' : '-';

    return '$sign₹$rupees';
  }
}
