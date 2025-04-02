import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/settings/model/currency/currency_request.dart';
import 'package:frequent_flow/src/settings/model/user/create_user_request.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object> get props => [];
}

class UpdateCurrency extends CurrencyEvent {
  CurrencyRequest currencyRequest;
  String user_Id;

  UpdateCurrency({required this.currencyRequest, required this.user_Id});

  @override
  List<Object> get props => [currencyRequest, user_Id];
}

class GetCurrencyUpdate extends CurrencyEvent {
  const GetCurrencyUpdate();

  @override
  List<Object> get props => [];
}
