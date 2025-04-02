import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/order_management/repository/InvoiceRepository.dart';

import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {

  InvoiceRepository invoiceRepository;
  int currentPage = 0;
  bool isFetching = false;

  InvoiceBloc({required this.invoiceRepository})
      : super(const InvoiceAddInitialState()) {
    on<AddInvoice>((event, emit) async {
      try {
        final invoiceAddResponse =
        await invoiceRepository.addInvoice(event.addInvoiceRequest);
        emit(InvoiceAddLoadedState(addInvoiceResponse: invoiceAddResponse));
      } catch (e) {
        emit(InvoiceAddErrorState(error: e.toString()));
      }
    });

    on<GetInvoiceDetails>((event, emit) async {
      try {
        final getInvoiceResponse =
        await invoiceRepository.getInvoice(0);
        emit(InvoiceGetLoadedState(getInvoiceDetailsResponse: getInvoiceResponse));
      } catch (e) {
        emit(InvoiceGetErrorState(error: e.toString()));
      }
    });
    on<GetInvoiceDetailsByID>((event, emit) async {
      try {
        final invoiceByIdResponse =
        await invoiceRepository.getInvoiceById(event.invoiceId);
        print("Print Invoice Bloc:: ${invoiceByIdResponse.toString()}");
        emit(InvoiceGetDetailsLoadedState(getDetailsById: invoiceByIdResponse));
      } catch (e) {
        emit(InvoiceGetDetailsErrorState(error: e.toString()));
      }
    });

    on<DeleteInvoice>((event, emit) async {
      try {
        final deleteCustomerResponse =
        await invoiceRepository.deleteInvoice(event.invoiceId);
        emit(InvoiceDeleteLoadedState(
            deleteCustomerResponse: deleteCustomerResponse));
      } catch (e) {
        emit(InvoiceDeleteErrorState(error: e.toString()));
      }
    });
    on<EditInvoice>((event, emit) async {
      try {
        final editInvoiceResponse =
        await invoiceRepository.editInvoice(event.invoiceId, event.editRequest);
        emit(InvoiceEditLoadedState(editInvoiceResponse: editInvoiceResponse));
      } catch (e) {
        emit(InvoiceEditErrorState(error: e.toString()));
      }
    });
  }
}
