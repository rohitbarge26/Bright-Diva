import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_event.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_state.dart';

import '../repository/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderRepository orderRepository;
  int currentPage = 0;
  bool isFetching = false;

  OrderBloc({required this.orderRepository})
      : super(const OrderAddInitialState()) {
    on<AddOrder>((event, emit) async {
      try {
        final orderAddResponse =
            await orderRepository.addOrder(event.addOrderRequest);
        emit(OrderAddLoadedState(addOrderResponse: orderAddResponse));
      } catch (e) {
        emit(OrderAddErrorState(error: e.toString()));
      }
    });

    on<GetOrderList>((event, emit) async {
      try {
        final orderAddResponse =
            await orderRepository.getOrderList(currentPage);
        emit(OrderListLoadedState(getOrderResponse: orderAddResponse));
      } catch (e) {
        emit(OrderListErrorState(error: e.toString()));
      }
    });

    on<GetOrderDetails>((event, emit) async {
      try {
        final orderByIdResponse =
            await orderRepository.getOrderDetails(event.orderId);
        emit(OrderDetailsLoadedState(getOrderByIdResponse: orderByIdResponse));
      } catch (e) {
        emit(OrderDetailsErrorState(error: e.toString()));
      }
    });

    on<DeleteOrder>((event, emit) async {
      try {
        final deleteCustomerResponse =
            await orderRepository.deleteOrder(event.orderId);
        emit(OrderDeleteLoadedState(
            deleteCustomerResponse: deleteCustomerResponse));
      } catch (e) {
        emit(OrderDeleteErrorState(error: e.toString()));
      }
    });

    on<EditOrder>((event, emit) async {
      try {
        final editCustomerResponse = await orderRepository.editOrder(
            event.orderId, event.orderEditRequest);
        emit(OrderEditLoadedState(editOrderResponse: editCustomerResponse));
      } catch (e) {
        emit(OrderEditErrorState(error: e.toString()));
      }
    });
  }
}
