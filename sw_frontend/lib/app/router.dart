import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/overview/presentation/screens/overview_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/budgets/presentation/screens/budget_edit_screen.dart';
import '../features/merchants/presentation/screens/merchants_screen.dart';
import '../features/merchants/presentation/screens/merchant_detail_screen.dart';
import '../features/filters/presentation/screens/filters_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.overview,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.overview,
            builder: (context, state) => const OverviewScreen(),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final transactionId = state.pathParameters['id']!;

                  return TransactionDetailScreen(transactionId: transactionId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.budgets,
            builder: (context, state) => const BudgetsScreen(),
            routes: [
              GoRoute(
                path: ':category',
                builder: (context, state) {
                  return BudgetEditScreen(
                    categoryId: state.pathParameters['category']!,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.merchants,
            builder: (context, state) => const MerchantsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final merchantId = state.pathParameters['id']!;

                  return MerchantDetailScreen(merchantId: merchantId);
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.filters,
        builder: (context, state) => const FiltersScreen(),
      ),
    ],
  );
}
