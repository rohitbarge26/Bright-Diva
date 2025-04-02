import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}

final class DashboardChartData extends DashboardEvent {
  const DashboardChartData();

  @override
  List<Object> get props => [];
}