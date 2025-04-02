import 'package:equatable/equatable.dart';

import '../model/expected_date_request.dart';

abstract class ExpectedEvent extends Equatable {
  const ExpectedEvent();

  @override
  List<Object> get props => [];
}

class UpdateExpectedDateInvoice extends ExpectedEvent {
  ExpectedDateRequest request;
  String invoiceId;

  UpdateExpectedDateInvoice({required this.request, required this.invoiceId});

  @override
  List<Object> get props => [request, invoiceId];
}
