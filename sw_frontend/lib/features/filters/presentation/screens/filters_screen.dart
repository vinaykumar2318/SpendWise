import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String? selectedCategory;
  String? selectedMerchant;

  final TextEditingController minAmountController = TextEditingController();

  final TextEditingController maxAmountController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  final List<String> categories = [
    'Food & Dining',
    'Shopping',
    'Transport',
    'Entertainment',
    'Groceries',
    'Bills',
    'Other',
  ];

  final List<String> merchants = [
    'Swiggy',
    'Amazon',
    'Uber',
    'Netflix',
    'BigBasket',
    'Airtel',
  ];

  @override
  void dispose() {
    minAmountController.dispose();
    maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        startDate = selected;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        endDate = selected;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedMerchant = null;
      minAmountController.clear();
      maxAmountController.clear();
      startDate = null;
      endDate = null;
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'category': selectedCategory,
      'merchant': selectedMerchant,
      'minAmount': minAmountController.text,
      'maxAmount': maxAmountController.text,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filters',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(onPressed: _clearFilters, child: const Text('Clear')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(hintText: 'Select category'),
            items: categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Merchant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: selectedMerchant,
            decoration: const InputDecoration(hintText: 'Select merchant'),
            items: merchants.map((merchant) {
              return DropdownMenuItem(value: merchant, child: Text(merchant));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMerchant = value;
              });
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Amount range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    hintText: 'Minimum',
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: maxAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    hintText: 'Maximum',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Date range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectStartDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(_formatDate(startDate)),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectEndDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(_formatDate(endDate)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text(
              'Apply Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
