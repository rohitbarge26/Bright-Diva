import 'package:equatable/equatable.dart';

import '../model/mis_data_response.dart';

abstract class MisState extends Equatable {
  const MisState();

  @override
  List<Object?> get props => [];
}

class MisInitialState extends MisState {
  const MisInitialState();

  @override
  List<Object?> get props => [];
}

class MisLoadedState extends MisState {
  final MISDataResponse? misDataResponse;

  const MisLoadedState({required this.misDataResponse});

  @override
  List<Object?> get props => [misDataResponse];
}

class MisErrorState extends MisState {
  final String error;

  const MisErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}
