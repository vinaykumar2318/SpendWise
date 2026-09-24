import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_overview_repository.dart';
import '../domain/month_summary.dart';
import '../domain/overview_repository.dart';

final overviewRepositoryProvider = Provider<OverviewRepository>((ref) {
  return MockOverviewRepository();
});

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

final monthSummaryProvider = FutureProvider.autoDispose<MonthSummary>((
  ref,
) async {
  final repository = ref.watch(overviewRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);

  return repository.getMonthSummary(month);
});

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }
}
