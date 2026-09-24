import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../domain/month_summary.dart';
import '../../state/overview_providers.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(monthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SpendWise',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthSummaryProvider);
          await ref.read(monthSummaryProvider.future);
        },
        child: summaryAsync.when(
          loading: () => const _OverviewLoading(),
          error: (error, stackTrace) => _OverviewError(
            onRetry: () {
              ref.invalidate(monthSummaryProvider);
            },
          ),
          data: (summary) {
            return _OverviewContent(month: month, summary: summary);
          },
        ),
      ),
    );
  }
}

class _OverviewContent extends ConsumerWidget {
  const _OverviewContent({required this.month, required this.summary});

  final DateTime month;
  final MonthSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = _categoryTotals(summary);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const Text(
          'Good afternoon',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Here is your spending overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),

        _MonthSelector(
          month: month,
          onPrevious: () {
            ref.read(selectedMonthProvider.notifier).previousMonth();
          },
          onNext: () {
            ref.read(selectedMonthProvider.notifier).nextMonth();
          },
        ),

        const SizedBox(height: 16),

        _TotalSpentCard(
          totalPaise: summary.totalPaise,
          transactionCount: summary.transactionCount,
        ),

        const SizedBox(height: 16),

        _SectionTitle(
          title: 'Spending by category',
          action: '${categories.length} categories',
        ),

        const SizedBox(height: 10),

        if (categories.isEmpty)
          const _EmptyCard(message: 'No spending recorded this month.')
        else
          ...categories.map(
            (entry) => _CategorySpendTile(
              categoryName: entry.name,
              amountPaise: entry.amountPaise,
              totalPaise: summary.totalPaise,
              color: Color(entry.colorValue),
            ),
          ),

        const SizedBox(height: 20),

        const _SectionTitle(title: 'Daily spending'),

        const SizedBox(height: 10),

        _DailySpendingCard(dailySpending: summary.byDay),

        const SizedBox(height: 20),

        const _SectionTitle(title: 'Monthly activity'),

        const SizedBox(height: 10),

        _ActivityCard(
          transactionCount: summary.transactionCount,
          activeDays: summary.byDay.length,
        ),

        const SizedBox(height: 20),

        _InsightCard(
          totalPaise: summary.totalPaise,
          transactionCount: summary.transactionCount,
        ),
      ],
    );
  }

  List<_CategoryTotal> _categoryTotals(MonthSummary summary) {
    final result = <_CategoryTotal>[];

    for (final entry in summary.byCategory.entries) {
      if (entry.value <= 0) {
        continue;
      }

      final category = MockData.categories.where(
        (item) => item.id == entry.key,
      );

      if (category.isEmpty) {
        continue;
      }

      result.add(
        _CategoryTotal(
          name: category.first.name,
          amountPaise: entry.value,
          colorValue: category.first.colorValue,
        ),
      );
    }

    result.sort((a, b) => b.amountPaise.compareTo(a.amountPaise));

    return result;
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                _monthName(month),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  String _monthName(DateTime date) {
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

class _TotalSpentCard extends StatelessWidget {
  const _TotalSpentCard({
    required this.totalPaise,
    required this.transactionCount,
  });

  final int totalPaise;
  final int transactionCount;

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
            'Total spending',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(totalPaise),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$transactionCount transactions this month',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int paise) {
    final rupees = paise.abs() ~/ 100;

    return '₹$rupees';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
      ],
    );
  }
}

class _CategorySpendTile extends StatelessWidget {
  const _CategorySpendTile({
    required this.categoryName,
    required this.amountPaise,
    required this.totalPaise,
    required this.color,
  });

  final String categoryName;
  final int amountPaise;
  final int totalPaise;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = totalPaise <= 0
        ? 0.0
        : (amountPaise / totalPaise).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _formatAmount(amountPaise),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: const Color(0xFFE8EEF7),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int paise) {
    return '₹${paise.abs() ~/ 100}';
  }
}

class _DailySpendingCard extends StatelessWidget {
  const _DailySpendingCard({required this.dailySpending});

  final List<DailySpend> dailySpending;

  @override
  Widget build(BuildContext context) {
    if (dailySpending.isEmpty) {
      return const _EmptyCard(message: 'No daily spending data available.');
    }

    final maxAmount = dailySpending
        .map((item) => item.amountPaise.abs())
        .fold<int>(0, (max, value) => value > max ? value : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: dailySpending.map((day) {
            final amount = day.amountPaise.abs();

            final ratio = maxAmount <= 0
                ? 0.0
                : (amount / maxAmount).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${day.date.day}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE8EEF7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '₹${amount ~/ 100}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.transactionCount,
    required this.activeDays,
  });

  final int transactionCount;
  final int activeDays;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: _ActivityValue(
                value: '$transactionCount',
                label: 'Transactions',
              ),
            ),
            Container(width: 1, height: 42, color: const Color(0xFFE4E7EC)),
            Expanded(
              child: _ActivityValue(value: '$activeDays', label: 'Active days'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityValue extends StatelessWidget {
  const _ActivityValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.totalPaise,
    required this.transactionCount,
  });

  final int totalPaise;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    final average = transactionCount == 0 ? 0 : totalPaise ~/ transactionCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights_rounded, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              transactionCount == 0
                  ? 'No spending activity yet this month.'
                  : 'Your average transaction is approximately ₹${average.abs() ~/ 100}.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 180),
        const Icon(Icons.cloud_off_rounded, size: 56, color: AppTheme.error),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Unable to load overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}

class _CategoryTotal {
  const _CategoryTotal({
    required this.name,
    required this.amountPaise,
    required this.colorValue,
  });

  final String name;
  final int amountPaise;
  final int colorValue;
}
