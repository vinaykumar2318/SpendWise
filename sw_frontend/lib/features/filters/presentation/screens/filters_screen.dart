import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../transactions/state/transaction_providers.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  String? _categoryId;
  String? _merchantQuery;

  double? _minAmount;
  double? _maxAmount;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    final currentFilter = ref.read(transactionFilterProvider);

    _categoryId = currentFilter.categoryId;
    _merchantQuery = currentFilter.query;

    _minAmount = currentFilter.minAmountPaise == null
        ? null
        : currentFilter.minAmountPaise! / 100;

    _maxAmount = currentFilter.maxAmountPaise == null
        ? null
        : currentFilter.maxAmountPaise! / 100;

    _startDate = currentFilter.startDate;
    _endDate = currentFilter.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filters',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(onPressed: _clearFilters, child: const Text('Clear')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _sectionTitle('Category'),
          const SizedBox(height: 10),
          _CategorySelector(
            selectedCategoryId: _categoryId,
            onChanged: (value) {
              setState(() {
                _categoryId = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle('Merchant'),
          const SizedBox(height: 10),
          _MerchantField(
            initialValue: _merchantQuery ?? '',
            onChanged: (value) {
              _merchantQuery = value.trim().isEmpty ? null : value.trim();
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle('Amount'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AmountField(
                  label: 'Minimum',
                  initialValue: _minAmount == null
                      ? ''
                      : _minAmount!.toStringAsFixed(0),
                  onChanged: (value) {
                    _minAmount = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountField(
                  label: 'Maximum',
                  initialValue: _maxAmount == null
                      ? ''
                      : _maxAmount!.toStringAsFixed(0),
                  onChanged: (value) {
                    _maxAmount = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Date range'),
          const SizedBox(height: 10),
          _DateSelector(
            startDate: _startDate,
            endDate: _endDate,
            onStartDateChanged: (date) {
              setState(() {
                _startDate = date;
              });
            },
            onEndDateChanged: (date) {
              setState(() {
                _endDate = date;
              });
            },
          ),
          const SizedBox(height: 28),
          _FilterSummary(
            categoryId: _categoryId,
            merchantQuery: _merchantQuery,
            minAmount: _minAmount,
            maxAmount: _maxAmount,
            startDate: _startDate,
            endDate: _endDate,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply filters'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }

  void _applyFilters() {
    if (_minAmount != null && _maxAmount != null && _minAmount! > _maxAmount!) {
      _showMessage('Minimum amount cannot be greater than maximum amount.');
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      _showMessage('Start date cannot be after end date.');
      return;
    }

    ref
        .read(transactionFilterProvider.notifier)
        .setFilter(
          TransactionFilter(
            startDate: _startDate,
            endDate: _endDate,
            categoryId: _categoryId,
            query: _merchantQuery,
            minAmountPaise: _minAmount == null
                ? null
                : (_minAmount! * 100).round(),
            maxAmountPaise: _maxAmount == null
                ? null
                : (_maxAmount! * 100).round(),
          ),
        );

    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _categoryId = null;
      _merchantQuery = null;
      _minAmount = null;
      _maxAmount = null;
      _startDate = null;
      _endDate = null;
    });

    ref.read(transactionFilterProvider.notifier).clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MerchantField extends StatefulWidget {
  const _MerchantField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_MerchantField> createState() => _MerchantFieldState();
}

class _MerchantFieldState extends State<_MerchantField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        labelText: 'Search merchant',
        hintText: 'e.g. Swiggy',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selectedCategoryId == null,
          onSelected: (_) {
            onChanged(null);
          },
        ),
        ...MockData.categories.map((category) {
          return ChoiceChip(
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (selected) {
              onChanged(selected ? category.id : null);
            },
          );
        }),
      ],
    );
  }
}

class _AmountField extends StatefulWidget {
  const _AmountField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: widget.onChanged,
      decoration: InputDecoration(labelText: widget.label, prefixText: '₹ '),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DateButton(
          label: 'Start date',
          date: startDate,
          onTap: () async {
            final date = await _pickDate(context, startDate);

            if (date != null) {
              onStartDateChanged(date);
            }
          },
          onClear: startDate == null
              ? null
              : () {
                  onStartDateChanged(null);
                },
        ),
        const SizedBox(height: 10),
        _DateButton(
          label: 'End date',
          date: endDate,
          onTap: () async {
            final date = await _pickDate(context, endDate);

            if (date != null) {
              onEndDateChanged(date);
            }
          },
          onClear: endDate == null
              ? null
              : () {
                  onEndDateChanged(null);
                },
        ),
      ],
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initialDate) {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date == null ? 'Select date' : _formatDate(date!),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 19),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _FilterSummary extends StatelessWidget {
  const _FilterSummary({
    required this.categoryId,
    required this.merchantQuery,
    required this.minAmount,
    required this.maxAmount,
    required this.startDate,
    required this.endDate,
  });

  final String? categoryId;
  final String? merchantQuery;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final filters = <String>[];

    if (categoryId != null) {
      for (final category in MockData.categories) {
        if (category.id == categoryId) {
          filters.add(category.name);
          break;
        }
      }
    }

    if (merchantQuery != null && merchantQuery!.isNotEmpty) {
      filters.add('Merchant: $merchantQuery');
    }

    if (minAmount != null) {
      filters.add('Min: ₹${minAmount!.toStringAsFixed(0)}');
    }

    if (maxAmount != null) {
      filters.add('Max: ₹${maxAmount!.toStringAsFixed(0)}');
    }

    if (startDate != null) {
      filters.add('From: ${startDate!.day}/${startDate!.month}');
    }

    if (endDate != null) {
      filters.add('To: ${endDate!.day}/${endDate!.month}');
    }

    if (filters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No filters selected.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map((filter) {
          return Chip(
            label: Text(filter),
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }
}
