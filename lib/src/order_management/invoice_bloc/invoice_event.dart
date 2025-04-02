import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/order_management/model/invoice_request.dart';

import '../model/edit_invoice_request.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();
  @override
  List<Object> get props => [];
}

class AddInvoice extends InvoiceEvent {
  InvoiceRequest addInvoiceRequest;

  AddInvoice({required this.addInvoiceRequest});

  @override
  List<Object> get props => [addInvoiceRequest];
}

class GetInvoiceDetails extends InvoiceEvent {
  const GetInvoiceDetails();

  @override
  List<Object> get props => [];
}

class GetInvoiceDetailsByID extends InvoiceEvent {
  String invoiceId;

  GetInvoiceDetailsByID({required this.invoiceId});

  @override
  List<Object> get props => [invoiceId];
}
class DeleteInvoice extends InvoiceEvent {
  String invoiceId;

  DeleteInvoice({required this.invoiceId});

  @override
  List<Object> get props => [invoiceId];
}
class EditInvoice extends InvoiceEvent {
  String invoiceId;
  InvoiceEditRequest editRequest;

  EditInvoice({required this.invoiceId, required this.editRequest});

  @override
  List<Object> get props => [invoiceId, editRequest];
}
