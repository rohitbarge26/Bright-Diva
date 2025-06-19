import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frequent_flow/src/order_management/invoice_bloc/invoice_bloc.dart';
import 'package:frequent_flow/src/order_management/invoice_bloc/invoice_state.dart';
import 'package:frequent_flow/src/order_management/model/add_order_request.dart';
import 'package:frequent_flow/src/order_management/model/edit_order_request.dart';
import 'package:frequent_flow/src/order_management/model/get_order_by_id.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_bloc.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_event.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_state.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../../utils/prefs.dart';
import '../../../utils/print_order.dart';
import '../../../utils/response_status.dart';
import '../../../utils/route.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/edit_order_alert.dart';
import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../invoice_bloc/invoice_event.dart';
import '../model/get_invoice_response.dart';
import '../model/get_order_response.dart';

class OrderPlace extends StatefulWidget {
  const OrderPlace({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<OrderPlace> createState() => _OrderPlaceState();
}

class _OrderPlaceState extends State<OrderPlace> {
  final _formOrderKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _deliveredUnitsController =
      TextEditingController();
  final TextEditingController _deliveredValueController =
      TextEditingController();

  // State variables
  String? _selectedInvoiceNumber;
  String? _selectedCurrency = 'HKD'; // Default value
  final List<String> _currencies = ['HKD', 'MOP', 'CNY'];
  bool _isPartialDelivery = false;
  bool _isPartialEditDelivery = false;
  bool _isViewOrderVisible = false; // State variable for visibility
  bool isSubmitting = false;
  bool isOrderList = false;
  String? _selectedCustomerId;
  int? _selectedInvoiceUnit;
  int? _selectedRemainingAmount;
  String errorAmount = '';
  OrderGetResponse? ordersListResponse;
  String? userRole;

  // Fetch customer name based on invoice number
  void _fetchCustomerName(String invoiceNumber, List<Invoices> invoices) {
    // Find the selected invoice from the list
    Invoices? selectedInvoice = invoices.firstWhere(
      (invoice) => invoice.invoiceNumber == invoiceNumber,
      orElse: () => Invoices(), // Provide a default value to avoid errors
    );

    if (selectedInvoice.customer != null) {
      _customerNameController.text = selectedInvoice.customer!.companyName ??
          selectedInvoice.customer!.contactPersonName ??
          'Unknown Customer';
      _selectedCustomerId = selectedInvoice.customerId;
      _selectedInvoiceUnit = selectedInvoice.totalUnits;
      //_deliveredUnitsController.text = _selectedInvoiceUnit.toString();
    } else {
      _customerNameController.text = 'Unknown Customer';
    }
    if (selectedInvoice.amountInHkd != null) {
      try {
        //double amountInHkd = double.parse(selectedInvoice.amountInHkd!);
        _deliveredValueController.text = selectedInvoice.remainingAmount.toString();//amountInHkd.toStringAsFixed(0);
        _selectedRemainingAmount = selectedInvoice.remainingAmount;
      } catch (e) {
        _deliveredValueController.text = '0';
        print('Error parsing amountInHkd: $e');
      }
    } else {
      _deliveredValueController.text = '0'; // Handle null case
    }
  }
// Function to validate the amount
  bool _validateAmount() {
    if (_selectedRemainingAmount == 0) {
      setState(() {
        errorAmount = 'Order already generated'; // Set error message
      });
      return false; // Validation failed
    }
    // Get the entered amount from controller and parse to double
    final enteredAmount = double.tryParse(_deliveredValueController.text) ?? 0;
    // Validate against selected amount
    if (enteredAmount <= 0) {
      setState(() {
        errorAmount = 'Please enter a valid amount';
      });
      return false;
    }

    if (enteredAmount > _selectedRemainingAmount!) {
      setState(() {
        errorAmount = 'Amount cannot exceed $_selectedRemainingAmount';
      });
      return false;
    }
    setState(() {
      errorAmount = ''; // Clear error message if validation passes
    });
    return true; // Validation passed
  }

  // Submit form
  void _submitForm() {
    if (!_validateAmount()) {
      return; // Stop submission if validation fails
    }

    if (_formOrderKey.currentState!.validate()) {
      print('Form submitted successfully');
      // Add the new customer to the list
      setState(() {
        isSubmitting = true;
      });
      final orderNumber = 'ORD-$_selectedInvoiceNumber';
      FocusScope.of(context).requestFocus(FocusNode());
      BlocProvider.of<OrderBloc>(context).add(AddOrder(
          addOrderRequest: OrderAddRequest(
              invoiceNumber: _selectedInvoiceNumber,
              amountOfDelivery: int.parse(_deliveredValueController.text),
              partialDelivery: _isPartialDelivery,
              currency: _selectedCurrency,
              deliveredUnits: 0,
              customerId: _selectedCustomerId,
              orderNumber: orderNumber)));
      _clearForm();
      // Show success message
    }
  }

  void _clearForm() {
    _deliveredUnitsController.clear();
    _deliveredValueController.clear();
  }

  // Function to handle view action
  void _viewOrder(String orderNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return Container();
      },
    );
  }

