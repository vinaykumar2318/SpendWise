import 'month_summary.dart';

abstract interface class OverviewRepository {
  Future<MonthSummary> getMonthSummary(DateTime month);
}
