import '../../../core/utils/mock_data.dart';
import '../domain/month_summary.dart';
import '../domain/overview_repository.dart';

class MockOverviewRepository implements OverviewRepository {
  @override
  Future<MonthSummary> getMonthSummary(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return MockData.buildSummary(month);
  }
}