  void _showEditOrderDialog(BuildContext context, Orders order) {
    double amountInHkd = double.parse(order.amountInHkd!);
    _deliveredValueController.text = amountInHkd.toStringAsFixed(0);
    _deliveredUnitsController.text = order.deliveredUnits!.toString();

    showDialog(
      context: context,
      builder: (context) {
        return EditOrderDialog(
          invoiceNumber: order.invoiceNumber!,
          companyName: order.customer!.companyName!,
          initialPartialDelivery: _isPartialEditDelivery,
          initialCurrency: _selectedCurrency!,
          onPartialDeliveryChanged: (value) {
            setState(() {
              _isPartialEditDelivery = value;
            });
          },
          onCurrencyChanged: (value) {
            setState(() {
              _selectedCurrency = value;
            });
          },
          deliveredUnitsController: _deliveredUnitsController,
          deliveredValueController: _deliveredValueController,
          callCancel: (BuildContext context) {
            Navigator.pop(context);
          },
          callSave: (BuildContext context, int units, String value) {
            Navigator.pop(context);
            context.read<OrderBloc>().add(EditOrder(
                orderId: order.id!,
                orderEditRequest: OrderEditRequest(
                    amountOfDelivery: int.parse(value),
                    partialDelivery: _isPartialEditDelivery,
                    currency: _selectedCurrency,
                    deliveredUnits: units)));
          },
        );
      },
    );
  }

  // Function to handle delete action
  void _deleteOrder(String id) {
    BlocProvider.of<OrderBloc>(context).add(DeleteOrder(orderId: id));
  }

  // Function to handle print invoice action
  void _printInvoice(String orderNumber) {
    // Implement print functionality (e.g., generate PDF)
    BlocProvider.of<OrderBloc>(context, listen: false)
        .add(GetOrderDetails(orderId: orderNumber));
  }

