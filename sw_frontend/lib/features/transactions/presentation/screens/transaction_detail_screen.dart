import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends State<TransactionDetailScreen> {
  String _selectedCategory = 'Food & Dining';
  bool _applyToFutureTransactions = false;

  final List<String> _categories = const [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Groceries',
    'Bills',
    'Income',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _buildAmountCard(),
          const SizedBox(height: 20),
          _buildTransactionInfo(),
          const SizedBox(height: 20),
          _buildCategorySection(),
          const SizedBox(height: 20),
          _buildMerchantRuleSection(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Swiggy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '-₹540',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '23 September 2026',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return _buildSection(
      title: 'Transaction information',
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.storefront_outlined,
            label: 'Merchant',
            value: 'Swiggy',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: _selectedCategory,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.credit_card_outlined,
            label: 'Payment method',
            value: 'ICICI Bank',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'Transaction ID',
            value: widget.transactionId,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return _buildSection(
      title: 'Recategorize',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change the category for this transaction.',
            style: TextStyle(
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantRuleSection() {
    return _buildSection(
      title: 'Merchant rule',
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Apply this category to future Swiggy transactions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Future transactions from this merchant will use the selected category.',
        ),
        value: _applyToFutureTransactions,
        onChanged: (value) {
          setState(() {
            _applyToFutureTransactions = value;
          });
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _applyToFutureTransactions
                  ? 'Category updated and merchant rule saved'
                  : 'Category updated successfully',
            ),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _selectedCategory = 'Food & Dining';
                  _applyToFutureTransactions = false;
                });
              },
            ),
          ),
        );
      },
      icon: const Icon(Icons.check_rounded),
      label: const Text('Save changes'),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1565C0),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF172033),
            ),
          ),
        ),
      ],
    );
  }
}