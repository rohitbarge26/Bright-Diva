import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/cash_management/model/add_cash_receipt_request.dart';

import '../model/edit_cash_receipt_request.dart';


abstract class CashEvent extends Equatable {
  const CashEvent();
  @override
  List<Object> get props => [];
}

class AddNewCashReceipt extends CashEvent {
  CashReceiptRequest addCashReceiptRequest;

  AddNewCashReceipt({required this.addCashReceiptRequest});

  @override
  List<Object> get props => [addCashReceiptRequest];
}

class GetCashReceipt extends CashEvent {
  const GetCashReceipt();

  @override
  List<Object> get props => [];
}

class GetCashReceiptList extends CashEvent {
  const GetCashReceiptList();

  @override
  List<Object> get props => [];
}

class GetCashReceiptFetchNextPage extends CashEvent {
  const GetCashReceiptFetchNextPage();

  @override
  List<Object> get props => [];
}

class GetCashDetailsByID extends CashEvent {
  String cashId;

  GetCashDetailsByID({required this.cashId});

  @override
  List<Object> get props => [cashId];
}


class DeleteCashReceipt extends CashEvent {
  String cashReceiptId;

  DeleteCashReceipt({required this.cashReceiptId});

  @override
  List<Object> get props => [cashReceiptId];
}

class EditCashReceipt extends CashEvent {
  String cashReceiptId;
  EditCashReceiptRequest editCashReceiptRequest;

  EditCashReceipt({required this.cashReceiptId, required this.editCashReceiptRequest});

  @override
  List<Object> get props => [cashReceiptId,editCashReceiptRequest];
}