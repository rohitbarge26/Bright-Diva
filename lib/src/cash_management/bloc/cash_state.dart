import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/order_management/model/edit_invoice.dart';

import '../../customer_management/model/delete_customer.dart';
import '../model/add_cash_receipt_response.dart';
import '../model/get_cash_receipt_by_id.dart';
import '../model/get_cash_receipt_response.dart';

abstract class CashState extends Equatable {
  const CashState();

  @override
  List<Object?> get props => [];
}

class CashAddInitialState extends CashState {
  const CashAddInitialState();

  @override
  List<Object?> get props => [];
}

class CashAddLoadedState extends CashState {
  final CashReceiptResponse? cashAddResponse;

  const CashAddLoadedState({required this.cashAddResponse});

  @override
  List<Object?> get props => [cashAddResponse];
}

class CashAddErrorState extends CashState {
  final String error;

  const CashAddErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class CashGetInitialState extends CashState {
  const CashGetInitialState();

  @override
  List<Object?> get props => [];
}

class CashGetLoadedState extends CashState {
  final GetCashReceiptResponse? getCashReceiptResponse;
  final bool hasReachedMax;

  CashGetLoadedState copyWith({
    GetCashReceiptResponse? myJobAllResponse,
    bool? hasReachedMax,
  }) {
    return CashGetLoadedState(
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        getCashReceiptResponse: myJobAllResponse ?? this.getCashReceiptResponse);
  }

  const CashGetLoadedState({
    required this.getCashReceiptResponse,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [getCashReceiptResponse];
}

class CashGetErrorState extends CashState {
  final String error;

  const CashGetErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class CashDetailsInitialState extends CashState {
  const CashDetailsInitialState();

  @override
  List<Object?> get props => [];
}

class CashDetailsLoadedState extends CashState {
  final CashDetailsByIdResponse? cashDetailsByIdResponse;

  const CashDetailsLoadedState({required this.cashDetailsByIdResponse});

  @override
  List<Object?> get props => [cashDetailsByIdResponse];
}

class CashDetailsErrorState extends CashState {
  final String error;

  const CashDetailsErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class CashDeleteInitialState extends CashState {
  const CashDeleteInitialState();

  @override
  List<Object?> get props => [];
}

class CashDeleteLoadedState extends CashState {
  final DeleteCustomerResponse? deleteCustomerResponse;

  const CashDeleteLoadedState({required this.deleteCustomerResponse});

  @override
  List<Object?> get props => [deleteCustomerResponse];
}

class CashDeleteErrorState extends CashState {
  final String error;

  const CashDeleteErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}


class CashEditInitialState extends CashState {
  const CashEditInitialState();

  @override
  List<Object?> get props => [];
}

class CashEditLoadedState extends CashState {
  final EditInvoiceResponse? editInvoiceResponse;

  const CashEditLoadedState({required this.editInvoiceResponse});

  @override
  List<Object?> get props => [editInvoiceResponse];
}

class CashEditErrorState extends CashState {
  final String error;

  const CashEditErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

