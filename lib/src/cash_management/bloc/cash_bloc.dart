import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/cash_management/repository/cash_repository.dart';
import '../model/get_cash_receipt_response.dart';
import 'cash_event.dart';
import 'cash_state.dart';

class CashBloc extends Bloc<CashEvent, CashState> {
  CashRepository cashRepository;
  int currentPage = 0;
  bool isFetching = false;

  CashBloc({required this.cashRepository})
      : super(const CashAddInitialState()) {
    on<AddNewCashReceipt>((event, emit) async {
      try {
        final customerAddResponse =
        await cashRepository.addCash(event.addCashReceiptRequest);
        emit(CashAddLoadedState(cashAddResponse: customerAddResponse));
      } catch (e) {
        emit(CashAddErrorState(error: e.toString()));
      }
    });

    /*on<GetCashReceiptList>((event, emit) async {
      try {
        final cashReceiptList =
        await cashRepository.getCashReceipt(0);
        emit(CashGetLoadedState(getCashReceiptResponse: cashReceiptList));
      } catch (e) {
        emit(CashGetErrorState(error: e.toString()));
      }
    });*/

    on<GetCashReceiptList>(_onGetCustomerList);
    on<GetCashReceiptFetchNextPage>(_onGetCustomerListFetchNextPage);


    on<DeleteCashReceipt>((event, emit) async {
      try {
        final deleteCustomerResponse =
        await cashRepository.deleteCashReceipt(event.cashReceiptId);
        emit(CashDeleteLoadedState(
            deleteCustomerResponse: deleteCustomerResponse));
      } catch (e) {
        emit(CashDeleteErrorState(error: e.toString()));
      }
    });

    on<GetCashDetailsByID>((event, emit) async {
      try {
        final cashIdResponse =
        await cashRepository.getCashReceiptById(event.cashId);
        emit(CashDetailsLoadedState(cashDetailsByIdResponse: cashIdResponse));
      } catch (e) {
        emit(CashDetailsErrorState(error: e.toString()));
      }
    });

    on<EditCashReceipt>((event, emit) async {
      try {
        final editCashIdResponse =
        await cashRepository.editCashReceipt(event.cashReceiptId,event.editCashReceiptRequest);
        emit(CashEditLoadedState(editInvoiceResponse: editCashIdResponse));
      } catch (e) {
        emit(CashEditErrorState(error: e.toString()));
      }
    });

  }

  Future<void> _onGetCustomerList(
      GetCashReceiptList event, Emitter<CashState> emit) async {
    try {
      emit(const CashGetInitialState());
      currentPage = 0;
      final pendingJobResponse =
      await cashRepository.getCashReceipt(currentPage);
      if (pendingJobResponse != null && pendingJobResponse.data != null) {
        if (pendingJobResponse.data!.length == 1) {
          emit(CashGetLoadedState(
            getCashReceiptResponse: pendingJobResponse,
            hasReachedMax: true,
          ));
        } else {
          emit(CashGetLoadedState(
            getCashReceiptResponse: pendingJobResponse,
            hasReachedMax: pendingJobResponse.data!.isEmpty,
          ));
        }
      } else {
        emit(const CashGetErrorState(error: "No data found"));
      }
    } catch (e) {
      emit(CashGetErrorState(error: e.toString()));
    }
  }

  Future<void> _onGetCustomerListFetchNextPage(
      GetCashReceiptFetchNextPage event, Emitter<CashState> emit) async {
    final currentState = state;
    if (currentState is CashGetLoadedState &&
        !currentState.hasReachedMax &&
        !isFetching) {
      try {
        isFetching = true;
        final nextPage = currentPage + 1;
        final pendingJobResponse =
        await cashRepository.getCashReceipt(nextPage);

        if (pendingJobResponse != null &&
            pendingJobResponse.data != null) {
          final newPendingJobData =
              (currentState.getCashReceiptResponse?.data)! +
                  pendingJobResponse.data!;
          emit(CashGetLoadedState(
            hasReachedMax: pendingJobResponse.data!.isEmpty,
            getCashReceiptResponse:
            GetCashReceiptResponse(data: newPendingJobData),
          ));
          currentPage = nextPage;
        } else {
          emit(currentState.copyWith(hasReachedMax: true));
        }
      } catch (e) {
        emit(CashGetErrorState(error: e.toString()));
      } finally {
        isFetching = false;
      }
    }
  }
}
