import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith(AppRoutes.transactions)) {
      return 1;
    }

    if (location.startsWith(AppRoutes.budgets)) {
      return 2;
    }

    if (location.startsWith(AppRoutes.merchants)) {
      return 3;
    }

    return 0;
  }

  String _getCurrentTitle(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/transactions')) {
      return 'Transactions';
    }

    if (location.startsWith('/budgets')) {
      return 'Budgets';
    }

    if (location.startsWith('/merchants')) {
      return 'Merchants';
    }

    return 'Overview';
  }

  final List<String> routes = const [
    AppRoutes.overview,
    AppRoutes.transactions,
    AppRoutes.budgets,
    AppRoutes.merchants,
  ];

  void _onItemTapped(int index) {
    final currentIndex = _getCurrentIndex(context);
    if (index == currentIndex) {
      return;
    }

    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCurrentTitle(context),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getCurrentIndex(context),
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Merchants',
          ),
        ],
      ),
    );
  }
}
