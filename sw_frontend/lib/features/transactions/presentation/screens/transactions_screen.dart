import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String? _selectedMerchant;
  double? _minAmount;
  double? _maxAmount;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<_TransactionGroup> _transactionGroups = const [
    _TransactionGroup(
      date: 'Today, 23 September',
      transactions: [
        _TransactionData(
          id: 'txn_001',
          merchant: 'Swiggy',
          category: 'Food & Dining',
          amount: '₹540',
          icon: Icons.restaurant_rounded,
          isCredit: false,
        ),
        _TransactionData(
          id: 'txn_002',
          merchant: 'Uber',
          category: 'Transport',
          amount: '₹280',
          icon: Icons.directions_car_rounded,
          isCredit: false,
        ),
        _TransactionData(
          id: 'txn_003',
          merchant: 'Amazon',
          category: 'Shopping',
          amount: '₹1,299',
          icon: Icons.shopping_bag_rounded,
          isCredit: false,
        ),
      ],
    ),
    _TransactionGroup(
      date: 'Yesterday, 22 September',
      transactions: [
        _TransactionData(
          id: 'txn_004',
          merchant: 'Netflix',
          category: 'Entertainment',
          amount: '₹649',
          icon: Icons.movie_rounded,
          isCredit: false,
        ),
        _TransactionData(
          id: 'txn_005',
          merchant: 'Salary',
          category: 'Income',
          amount: '₹75,000',
          icon: Icons.account_balance_wallet_rounded,
          isCredit: true,
        ),
      ],
    ),
    _TransactionGroup(
      date: '21 September',
      transactions: [
        _TransactionData(
          id: 'txn_006',
          merchant: 'Airtel',
          category: 'Bills',
          amount: '₹799',
          icon: Icons.receipt_long_rounded,
          isCredit: false,
        ),
        _TransactionData(
          id: 'txn_007',
          merchant: 'BigBasket',
          category: 'Groceries',
          amount: '₹2,450',
          icon: Icons.local_grocery_store_rounded,
          isCredit: false,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilters(_TransactionData transaction) {
    if (_selectedCategory != null &&
        _selectedCategory!.isNotEmpty &&
        transaction.category != _selectedCategory) {
      return false;
    }

    if (_selectedMerchant != null &&
        _selectedMerchant!.isNotEmpty &&
        transaction.merchant != _selectedMerchant) {
      return false;
    }

    final numericAmount = double.tryParse(
      transaction.amount.replaceAll('₹', '').replaceAll(',', ''),
    );

    if (numericAmount == null) {
      return false;
    }

    if (_minAmount != null && numericAmount < _minAmount!) {
      return false;
    }

    if (_maxAmount != null && numericAmount > _maxAmount!) {
      return false;
    }

    return true;
  }

  List<_TransactionGroup> get _filteredGroups {
    final query = _searchController.text.trim().toLowerCase();

    return _transactionGroups
        .map((group) {
          final filteredTransactions = group.transactions.where((transaction) {
            final matchesSearch =
                query.isEmpty ||
                transaction.merchant.toLowerCase().contains(query) ||
                transaction.category.toLowerCase().contains(query) ||
                transaction.amount.toLowerCase().contains(query);

            return matchesSearch && _matchesFilters(transaction);
          }).toList();

          return _TransactionGroup(
            date: group.date,
            transactions: filteredTransactions,
          );
        })
        .where((group) => group.transactions.isNotEmpty)
        .toList();
  }

  int get _visibleTransactionCount {
    return _filteredGroups.fold(
      0,
      (total, group) => total + group.transactions.length,
    );
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _selectedMerchant != null ||
        _minAmount != null ||
        _maxAmount != null ||
        _startDate != null ||
        _endDate != null;
  }

  Future<void> _openFilters() async {
    final result = await context.push('/filters');

    if (!mounted || result is! Map<String, dynamic>) {
      return;
    }

    setState(() {
      _selectedCategory = result['category'] as String?;
      _selectedMerchant = result['merchant'] as String?;
      _minAmount = (result['minAmount'] as num?)?.toDouble();
      _maxAmount = (result['maxAmount'] as num?)?.toDouble();
      _startDate = result['startDate'] as DateTime?;
      _endDate = result['endDate'] as DateTime?;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Filters applied')));
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedMerchant = null;
      _minAmount = null;
      _maxAmount = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = _filteredGroups;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;

                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
            tooltip: _isSearching ? 'Close search' : 'Search transactions',
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: _openFilters,
                tooltip: 'Filter transactions',
                icon: const Icon(Icons.tune_rounded),
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD92D20),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            if (_isSearching) ...[
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search merchant or category',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear_rounded),
                        )
                      : null,
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
            ],
            _buildMonthHeader(context),
            const SizedBox(height: 20),
            if (filteredGroups.isEmpty)
              _buildEmptyState(context)
            else
              for (int i = 0; i < filteredGroups.length; i++) ...[
                _buildDaySection(
                  context,
                  date: filteredGroups[i].date,
                  transactions: filteredGroups[i].transactions,
                ),
                if (i != filteredGroups.length - 1) const SizedBox(height: 24),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'September 2026',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_visibleTransactionCount transactions shown',
                  style: const TextStyle(color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Change month',
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Color(0xFF98A2B3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your search or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF667085)),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _clearFilters();
              setState(() {});
            },
            child: const Text('Clear search and filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context, {
    required String date,
    required List<_TransactionData> transactions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475467),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                _buildTransactionTile(context, transactions[i]),
                if (i != transactions.length - 1)
                  const Divider(height: 1, indent: 76),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    _TransactionData transaction,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.push('/transactions/${transaction.id}');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(transaction.icon, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction.isCredit
                  ? '+${transaction.amount}'
                  : '-${transaction.amount}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: transaction.isCredit
                    ? const Color(0xFF16803C)
                    : const Color(0xFF172033),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionGroup {
  const _TransactionGroup({required this.date, required this.transactions});

  final String date;
  final List<_TransactionData> transactions;
}

class _TransactionData {
  const _TransactionData({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.icon,
    required this.isCredit,
  });

  final String id;
  final String merchant;
  final String category;
  final String amount;
  final IconData icon;
  final bool isCredit;
}
