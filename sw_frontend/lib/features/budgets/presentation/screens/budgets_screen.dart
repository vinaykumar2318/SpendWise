import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../domain/budget.dart';
import '../../../transactions/domain/category.dart';
import '../../state/budget_providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = DateTime(DateTime.now().year, DateTime.now().month, 1);

    final budgetsAsync = ref.watch(budgetsProvider(month));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budgets',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Add budget',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Choose a category to create a budget.'),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return _ErrorState(
            onRetry: () {
              ref.invalidate(budgetsProvider(month));
            },
          );
        },
        data: (budgets) {
          if (budgets.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetsProvider(month));

              await ref.read(budgetsProvider(month).future);
            },
            child: _BudgetContent(month: month, budgets: budgets),
          );
        },
      ),
    );
  }
}

class _BudgetContent extends StatelessWidget {
  const _BudgetContent({required this.month, required this.budgets});

  final DateTime month;
  final List<Budget> budgets;

  @override
  Widget build(BuildContext context) {
    final totalLimit = budgets.fold<int>(
      0,
      (sum, budget) => sum + budget.limitPaise,
    );

    final totalSpent = budgets.fold<int>(
      0,
      (sum, budget) => sum + budget.spentPaise,
    );

    final overallProgress = totalLimit <= 0
        ? 0.0
        : (totalSpent / totalLimit).clamp(0.0, 1.0);

    final overBudgetCount = budgets
        .where((budget) => budget.isOverBudget)
        .length;

    final approachingCount = budgets
        .where((budget) => budget.isApproachingLimit)
        .length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _MonthHeader(month: month),

        const SizedBox(height: 16),

        _OverallBudgetCard(
          totalLimitPaise: totalLimit,
          totalSpentPaise: totalSpent,
          progress: overallProgress,
        ),

        const SizedBox(height: 16),

        if (overBudgetCount > 0)
          _AlertCard(
            icon: Icons.warning_amber_rounded,
            title: '$overBudgetCount budget exceeded',
            message:
                'Review your spending in the categories above their limits.',
            isError: true,
          )
        else if (approachingCount > 0)
          _AlertCard(
            icon: Icons.info_outline_rounded,
            title: '$approachingCount budgets approaching their limits',
            message: 'You are getting close to the monthly limit in some categories.',
            isError: false,
          ),

        if (overBudgetCount > 0 || approachingCount > 0)
          const SizedBox(height: 20),

        const Text(
          'Category budgets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        ...budgets.map((budget) {
          final category = _findCategory(budget.categoryId);

          return _BudgetCard(
            budget: budget,
            categoryName: category?.name ?? 'Other',
            categoryColor: category == null
                ? AppTheme.primaryBlue
                : Color(category.colorValue),
            onTap: () {
              // IMPORTANT:
              // The edit screen expects the category ID,
              // not the category name.
              context.push(
                '${AppRoutes.budgets}/${Uri.encodeComponent(budget.categoryId)}',
              );
            },
          );
        }),
      ],
    );
  }

  Category? _findCategory(String categoryId) {
    for (final category in MockData.categories) {
      if (category.id == categoryId) {
        return category;
      }
    }

    return null;
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget period',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              _formatMonth(month),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }

  String _formatMonth(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }
}

class _OverallBudgetCard extends StatelessWidget {
  const _OverallBudgetCard({
    required this.totalLimitPaise,
    required this.totalSpentPaise,
    required this.progress,
  });

  final int totalLimitPaise;
  final int totalSpentPaise;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remaining = totalLimitPaise - totalSpentPaise;

    final isOver = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly budget',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${totalSpentPaise.abs() ~/ 100}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'of ₹${totalLimitPaise ~/ 100}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8EEF7),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppTheme.error : AppTheme.primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            isOver
                ? '₹${remaining.abs() ~/ 100} over budget'
                : '₹${remaining ~/ 100} remaining',
            style: TextStyle(
              color: isOver ? AppTheme.error : AppTheme.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.categoryName,
    required this.categoryColor,
    required this.onTap,
  });

  final Budget budget;
  final String categoryName;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final statusColor = _statusColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
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
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${budget.spentPaise.abs() ~/ 100} of ₹${budget.limitPaise ~/ 100}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: budget.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8EEF7),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      budget.isOverBudget
                          ? '₹${budget.remainingPaise.abs() ~/ 100} over limit'
                          : '₹${budget.remainingPaise ~/ 100} remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

  String get _status {
    if (budget.isOverBudget) {
      return 'Over budget';
    }

    if (budget.isApproachingLimit) {
      return 'Approaching';
    }

    return 'On track';
  }

  Color get _statusColor {
    if (budget.isOverBudget) {
      return AppTheme.error;
    }

    if (budget.isApproachingLimit) {
      return AppTheme.warning;
    }

    return AppTheme.success;
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
        return Icons.account_balance_wallet_rounded;
    }
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.isError,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppTheme.error : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
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
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No budgets yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Create a budget to start tracking your spending.',
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
              'Unable to load budgets',
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
