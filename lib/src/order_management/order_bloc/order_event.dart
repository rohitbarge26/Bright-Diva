import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/order_management/model/add_order_request.dart';

import '../model/edit_order_request.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class AddOrder extends OrderEvent {
  OrderAddRequest addOrderRequest;

  AddOrder({required this.addOrderRequest});

  @override
  List<Object> get props => [addOrderRequest];
}

class GetOrderList extends OrderEvent {
  const GetOrderList();

  @override
  List<Object> get props => [];
}

class GetOrderDetails extends OrderEvent {
  String orderId;

  GetOrderDetails({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class DeleteOrder extends OrderEvent {
  String orderId;

  DeleteOrder({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class EditOrder extends OrderEvent {
  String orderId;
  OrderEditRequest orderEditRequest;

  EditOrder({required this.orderId, required this.orderEditRequest});

  @override
  List<Object> get props => [orderId, orderEditRequest];
}




