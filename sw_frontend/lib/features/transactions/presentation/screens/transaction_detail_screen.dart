import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  String _selectedCategory = 'Food & Dining';
  bool _applyToMerchant = false;

  final List<String> _categories = const [
    'Food & Dining',
    'Shopping',
    'Transport',
    'Bills',
    'Entertainment',
    'Groceries',
    'Health',
    'Travel',
    'Other',
  ];

  void _saveCategory() {
    // Actual repository update will be added later.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _applyToMerchant
              ? 'Category updated for this transaction and merchant'
              : 'Transaction category updated',
        ),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Undo logic will be implemented later.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAmountCard(context),

          const SizedBox(height: 20),

          _buildDetailsCard(context),

          const SizedBox(height: 20),

          _buildCategoryCard(context),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saveCategory,
              child: const Text(
                'Save category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(
              Icons.restaurant_rounded,
              color: Color(0xFF1565C0),
              size: 30,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Swiggy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '-₹540',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text('23 September 2026', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return _buildCard(
      title: 'Transaction details',
      child: Column(
        children: [
          _buildDetailRow(label: 'Merchant', value: 'Swiggy'),
          const Divider(height: 24),
          _buildDetailRow(label: 'Original description', value: 'SWIGGY*1234'),
          const Divider(height: 24),
          _buildDetailRow(label: 'Payment mode', value: 'UPI'),
          const Divider(height: 24),
          _buildDetailRow(label: 'Transaction ID', value: widget.transactionId),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context) {
    return _buildCard(
      title: 'Category',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Transaction category',
            ),
            items: _categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 16),

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Apply to this merchant',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Future matching transactions will use this category.',
            ),
            value: _applyToMerchant,
            onChanged: (value) {
              setState(() {
                _applyToMerchant = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF667085))),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
