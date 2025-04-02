import 'package:equatable/equatable.dart';

import '../../customer_management/model/delete_customer.dart';
import '../model/add_order_response.dart';
import '../model/edit_invoice.dart';
import '../model/get_order_by_id.dart';
import '../model/get_order_response.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderAddInitialState extends OrderState {
  const OrderAddInitialState();

  @override
  List<Object?> get props => [];
}

class OrderAddLoadedState extends OrderState {
  final OrderAddResponse? addOrderResponse;

  const OrderAddLoadedState({required this.addOrderResponse});

  @override
  List<Object?> get props => [addOrderResponse];
}

class OrderAddErrorState extends OrderState {
  final String error;

  const OrderAddErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class OrderListInitialState extends OrderState {
  const OrderListInitialState();

  @override
  List<Object?> get props => [];
}

class OrderListLoadedState extends OrderState {
  final OrderGetResponse? getOrderResponse;

  const OrderListLoadedState({required this.getOrderResponse});

  @override
  List<Object?> get props => [getOrderResponse];
}

class OrderListErrorState extends OrderState {
  final String error;

  const OrderListErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}


class OrderDetailsInitialState extends OrderState {
  const OrderDetailsInitialState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsLoadedState extends OrderState {
  final OrderGetByIdResponse? getOrderByIdResponse;

  const OrderDetailsLoadedState({required this.getOrderByIdResponse});

  @override
  List<Object?> get props => [getOrderByIdResponse];
}

class OrderDetailsErrorState extends OrderState {
  final String error;

  const OrderDetailsErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class OrderDeleteInitialState extends OrderState {
  const OrderDeleteInitialState();

  @override
  List<Object?> get props => [];
}

class OrderDeleteLoadedState extends OrderState {
  final DeleteCustomerResponse? deleteCustomerResponse;

  const OrderDeleteLoadedState({required this.deleteCustomerResponse});

  @override
  List<Object?> get props => [deleteCustomerResponse];
}

class OrderDeleteErrorState extends OrderState {
  final String error;

  const OrderDeleteErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class OrderEditInitialState extends OrderState {
  const OrderEditInitialState();

  @override
  List<Object?> get props => [];
}

class OrderEditLoadedState extends OrderState {
  final EditInvoiceResponse? editOrderResponse;

  const OrderEditLoadedState({required this.editOrderResponse});

  @override
  List<Object?> get props => [editOrderResponse];
}

class OrderEditErrorState extends OrderState {
  final String error;

  const OrderEditErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}