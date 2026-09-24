import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../domain/category.dart';
import '../../domain/transaction.dart';
import '../../state/transaction_providers.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  String? _selectedCategoryId;
  bool _applyToMerchant = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final transactionAsync = ref.watch(
      transactionByIdProvider(widget.transactionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: transactionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          onRetry: () {
            ref.invalidate(transactionByIdProvider(widget.transactionId));
          },
        ),
        data: (transaction) {
          if (transaction == null) {
            return const _NotFoundState();
          }

          return _buildContent(transaction);
        },
      ),
    );
  }

  Widget _buildContent(Transaction transaction) {
    final selectedCategoryId = _selectedCategoryId ?? transaction.categoryId;

    final category = _findCategory(selectedCategoryId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _AmountCard(transaction: transaction, category: category),

        const SizedBox(height: 16),

        _DetailsCard(transaction: transaction),

        const SizedBox(height: 16),

        _CategoryCard(
          selectedCategoryId: selectedCategoryId,
          onChanged: _saving
              ? null
              : (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
        ),

        const SizedBox(height: 16),

        _MerchantRuleCard(
          merchantName: transaction.merchantName,
          value: _applyToMerchant,
          enabled: !_saving,
          onChanged: (value) {
            setState(() {
              _applyToMerchant = value;
            });
          },
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed:
              _saving ||
                  (selectedCategoryId == transaction.categoryId &&
                      !_applyToMerchant)
              ? null
              : () => _save(transaction),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save changes'),
        ),
      ],
    );
  }

  Future<void> _save(Transaction transaction) async {
    final categoryId = _selectedCategoryId ?? transaction.categoryId;

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(transactionRepositoryProvider);

      await repository.updateTransactionCategory(
        transactionId: transaction.id,
        categoryId: categoryId,
        applyToMerchant: _applyToMerchant,
      );

      // Refresh this transaction.
      ref.invalidate(transactionByIdProvider(transaction.id));

      // Refresh the transaction feed.
      ref.invalidate(transactionsProvider);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedCategoryId = categoryId;
        _applyToMerchant = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction category updated successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update the transaction category.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.transaction, required this.category});

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final isRefund = transaction.isRefund;

    final amountText = '₹${transaction.amountPaise.abs() ~/ 100}';

    final categoryColor = category == null
        ? AppTheme.primaryBlue
        : Color(category!.colorValue);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isRefund ? Icons.undo_rounded : Icons.receipt_long_rounded,
              color: categoryColor,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            isRefund ? '+$amountText' : amountText,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isRefund ? AppTheme.success : AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            transaction.merchantName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            category?.name ?? 'Other',
            style: TextStyle(color: categoryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const _SectionTitle(title: 'Transaction details'),

            const SizedBox(height: 12),

            _DetailRow(label: 'Merchant', value: transaction.merchantName),

            _DetailRow(label: 'Raw name', value: transaction.merchantRaw),

            _DetailRow(label: 'Payment mode', value: transaction.mode),

            _DetailRow(label: 'Currency', value: transaction.currency),

            _DetailRow(
              label: 'Date',
              value: _formatDate(transaction.occurredAt),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${_month(local.month)} ${local.day}, '
        '${local.year} • '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final String selectedCategoryId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'Category'),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Transaction category',
              ),
              items: MockData.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantRuleCard extends StatelessWidget {
  const _MerchantRuleCard({
    required this.merchantName,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String merchantName;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        value: value,
        onChanged: enabled ? onChanged : null,
        title: const Text(
          'Remember for this merchant',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Apply this category to future '
          '$merchantName transactions.',
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Transaction not found',
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
