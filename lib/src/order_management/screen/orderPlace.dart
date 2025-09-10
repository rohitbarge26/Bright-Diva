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
import '../../../utils/validation.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/edit_order_alert.dart';
import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../../settings/bloc/currency/currency_bloc.dart';
import '../../settings/bloc/currency/currency_event.dart';
import '../../settings/bloc/currency/currency_state.dart';
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
  final TextEditingController _deliveredByController = TextEditingController();

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
  num? _selectedRemainingAmount;
  String errorAmount = '';
  String errorDeliveredBy = '';
  OrderGetResponse? ordersListResponse;
  String? userRole;
  double hkdToMop = 1.03; // Initial value for HKD to MOP
  double hkdToCny = 0.92; // Initial value for HKD to CNY
  String currency_id = "";
  String _conversionText = '';
  double _amountInHKD = 0.0;

  void _updateConversionText() {
    if (_selectedCurrency == 'HKD') {
      setState(() => _conversionText = '');
    } else {
      final convertedAmount = _convertFromHKD(_amountInHKD, _selectedCurrency!);
      setState(() {
        _conversionText = '≈ ${convertedAmount.toStringAsFixed(2)} '
            '$_selectedCurrency (${_amountInHKD.toStringAsFixed(2)} HKD)';
      });
    }
  }

  double _convertToHKD(double amount, String fromCurrency) {
    if (fromCurrency == 'HKD') return amount;
    final rate = fromCurrency == 'MOP' ? hkdToMop : hkdToCny;
    return amount / rate;
  }

  double _convertFromHKD(double amountInHKD, String toCurrency) {
    if (toCurrency == 'HKD') return amountInHKD;
    final rate = toCurrency == 'MOP' ? hkdToMop : hkdToCny;
    return amountInHKD * rate;
  }

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
    if (selectedInvoice.remainingAmount != null) {
      try {
        _deliveredValueController.text =
            selectedInvoice.remainingAmount!.toStringAsFixed(2);
        _selectedRemainingAmount = selectedInvoice.remainingAmount;
      } catch (e) {
        _deliveredValueController.text = '0';
        _selectedRemainingAmount = 0;
        print('Error handling remainingAmount: $e');
      }
    } else {
      _deliveredValueController.text = '0';
      _selectedRemainingAmount = 0;
    }
  }

  bool _validateFields() {
    bool isValid = true;

    if (_selectedRemainingAmount == 0) {
      print('Cash Receipt already generated');
      setState(() {
        errorAmount = 'Cash Receipt already generated'; // Set error message
      });
      isValid = false;
    }

    // Validate Amount
    if (_deliveredByController.text.isEmpty) {
      print('Please enter a valid pickup by');
      setState(() {
        errorDeliveredBy =
            AppLocalizations.of(context)!.error_deliveredByRequired;
      });
      isValid = false;
    }

    print('_validateFields amount in HKD: $_amountInHKD');
    print(
        '_validateFields amountController: ${_deliveredValueController.text}');
    print('Remaining Amount: $_selectedRemainingAmount');

    final enteredAmountHKD = _deliveredValueController.text;

    try {
      final enteredAmount = double.parse(enteredAmountHKD);
      print('Entered Amount: $enteredAmount');
      // Validate against selected amount
      if (enteredAmount <= 0) {
        print('Please enter a valid amount');
        setState(() {
          errorAmount = 'Please enter a valid amount';
        });
        isValid = false;
      }
      if (enteredAmount > _selectedRemainingAmount!) {
        print(
            'Amount cannot exceed ${_selectedRemainingAmount!.toStringAsFixed(2)} HKD');
        setState(() {
          errorAmount =
              'Amount cannot exceed ${_selectedRemainingAmount!.toStringAsFixed(2)} HKD';
        });
        isValid = false;
      }
    } catch (e) {
      setState(() {
        print('catch');
        errorAmount = 'Please enter a valid number';
      });
      isValid = false;
    }

    return isValid;
  }

  // Submit form
  void _submitForm() {
    if (!_validateFields()) {
      return; // Stop submission if validation fails
    }else{
      setState(() {
        errorAmount = '';
      });
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
              amountOfDelivery: num.tryParse(_deliveredValueController.text),
              deliveredBy: _deliveredByController.text,
              partialDelivery: _isPartialDelivery,
              currency: _selectedCurrency,
              deliveredUnits: 0,
              customerId: _selectedCustomerId,
              orderNumber: orderNumber)));
      _clearForm();
      // Show success message
    }
  }

  String _formatAmount(String? amount) {
    if (amount == null || amount == 'N/A') return 'N/A';

    try {
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null) return amount;

      return parsedAmount.toStringAsFixed(2);
    } catch (e) {
      return amount;
    }
  }

  void _formatAmountInput(String value) {
    if (value.isEmpty) return;

    // Remove any non-numeric characters except decimal point
    String cleanedValue = value.replaceAll(RegExp(r'[^0-9\.]'), '');

    // Check for multiple decimal points
    if (cleanedValue.split('.').length > 2) {
      cleanedValue = cleanedValue.substring(0, cleanedValue.length - 1);
    }

    // Limit to 2 decimal places
    if (cleanedValue.contains('.')) {
      List<String> parts = cleanedValue.split('.');
      if (parts[1].length > 2) {
        cleanedValue = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }

    // Update controller if value changed
    if (cleanedValue != value) {
      _deliveredValueController.text = cleanedValue;
      _deliveredValueController.selection =
          TextSelection.collapsed(offset: cleanedValue.length);
    }
  }

  void _clearForm() {
    _deliveredUnitsController.clear();
    _deliveredValueController.clear();
  }

  void _showEditOrderDialog(BuildContext context, Orders order) {
    double amountInHkd = double.parse(order.amountInHkd!);
    _deliveredValueController.text = amountInHkd.toStringAsFixed(0);
    _deliveredUnitsController.text = order.deliveredUnits!.toString();
    _deliveredByController.text = order.deliveredBy ?? '';

    // Get the remaining amount from the invoice data
    double remainingAmount = 0.0;
    if (BlocProvider.of<InvoiceBloc>(context).state is InvoiceGetLoadedState) {
      final invoiceState =
          BlocProvider.of<InvoiceBloc>(context).state as InvoiceGetLoadedState;
      final invoice =
          invoiceState.getInvoiceDetailsResponse?.invoices?.firstWhere(
        (inv) => inv.invoiceNumber == order.invoiceNumber,
        orElse: () => Invoices(remainingAmount: 0),
      );
      remainingAmount = invoice?.remainingAmount?.toDouble() ?? 0.0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return EditOrderDialog(
          invoiceNumber: order.invoiceNumber!,
          companyName: order.customer!.companyName!,
          initialPartialDelivery: _isPartialEditDelivery,
          initialCurrency: _selectedCurrency!,
          remainingAmount: remainingAmount,
          // Pass the remaining amount
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
          valueHkdToMop: hkdToMop,
          valueHkdToCny: hkdToCny,
          callCancel: (BuildContext context) {
            Navigator.pop(context);
          },
          callSave: (BuildContext context, int units, String value) {
            print('callSave: $value');
            Navigator.pop(context);
            context.read<OrderBloc>().add(EditOrder(
                  orderId: order.id!,
                  orderEditRequest: OrderEditRequest(
                    amountOfDelivery: num.tryParse(value),
                    partialDelivery: _isPartialEditDelivery,
                    currency: _selectedCurrency,
                    deliveredUnits: units,
                    deliveredBy: _deliveredByController.text,
                  ),
                ));
          },
          deliveredByController: _deliveredByController,
        );
      },
    );
  }

  void _deleteOrder(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          // 确认删除
          content: Text(AppLocalizations.of(context)!.areYouSureDelete),
          // 您确定要删除吗？
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.no), // 否
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes), // 是
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                BlocProvider.of<OrderBloc>(context)
                    .add(DeleteOrder(orderId: id));
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle print invoice action
  void _printInvoice(String orderNumber) {
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
    BlocProvider.of<CurrencyBloc>(context).add(const GetCurrencyUpdate());
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
                  alertLogoPath: 'assets/icons/error_icon.svg',
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
                  alertLogoPath: 'assets/icons/error_icon.svg',
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
                  alertLogoPath: 'assets/icons/error_icon.svg',
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
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.successMessageDelete)),
            );
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ErrorAlertDialog(
                    alertLogoPath: 'assets/icons/error_icon.svg',
                    status: AppLocalizations.of(context)!.unableToProcess,
                    statusInfo:
                        AppLocalizations.of(context)!.somethingWentWrong,
                    buttonText: AppLocalizations.of(context)!.btnOkay,
                    onPress: () {
                      Navigator.of(context).pop();
                    }));
          }
        } else if (state is OrderEditLoadedState) {
          int? code = state.editOrderResponse!.statusCode;
          print('Code : $code');
          if (code == SUCCESS) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)!.msgUpdateOrder)),
            );
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ErrorAlertDialog(
                    alertLogoPath: 'assets/icons/error_icon.svg',
                    status: AppLocalizations.of(context)!.unableToProcess,
                    statusInfo:
                        AppLocalizations.of(context)!.somethingWentWrong,
                    buttonText: AppLocalizations.of(context)!.btnOkay,
                    onPress: () {
                      Navigator.of(context).pop();
                    }));
          }
        }
      },
      child: BlocListener<CurrencyBloc, CurrencyState>(
        listener: (context, state) {
          if (state is GetCurrencyLoadedState) {
            int code = state.getCurrencyResponse?.statusCode ?? 0;
            print('Code : $code');
            if (code == SUCCESS) {
              setState(() {
                currency_id = state.getCurrencyResponse!.currency![0].id!;
                hkdToMop = state.getCurrencyResponse!.currency![0].hkdToMop!;
                hkdToCny = state.getCurrencyResponse!.currency![0].hkdToCny!;
              });
            }
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
                                    print("Search InvoiceGetInitialState List");
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (state is InvoiceGetLoadedState) {
                                    List<Invoices> invoices = state
                                            .getInvoiceDetailsResponse
                                            ?.invoices ??
                                        [];

                                    return DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSearchBox: true,
                                        searchFieldProps: const TextFieldProps(
                                          decoration: InputDecoration(
                                            labelText: "Search Invoice",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        // Disable selection of fulfilled invoices
                                        disabledItemFn: (String item) =>
                                            item.contains("(Fulfilled)"),
                                      ),
                                      selectedItem: _selectedInvoiceNumber,
                                      items: invoices.map((invoice) {
                                        // Append (Fulfilled) if remaining amount is 0 or negative
                                        final isFulfilled =
                                            (invoice.remainingAmount ?? 1) <= 0;
                                        final invoiceNumber =
                                            invoice.invoiceNumber ??
                                                AppLocalizations.of(context)!
                                                    .error_invoiceRequired;
                                        return isFulfilled
                                            ? "$invoiceNumber (Fulfilled)"
                                            : invoiceNumber;
                                      }).toList(),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .orderInvoiceNumber,
                                          border: const OutlineInputBorder(),
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
                                    print('Else Condition');
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
                                  enabled:
                                      false, // Disabled as it's auto-filled
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
                              // Delivered By Field
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE5E5E5), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextFormField(
                                  controller: _deliveredByController,
                                  decoration: InputDecoration(
                                    labelText:
                                        '${AppLocalizations.of(context)!.deliveredBy} *',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    prefixIcon: const Icon(Icons.person,
                                        size: 20, color: Colors.grey),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      setState(() {
                                        errorDeliveredBy =
                                        Validator.stringValidate(value)
                                            ? ''
                                            : AppLocalizations.of(
                                            context)!
                                            .error_deliveredByRequired;
                                      });
                                    });
                                  },
                                ),
                              ),
                              Visibility(
                                visible: errorDeliveredBy.isNotEmpty,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, top: 12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/error_icon.svg',
                                        height: 12.67,
                                        width: 12.67,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: CustomText(
                                          text: errorDeliveredBy,
                                          fontSize: 12,
                                          desiredLineHeight: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFF85A5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                        if (value != null &&
                                            value != _selectedCurrency) {
                                          setState(() {
                                            // Convert current amount to HKD first
                                            final currentAmount =
                                                double.tryParse(
                                                        _deliveredValueController
                                                            .text) ??
                                                    0;
                                            _amountInHKD = _convertToHKD(
                                                currentAmount,
                                                _selectedCurrency!);

                                            // Update currency and convert to new currency
                                            _selectedCurrency = value;
                                            final newAmount = _convertFromHKD(
                                                _amountInHKD, value);
                                            _deliveredValueController.text =
                                                newAmount.toStringAsFixed(2);
                                            print('New amount: $newAmount');
                                            // Update conversion text
                                            _updateConversionText();
                                          });
                                        }
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
                                        border: const OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      enabled: _isPartialDelivery,
                                      onChanged: (value) {
                                        // Format the input to allow only numbers and up to 2 decimal places
                                        _formatAmountInput(value);

                                        final amount =
                                            double.tryParse(value) ?? 0;
                                        setState(() {
                                          _amountInHKD = _convertToHKD(
                                              amount, _selectedCurrency!);
                                          _updateConversionText();
                                        });
                                      },
                                      validator: (value) {
                                        if (_isPartialDelivery &&
                                            (value == null || value.isEmpty)) {
                                          return AppLocalizations.of(context)!
                                              .error_deliveredValueRequired;
                                        }

                                        if (_selectedRemainingAmount != null &&
                                            _amountInHKD >
                                                _selectedRemainingAmount!) {
                                          return 'Amount cannot exceed ${_selectedRemainingAmount!.toStringAsFixed(2)} HKD';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: errorAmount.isNotEmpty,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, top: 12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/error_icon.svg',
                                        height: 12.67,
                                        width: 12.67,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: CustomText(
                                          text: errorAmount,
                                          fontSize: 12,
                                          desiredLineHeight: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFF85A5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (_conversionText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _conversionText,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              // Submit Button
                              ElevatedButton(
                                onPressed: _submitForm,
                                child:
                                    Text(AppLocalizations.of(context)!.submit),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
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
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final order = sortedList[index];
        // Format date and time
        String formattedDate = 'N/A';
        String formattedTime = '';
        if (order.updatedAt != null) {
          try {
            DateTime dateTime = DateTime.parse(order.updatedAt!);
            formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
            formattedTime = DateFormat('hh:mm a').format(dateTime);
          } catch (e) {
            formattedDate = 'Invalid Date';
          }
        }

        // Determine statuses
        final paymentStatus =
            order.partialDelivery == true ? 'Partial' : 'Full';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Add tap functionality if needed
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Number Header
                    Row(
                      children: [
                        // Order Number
                        Expanded(
                          child: Text(
                            order.orderNumber ?? 'ORD-0000',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A5B92),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        // Status Badges
                        Row(
                          children: [
                            _buildStatusBadge(
                              paymentStatus,
                              order.partialDelivery == true
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(width: 6),
                            BlocBuilder<InvoiceBloc, InvoiceState>(
                              builder: (context, state) {
                                if (state is InvoiceGetLoadedState) {
                                  return _buildInvoiceStatus(
                                      order.invoiceNumber!,
                                      state.getInvoiceDetailsResponse
                                              ?.invoices ??
                                          []);
                                }
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount Column
                        Expanded(
                          child: _buildDetailRow(
                            icon: Icons.business,
                            label: 'Customer',
                            value: order.customer?.companyName ?? 'N/A',
                          ),
                        ),

                        // Date Column
                        Expanded(
                          child: _buildDetailColumn(
                            icon: Icons.account_box,
                            label: 'Delivered By',
                            value: order.deliveredBy!,
                          ),
                        ),
                      ],
                    ),

                    // Order Details
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.receipt,
                      label: 'Invoice',
                      value: order.invoiceNumber ?? 'N/A',
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount Column
                        Expanded(
                          child: _buildDetailColumn(
                            icon: Icons.attach_money,
                            label: 'Amount (HKD)',
                            value: _formatAmount(order.amountInHkd),
                          ),
                        ),

                        // Date Column
                        Expanded(
                          child: _buildDetailColumn(
                            icon: Icons.calendar_today,
                            label: 'Updated',
                            value:
                                formattedDate != 'N/A' ? formattedDate : 'N/A',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Divider
                    const Divider(height: 1, color: Color(0xFFE5E5E5)),
                    const SizedBox(height: 12),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Print Button
                        _buildActionButton(
                          icon: Icons.print,
                          color: Colors.green,
                          tooltip: 'Print Order',
                          onPressed: () => _printInvoice(order.id!),
                        ),

                        if (userRole == 'Admin') ...[
                          const SizedBox(width: 8),
                          // Edit Button
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.orange,
                            tooltip: 'Edit Order',
                            onPressed: () =>
                                _showEditOrderDialog(context, order),
                          ),

                          const SizedBox(width: 8),
                          // Delete Button
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            tooltip: 'Delete Order',
                            onPressed: () => _deleteOrder(order.id!),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceStatus(String invoiceNumber, List<Invoices> invoices) {
    // Find the invoice that matches this cash receipt
    final invoice = invoices.firstWhere(
      (inv) => inv.invoiceNumber == invoiceNumber,
      orElse: () => Invoices(remainingAmount: 1), // Default to incomplete
    );

    final isCompleted =
        invoice.remainingAmount != null && invoice.remainingAmount! <= 0;

    return _buildStatusBadge(
      isCompleted ? 'Complete' : 'Incomplete',
      isCompleted ? Colors.green : Colors.orange,
    );
  }

  // Helper method for status badges
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

// Helper method for detail columns (for date and amount)
  Widget _buildDetailColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF171717),
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

// Helper method for detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF171717),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

// Helper method for action buttons
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}
