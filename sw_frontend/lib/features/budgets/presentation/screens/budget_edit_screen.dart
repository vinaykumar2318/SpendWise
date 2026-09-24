import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../transactions/domain/category.dart';
import '../../domain/budget.dart';
import '../../state/budget_providers.dart';

class BudgetEditScreen extends ConsumerStatefulWidget {
  const BudgetEditScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends ConsumerState<BudgetEditScreen> {
  final _amountController = TextEditingController();

  Budget? _budget;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBudget() async {
    final month = DateTime(DateTime.now().year, DateTime.now().month, 1);

    try {
      final budgets = await ref.read(budgetsProvider(month).future);

      Budget? matchingBudget;

      for (final budget in budgets) {
        if (budget.categoryId == widget.categoryId) {
          matchingBudget = budget;
          break;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _budget = matchingBudget;
        _loading = false;
      });

      if (matchingBudget != null) {
        _amountController.text = (matchingBudget.limitPaise / 100)
            .toStringAsFixed(0);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveBudget() async {
    final budget = _budget;

    if (budget == null) {
      return;
    }

    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      _showMessage('Please enter a budget amount.');
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount greater than zero.');
      return;
    }

    final limitPaise = (amount * 100).round();

    if (limitPaise < budget.spentPaise) {
      _showMessage('Budget cannot be lower than the amount already spent.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(budgetRepositoryProvider);

      final updatedBudget = budget.copyWith(limitPaise: limitPaise);

      final savedBudget = await repository.saveBudget(updatedBudget);

      ref.invalidate(budgetsProvider(budget.month));

      if (!mounted) {
        return;
      }

      setState(() {
        _budget = savedBudget;
      });

      _showMessage('Budget updated successfully.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to update budget. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final category = _findCategory(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Budget',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _budget == null
          ? _NotFoundState(categoryName: category?.name ?? 'Category')
          : _EditContent(
              budget: _budget!,
              category: category,
              controller: _amountController,
              saving: _saving,
              onSave: _saveBudget,
            ),
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

class _EditContent extends StatelessWidget {
  const _EditContent({
    required this.budget,
    required this.category,
    required this.controller,
    required this.saving,
    required this.onSave,
  });

  final Budget budget;
  final Category? category;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final categoryColor = category == null
        ? AppTheme.primaryBlue
        : Color(category!.colorValue);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _CategoryHeader(category: category, color: categoryColor),

        const SizedBox(height: 20),

        _CurrentBudgetCard(budget: budget, color: categoryColor),

        const SizedBox(height: 20),

        const Text(
          'Monthly budget limit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '₹ ',
            labelText: 'Budget amount',
            hintText: 'Enter monthly limit',
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Enter the maximum amount you want to spend in this category this month.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save budget'),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.color});

  final Category? category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: color,
            size: 28,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category?.name ?? 'Category',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Monthly spending budget',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentBudgetCard extends StatelessWidget {
  const _CurrentBudgetCard({required this.budget, required this.color});

  final Budget budget;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = budget.progress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current usage',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${budget.spentPaise.abs() ~/ 100}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(width: 6),

                const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    'spent',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),

                const Spacer(),

                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: const Color(0xFFE9EEF5),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              budget.isOverBudget
                  ? '₹${budget.remainingPaise.abs() ~/ 100} over budget'
                  : '₹${budget.remainingPaise ~/ 100} remaining',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No budget found for $categoryName',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
