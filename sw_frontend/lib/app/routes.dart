class AppRoutes {
  AppRoutes._();

  // Authentication
  static const String login = '/login';

  // Main sections
  static const String overview = '/overview';
  static const String transactions = '/transactions';
  static const String budgets = '/budgets';
  static const String merchants = '/merchants';

  // Detail routes
  static const String transactionDetail = '/transactions/:id';
  static const String budgetEdit = '/budgets/:category';
  static const String merchantDetail = '/merchants/:id';

  // Filters
  static const String filters = '/filters';
}
