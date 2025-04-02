import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/customer_management/repository/customer_repository.dart';

import '../model/get_customer.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerRepository customerRepository;
  int currentPage = 0;
  bool isFetching = false;

  CustomerBloc({required this.customerRepository})
      : super(const CustomerAddInitialState()) {
    on<AddNewCustomer>((event, emit) async {
      try {
        final customerAddResponse =
            await customerRepository.addCustomer(event.addCustomerRequest);

        print("Data in Bloc: ${customerAddResponse.toString()}");
        emit(CustomerAddLoadedState(customerAddResponse: customerAddResponse));
      } catch (e) {
        emit(CustomerAddErrorState(error: e.toString()));
      }
    });

    on<GetCustomer>(_onGetCustomerList);
    on<GetCustomerFetchNextPage>(_onGetCustomerListFetchNextPage);

    on<DeleteCustomer>((event, emit) async {
      try {
        final deleteCustomerResponse =
            await customerRepository.deleteCustomer(event.customerId);
        emit(CustomerDeleteLoadedState(
            deleteCustomerResponse: deleteCustomerResponse));
      } catch (e) {
        emit(CustomerDeleteErrorState(error: e.toString()));
      }
    });

    on<GetCustomerList>((event,emit) async {
      try {
        final customerList =
        await customerRepository.getCustomer(0);
        emit(CustomerListLoadedState(getCustomerListResponse: customerList));
      } catch (e) {
        emit(CustomerListErrorState(error: e.toString()));
      }
    });

    on<EditCustomer>((event, emit) async {
      try {
        final editCustomerResponse = await customerRepository.editCustomer(
            event.customerId, event.addCustomerRequest);
        emit(CustomerEditLoadedState(
            editCustomerResponse: editCustomerResponse));
      } catch (e) {
        emit(CustomerEditErrorState(error: e.toString()));
      }
    });

  }

  Future<void> _onGetCustomerList(
      GetCustomer event, Emitter<CustomerState> emit) async {
    try {
      emit(const CustomerGetInitialState());
      currentPage = 0;
      final pendingJobResponse =
          await customerRepository.getCustomer(currentPage);
      if (pendingJobResponse != null && pendingJobResponse.customers != null) {
        if (pendingJobResponse.customers!.length == 1) {
          emit(CustomerGetLoadedState(
            customerGetResponse: pendingJobResponse,
            hasReachedMax: true,
          ));
        } else {
          emit(CustomerGetLoadedState(
            customerGetResponse: pendingJobResponse,
            hasReachedMax: pendingJobResponse.customers!.isEmpty,
          ));
        }
      } else {
        emit(const CustomerGetErrorState(error: "No data found"));
      }
    } catch (e) {
      emit(CustomerGetErrorState(error: e.toString()));
    }
  }

  Future<void> _onGetCustomerListFetchNextPage(
      GetCustomerFetchNextPage event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is CustomerGetLoadedState &&
        !currentState.hasReachedMax &&
        !isFetching) {
      try {
        isFetching = true;
        final nextPage = currentPage + 1;
        final pendingJobResponse =
            await customerRepository.getCustomer(nextPage);

        if (pendingJobResponse != null &&
            pendingJobResponse.customers != null) {
          final newPendingJobData =
              (currentState.customerGetResponse?.customers)! +
                  pendingJobResponse.customers!;
          emit(CustomerGetLoadedState(
            hasReachedMax: pendingJobResponse.customers!.isEmpty,
            customerGetResponse:
                GetCustomerResponse(customers: newPendingJobData),
          ));
          currentPage = nextPage;
        } else {
          emit(currentState.copyWith(hasReachedMax: true));
        }
      } catch (e) {
        emit(CustomerGetErrorState(error: e.toString()));
      } finally {
        isFetching = false;
      }
    }
  }
}
