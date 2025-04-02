import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/expected_payment_date/bloc/expected_event.dart';
import 'package:frequent_flow/src/expected_payment_date/bloc/expected_state.dart';

import '../repository/expected_date_repository.dart';

class ExpectedBloc extends Bloc<ExpectedEvent, ExpectedState> {
  ExpectedDateRepository expectedDateRepository;


  ExpectedBloc({required this.expectedDateRepository})
      : super(const ExpectedDateInitialState()) {
    on<UpdateExpectedDateInvoice>((event, emit) async {
      try {
        final updateInvoice =
        await expectedDateRepository.updateExpectedDate(event.request, event.invoiceId);
        emit(ExpectedDateLoadedState(expectedDateResponse: updateInvoice));
      } catch (e) {
        emit(ExpectedDateErrorState(error: e.toString()));
      }
    });
  }}