import 'package:equatable/equatable.dart';
import '../model/add_customer_response.dart';
import '../model/delete_customer.dart';
import '../model/edit_customer.dart';
import '../model/get_customer.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerAddInitialState extends CustomerState {
  const CustomerAddInitialState();

  @override
  List<Object?> get props => [];
}

class CustomerAddLoadedState extends CustomerState {
  final CustomerAddResponse? customerAddResponse;

  const CustomerAddLoadedState({required this.customerAddResponse});

  @override
  List<Object?> get props => [customerAddResponse];
}

class CustomerAddErrorState extends CustomerState {
  final String error;

  const CustomerAddErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class CustomerGetInitialState extends CustomerState {
  const CustomerGetInitialState();

  @override
  List<Object?> get props => [];
}

class CustomerGetLoadedState extends CustomerState {
  final GetCustomerResponse? customerGetResponse;
  final bool hasReachedMax;

  CustomerGetLoadedState copyWith({
    GetCustomerResponse? myJobAllResponse,
    bool? hasReachedMax,
  }) {
    return CustomerGetLoadedState(
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        customerGetResponse: myJobAllResponse ?? this.customerGetResponse);
  }

  const CustomerGetLoadedState({
    required this.customerGetResponse,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [customerGetResponse];
}

class CustomerGetErrorState extends CustomerState {
  final String error;

  const CustomerGetErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class CustomerDeleteInitialState extends CustomerState {
  const CustomerDeleteInitialState();

  @override
  List<Object?> get props => [];
}

class CustomerDeleteLoadedState extends CustomerState {
  final DeleteCustomerResponse? deleteCustomerResponse;

  const CustomerDeleteLoadedState({required this.deleteCustomerResponse});

  @override
  List<Object?> get props => [deleteCustomerResponse];
}

class CustomerDeleteErrorState extends CustomerState {
  final String error;

  const CustomerDeleteErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class CustomerListInitialState extends CustomerState {
  const CustomerListInitialState();

  @override
  List<Object?> get props => [];
}

class CustomerListLoadedState extends CustomerState {
  final GetCustomerResponse? getCustomerListResponse;

  const CustomerListLoadedState({required this.getCustomerListResponse});

  @override
  List<Object?> get props => [getCustomerListResponse];
}

class CustomerListErrorState extends CustomerState {
  final String error;

  const CustomerListErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}


class CustomerEditInitialState extends CustomerState {
  const CustomerEditInitialState();

  @override
  List<Object?> get props => [];
}

class CustomerEditLoadedState extends CustomerState {
  final EditCustomerResponse? editCustomerResponse;

  const CustomerEditLoadedState({required this.editCustomerResponse});

  @override
  List<Object?> get props => [editCustomerResponse];
}

class CustomerEditErrorState extends CustomerState {
  final String error;

  const CustomerEditErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}