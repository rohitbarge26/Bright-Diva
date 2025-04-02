import 'package:equatable/equatable.dart';

import '../../model/currency/get_currency_response.dart';
import '../../model/currency/currency_response.dart';


abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitialState extends CurrencyState {
  const CurrencyInitialState();

  @override
  List<Object?> get props => [];
}

class CurrencyLoadedState extends CurrencyState {
  final CurrencyResponse? currencyResponse;

  const CurrencyLoadedState({required this.currencyResponse});

  @override
  List<Object?> get props => [currencyResponse];
}

class CurrencyErrorState extends CurrencyState {
  final String error;

  const CurrencyErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class GetCurrencyInitialState extends CurrencyState {
  const GetCurrencyInitialState();

  @override
  List<Object?> get props => [];
}

class GetCurrencyLoadedState extends CurrencyState {
  final GetCurrencyResponse? getCurrencyResponse;

  const GetCurrencyLoadedState({required this.getCurrencyResponse});

  @override
  List<Object?> get props => [getCurrencyResponse];
}

class GetCurrencyErrorState extends CurrencyState {
  final String error;

  const GetCurrencyErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}