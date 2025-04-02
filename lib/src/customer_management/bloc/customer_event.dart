import 'package:equatable/equatable.dart';

import '../model/add_customer_request.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object> get props => [];
}

class AddNewCustomer extends CustomerEvent {
  CustomerAddRequest addCustomerRequest;

  AddNewCustomer({required this.addCustomerRequest});

  @override
  List<Object> get props => [addCustomerRequest];
}

class GetCustomer extends CustomerEvent {
  const GetCustomer();

  @override
  List<Object> get props => [];
}

class GetCustomerList extends CustomerEvent {
  const GetCustomerList();

  @override
  List<Object> get props => [];
}

class GetCustomerFetchNextPage extends CustomerEvent {
  const GetCustomerFetchNextPage();

  @override
  List<Object> get props => [];
}

class DeleteCustomer extends CustomerEvent {
  String customerId;

  DeleteCustomer({required this.customerId});

  @override
  List<Object> get props => [customerId];
}

class EditCustomer extends CustomerEvent {
  String customerId;
  CustomerAddRequest addCustomerRequest;

  EditCustomer({required this.customerId, required this.addCustomerRequest});

  @override
  List<Object> get props => [customerId];
}