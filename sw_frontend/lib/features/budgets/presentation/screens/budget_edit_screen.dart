import 'package:flutter/material.dart';

class BudgetEditScreen extends StatefulWidget {
  final String category;

  const BudgetEditScreen({super.key, required this.category});

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  late final TextEditingController budgetController;

  final int currentSpent = 4820;

  @override
  void initState() {
    super.initState();

    budgetController = TextEditingController(text: '6000');
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final value = budgetController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget amount.')),
      );
      return;
    }

    final budget = int.tryParse(value);

    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.category} budget updated to ₹$budget')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final budget = int.tryParse(budgetController.text) ?? 0;

    final double progress = budget > 0
        ? (currentSpent / budget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Budget',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Monthly budget',
                        style: TextStyle(color: Color(0xFF667085)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Budget amount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              setState(() {});
            },
            decoration: const InputDecoration(
              prefixText: '₹ ',
              hintText: 'Enter monthly budget',
            ),
          ),

          const SizedBox(height: 24),

          // Current spending
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current spending',
                    style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹$currentSpent',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    budget > 0
                        ? '${(progress * 100).toStringAsFixed(0)}% of budget used'
                        : 'Enter a valid budget',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _saveBudget,
            child: const Text(
              'Save Budget',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
