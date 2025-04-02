import 'package:equatable/equatable.dart';

import '../model/expected_date_response.dart';

abstract class ExpectedState extends Equatable {
  const ExpectedState();
  @override
  List<Object?> get props => [];
}

class ExpectedDateInitialState extends ExpectedState {
  const ExpectedDateInitialState();

  @override
  List<Object?> get props => [];
}

class ExpectedDateLoadedState extends ExpectedState {
  final ExpectedDateResponse? expectedDateResponse;

  const ExpectedDateLoadedState({required this.expectedDateResponse});

  @override
  List<Object?> get props => [expectedDateResponse];
}

class ExpectedDateErrorState extends ExpectedState {
  final String error;

  const ExpectedDateErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}