import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository})
      : super(const DashboardChartInitialState()) {
    on<DashboardChartData>((event, emit) async {
      try {
        final dashboardChartResponse =
            await dashboardRepository.getDashboardChartData();
        emit(DashboardChartLoadedState(
            dashboardChartResponse: dashboardChartResponse));
      } catch (e) {
        emit(DashboardChartErrorState(error: e.toString()));
      }
    });
  }
}
