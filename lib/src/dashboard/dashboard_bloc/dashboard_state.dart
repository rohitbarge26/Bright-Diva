import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/dashboard/model/dashboard_chart_response.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardChartInitialState extends DashboardState {
  const DashboardChartInitialState();

  @override
  List<Object?> get props => [];
}

class DashboardChartLoadedState extends DashboardState {
  final DashboardChartResponse? dashboardChartResponse;

  const DashboardChartLoadedState(
      {required this.dashboardChartResponse});

  @override
  List<Object?> get props => [dashboardChartResponse];
}

class DashboardChartErrorState extends DashboardState {
  final String error;

  const DashboardChartErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}