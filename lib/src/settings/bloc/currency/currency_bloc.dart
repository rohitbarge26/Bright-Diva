import 'package:flutter_bloc/flutter_bloc.dart';

import '../../respository/CurrencyResponse.dart';
import 'currency_event.dart';
import 'currency_state.dart';


class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyRepository currencyRepository;
  int currentPage = 0;
  bool isFetching = false;

  CurrencyBloc({required this.currencyRepository})
      : super(const CurrencyInitialState()) {
    on<UpdateCurrency>((event, emit) async {
      try {
        final currencyRequest =
        await currencyRepository.updateCurrency(event.currencyRequest, event.user_Id);
        emit(CurrencyLoadedState(currencyResponse: currencyRequest));
      } catch (e) {
        emit(CurrencyErrorState(error: e.toString()));
      }
    });
    on<GetCurrencyUpdate>((event, emit) async{
      try{
        final getCurrencyResponse = await currencyRepository.getCurrencyRate();
        emit(GetCurrencyLoadedState(getCurrencyResponse: getCurrencyResponse));
      }catch(e){
        emit(GetCurrencyErrorState(error: e.toString()));
      }
    });
  }}