  @override
  void initState() {
    super.initState();
    print("Get Invoice list");
    BlocProvider.of<InvoiceBloc>(context, listen: false)
        .add(const GetInvoiceDetails());
    userRole = Prefs.getUser('user')?.role!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) async {
        if (state is OrderAddInitialState) {
          const CircularProgressIndicator();
        } else if (state is OrderAddLoadedState) {
          int code = state.addOrderResponse?.statusCode ?? 0;
          print('Code : $code');
          setState(() {
            isSubmitting = false;
          });
          if (code == SUCCESS_CREATE) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.successfully,
                  AppLocalizations.of(context)!.successMessageOrder,
                  AppLocalizations.of(context)!.btnContinue,
                  ROUT_HOME,
                  false,
                  0),
            );
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ErrorAlertDialog(
                  alertLogoPath: 'assets/icon/error_icon.svg',
                  status: AppLocalizations.of(context)!.unableToProcess,
                  statusInfo: AppLocalizations.of(context)!.somethingWentWrong,
                  buttonText: AppLocalizations.of(context)!.btnOkay,
                  onPress: () {
                    Navigator.of(context).pop();
                  }),
            );
          }
        } else if (state is OrderListLoadedState) {
          int code = state.getOrderResponse?.statusCode ?? 0;
          print('Code : $code');
          if (code == SUCCESS) {
            if (state.getOrderResponse?.total == 0) {
              setState(() {
                isOrderList = false;
              });
            } else {
              setState(() {
                isOrderList = true;
                ordersListResponse = state.getOrderResponse;
                _isViewOrderVisible = !_isViewOrderVisible; // Toggle visibility
                //isHasReachMax = state.hasReachedMax;
              });
            }
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ErrorAlertDialog(
                  alertLogoPath: 'assets/icon/error_icon.svg',
                  status: AppLocalizations.of(context)!.unableToProcess,
                  statusInfo: AppLocalizations.of(context)!.somethingWentWrong,
                  buttonText: AppLocalizations.of(context)!.btnOkay,
                  onPress: () {
                    Navigator.of(context).pop();
                  }),
            );
          }
        } else if (state is OrderDetailsLoadedState) {
          int code = state.getOrderByIdResponse?.statusCode ?? 0;
          print('Code : $code');
          if (code == SUCCESS) {
            Order? orders = state.getOrderByIdResponse?.order;
            final pdfFile = await PdfService.generateOrderPdf(orders!);
            print('PDF saved at: ${pdfFile.path}');
            final result = await OpenFile.open(pdfFile.path);
            if (result.type != ResultType.done) {
              print("Failed to open the file: ${result.message}");
            }
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ErrorAlertDialog(
                  alertLogoPath: 'assets/icon/error_icon.svg',
                  status: AppLocalizations.of(context)!.unableToProcess,
                  statusInfo: AppLocalizations.of(context)!.somethingWentWrong,
                  buttonText: AppLocalizations.of(context)!.btnOkay,
                  onPress: () {
                    Navigator.of(context).pop();
                  }),
            );
          }
        } else if (state is OrderDeleteLoadedState) {
          int? code = state.deleteCustomerResponse!.statusCode;
          if (code == SUCCESS) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.successfully,
                  AppLocalizations.of(context)!.successMessageDelete,
                  AppLocalizations.of(context)!.btnContinue,
                  ROUT_HOME,
                  false,
                  0),
            );
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ErrorAlertDialog(
                    alertLogoPath: 'assets/icon/error_icon.svg',
                    status: AppLocalizations.of(context)!.unableToProcess,
                    statusInfo:
                    AppLocalizations.of(context)!.somethingWentWrong,
                    buttonText: AppLocalizations.of(context)!.btnOkay,
                    onPress: () {
                      Navigator.of(context).pop();
                    }));
          }
        }else if (state is OrderEditLoadedState) {
          int? code = state.editOrderResponse!.statusCode;
          print('Code : $code');
          if (code == SUCCESS) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)!.msgUpdateOrder)),
            );
          } else {}
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 68, right: 16.0, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        widget.onBackTap();
                      },
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow_icon.svg',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: AppLocalizations.of(context)!.manageOrder,
                      fontSize: 20,
                      desiredLineHeight: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.02,
                      color: const Color(0xFF171717),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print("Get Customer list");
                      BlocProvider.of<OrderBloc>(context, listen: false)
                          .add(const GetOrderList());
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF85A5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.viewOrder,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: _isViewOrderVisible
                    ? isOrderList
                        ? _buildOrderList()
                        : const Center(
                            child:
                                CircularProgressIndicator()) // Show View Order table
                    : Form(
                        key: _formOrderKey,
                        child: ListView(
                          children: [
                            // Invoice Number (Searchable Dropdown)

                            BlocBuilder<InvoiceBloc, InvoiceState>(
                              builder: (context, state) {
                                if (state is InvoiceGetInitialState) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is InvoiceGetLoadedState) {
                                  List<Invoices> invoices = state
                                          .getInvoiceDetailsResponse
                                          ?.invoices ??
                                      [];

                                  return DropdownSearch<String>(
                                    popupProps: const PopupProps.menu(
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                          labelText: "Search Invoice",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    selectedItem: _selectedInvoiceNumber,
                                    items: invoices
                                        .map((invoice) =>
                                            invoice.invoiceNumber ?? "")
                                        .toList(),
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .orderInvoiceNumber,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedInvoiceNumber = value;
                                        _fetchCustomerName(value!, invoices);
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .errorOrderInvoiceNumber;
                                      }
                                      return null;
                                    },
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),

                            const SizedBox(height: 16),
                            // Customer Name (Fetched automatically)
                            TextFormField(
                              controller: _customerNameController,
                              decoration: InputDecoration(
                                labelText:
                                    '${AppLocalizations.of(context)!.customerName} *',
                                border: const OutlineInputBorder(),
                                enabled: false, // Disabled as it's auto-filled
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .error_customerNameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Partial Delivery (Radio Buttons)
                            Text(
                              '${AppLocalizations.of(context)!.partialDelivery} *',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: _isPartialDelivery,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPartialDelivery = value!;
                                    });
                                  },
                                ),
                                Text(AppLocalizations.of(context)!.yes),
                                const SizedBox(width: 16),
                                Radio<bool>(
                                  value: false,
                                  groupValue: _isPartialDelivery,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPartialDelivery = value!;
                                    });
                                  },
                                ),
                                Text(AppLocalizations.of(context)!.no),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Delivered Units (Input Field)
                            /*TextFormField(
                              controller: _deliveredUnitsController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .deliveredUnits,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: _isPartialDelivery,
                              // Enable only if Partial Delivery is Yes
                              validator: (value) {
                                if (_isPartialDelivery &&
                                    (value == null || value.isEmpty)) {
                                  return AppLocalizations.of(context)!
                                      .error_deliveredUnitsRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),*/

                            // Delivered Value (Currency Dropdown + Input Field)
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCurrency,
                                    hint: Text(AppLocalizations.of(context)!
                                        .select_currency),
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .currency,
                                      border: const OutlineInputBorder(),
                                    ),
                                    items:
                                        ['HKD', 'MOP', 'CNY'].map((currency) {
                                      return DropdownMenuItem(
                                        value: currency,
                                        child: Text(currency),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCurrency = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _deliveredValueController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .deliveredValue,
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    enabled: _isPartialDelivery,
                                    // Enable only if Partial Delivery is Yes
                                    validator: (value) {
                                      if (_isPartialDelivery &&
                                          (value == null || value.isEmpty)) {
                                        return AppLocalizations.of(context)!
                                            .error_deliveredValueRequired;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _submitForm,
                              child: Text(AppLocalizations.of(context)!.submit),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    final sortedList = ordersListResponse!.orders?.toList() ?? [];
    sortedList.sort((a, b) {
      final dateA = DateTime.parse(a.updatedAt!);
      final dateB = DateTime.parse(b.updatedAt!);
      return dateB.compareTo(dateA); // For newest first (descending)
      // Use dateA.compareTo(dateB) for oldest first (ascending)
    });
    return ListView.builder(
      itemCount: sortedList.length,
      // Assuming `order` is a list
      itemBuilder: (context, index) {
        final order = sortedList[index];
        String dateString = order.updatedAt!;
        DateTime dateTime = DateTime.parse(dateString);
        // Extract date and time
        String date = DateFormat('yyyy-MM-dd').format(dateTime);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ListTile(
            title: Text('${order.orderNumber}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customer?.companyName ?? "N/A"),
                Text('${order.invoiceNumber}'),
                Text(date),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (userRole == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditOrderDialog(context, order),
                  ),
                if (userRole == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(order.id!),
                  ),
                IconButton(
                  icon: Icon(Icons.print, color: Colors.green),
                  onPressed: () => _printInvoice(order.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
