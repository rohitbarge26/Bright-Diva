import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/order_management/model/invoice_response.dart';

import '../../customer_management/model/delete_customer.dart';
import '../model/edit_invoice.dart';
import '../model/get_invoice_by_id.dart';
import '../model/get_invoice_response.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceAddInitialState extends InvoiceState {
  const InvoiceAddInitialState();

  @override
  List<Object?> get props => [];
}

class InvoiceAddLoadedState extends InvoiceState {
  final InvoiceResponse? addInvoiceResponse;

  const InvoiceAddLoadedState({required this.addInvoiceResponse});

  @override
  List<Object?> get props => [addInvoiceResponse];
}

class InvoiceAddErrorState extends InvoiceState {
  final String error;

  const InvoiceAddErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class InvoiceGetInitialState extends InvoiceState {
  const InvoiceGetInitialState();

  @override
  List<Object?> get props => [];
}

class InvoiceGetLoadedState extends InvoiceState {
  final GetInvoiceResponse? getInvoiceDetailsResponse;

  const InvoiceGetLoadedState({required this.getInvoiceDetailsResponse});

  @override
  List<Object?> get props => [getInvoiceDetailsResponse];
}

class InvoiceGetErrorState extends InvoiceState {
  final String error;

  const InvoiceGetErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class InvoiceGetDetailsInitialState extends InvoiceState {
  const InvoiceGetDetailsInitialState();

  @override
  List<Object?> get props => [];
}

class InvoiceGetDetailsLoadedState extends InvoiceState {
  final InvoiceDetailsByIdResponse? getDetailsById;

  const InvoiceGetDetailsLoadedState({required this.getDetailsById});

  @override
  List<Object?> get props => [getDetailsById];
}

class InvoiceGetDetailsErrorState extends InvoiceState {
  final String error;

  const InvoiceGetDetailsErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class InvoiceDeleteInitialState extends InvoiceState {
  const InvoiceDeleteInitialState();

  @override
  List<Object?> get props => [];
}

class InvoiceDeleteLoadedState extends InvoiceState {
  final DeleteCustomerResponse? deleteCustomerResponse;

  const InvoiceDeleteLoadedState({required this.deleteCustomerResponse});

  @override
  List<Object?> get props => [deleteCustomerResponse];
}

class InvoiceDeleteErrorState extends InvoiceState {
  final String error;

  const InvoiceDeleteErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class InvoiceEditInitialState extends InvoiceState {
  const InvoiceEditInitialState();

  @override
  List<Object?> get props => [];
}

class InvoiceEditLoadedState extends InvoiceState {
  final EditInvoiceResponse? editInvoiceResponse;

  const InvoiceEditLoadedState({required this.editInvoiceResponse});

  @override
  List<Object?> get props => [editInvoiceResponse];
}

class InvoiceEditErrorState extends InvoiceState {
  final String error;

  const InvoiceEditErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}
