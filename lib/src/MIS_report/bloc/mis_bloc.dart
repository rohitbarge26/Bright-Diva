import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/mis_repository.dart';
import 'mis_event.dart';
import 'mis_state.dart';

class MisBloc extends Bloc<MisEvent, MisState> {
  MisRepository misRepository;

  MisBloc({required this.misRepository})
      : super(const MisInitialState()) {
    on<MISFilterEvent>((event, emit) async {
      try {
        final updateInvoice = await misRepository.getMISReport(
            event.type, event.fromDate, event.toDate, event.customerId!);
        emit(MisLoadedState(misDataResponse: updateInvoice));
      } catch (e) {
        emit(MisErrorState(error: e.toString()));
      }
    });
  }
}
