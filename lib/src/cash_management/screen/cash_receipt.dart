import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/src/cash_management/bloc/cash_bloc.dart';
import 'package:frequent_flow/src/cash_management/bloc/cash_state.dart';
import 'package:frequent_flow/src/cash_management/model/add_cash_receipt_request.dart';
import 'package:frequent_flow/src/cash_management/model/edit_cash_receipt_request.dart';
import 'package:frequent_flow/src/cash_management/model/get_cash_receipt_by_id.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_bloc.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_event.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/app_functions.dart';
import '../../../utils/prefs.dart';
import '../../../utils/print_order.dart';
import '../../../utils/response_status.dart';
import '../../../utils/route.dart';
import '../../../utils/validation.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/edit_cash_receipt_alert.dart';
import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../../customer_management/model/get_customer.dart';
import '../../order_management/invoice_bloc/invoice_bloc.dart';
import '../../order_management/invoice_bloc/invoice_event.dart';
import '../../order_management/invoice_bloc/invoice_state.dart';
import '../../order_management/model/get_invoice_response.dart';
import '../../order_management/screen/invoice.dart';
import '../bloc/cash_event.dart';
import '../model/get_cash_receipt_response.dart';

class CashReceipt extends StatefulWidget {
  const CashReceipt({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<CashReceipt> createState() => _CashReceiptState();
}

class _CashReceiptState extends State<CashReceipt> {
  final _formCashKey = GlobalKey<FormState>();
  TextEditingController receiptNumberController = TextEditingController();
  TextEditingController invoiceNumberController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pickupByController = TextEditingController();

  String errorReceiptNumber = '';
  String errorInvoiceNumber = '';
  String errorCustomer = '';
  String errorAmount = '';
  String errorPickupBy = '';

  bool isButtonEnabled = false;
  Color buttonColor = const Color(0xFF88c2f7);
  bool saveValidation = true;
  String? selectedCustomer;
  bool isSubmitting = false;
  String dropDownSelectionCustomerError = '';
  List<Customers>? customerList;
  String? _selectedCurrency = 'HKD'; // Default value
  final List<String> _currencies = ['HKD', 'MOP', 'CNY'];
  bool _isPartialPayment = false; // Partial Payment Radio Button
  bool _isPartialCashReceiptPayment = false; // Partial Payment Radio Button
  String? _selectedInvoiceNumber;
  final TextEditingController _customerNameController = TextEditingController();
  String? _selectedCustomerId;
  int? _selectedRemainingAmount;
  bool _isViewCashReceiptVisible = false;
  bool isCashReceiptList = false;
  List<CashReceiptData>? cashReceiptList;
  final ScrollController _scrollController = ScrollController();
  String? userRole;

  // Fetch customer name based on invoice number
  void _fetchCustomerName(String invoiceNumber, List<Invoices> invoices) {
    // Find the selected invoice from the list
    Invoices? selectedInvoice = invoices.firstWhere(
      (invoice) => invoice.invoiceNumber == invoiceNumber,
      orElse: () => Invoices(), // Provide a default value to avoid errors
    );
    setState(() {});
    if (selectedInvoice.customer != null) {
      _customerNameController.text = selectedInvoice.customer!.companyName ??
          selectedInvoice.customer!.contactPersonName ??
          'Unknown Customer';
      _selectedCustomerId = selectedInvoice.customerId;
      _selectedRemainingAmount = selectedInvoice.remainingAmount;
    } else {
      _customerNameController.text = 'Unknown Customer';
    }

    if (selectedInvoice.remainingAmount != null) {
      amountController.text = selectedInvoice.remainingAmount.toString();
      /*double.parse(selectedInvoice.remainingAmount!).toStringAsFixed(0);*/
    } else {
      amountController.text = ''; // Clear if no amount is available
    }
  }

  // Function to validate the amount
  bool _validateAmount() {
    if (_selectedRemainingAmount == 0) {
      setState(() {
        errorAmount = 'Cash Receipt already generated'; // Set error message
      });
      return false; // Validation failed
    }
    // Get the entered amount from controller and parse to double
    final enteredAmount = double.tryParse(amountController.text) ?? 0;
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

  void _updateButtonColor() {
    setState(() {
      bool isValidInvoice =
          Validator.stringValidate(invoiceNumberController.text);
      bool isCustomerSelected =
          Validator.stringValidate(customerNameController.text);
      bool isAmountEntered = Validator.amountValidate(amountController.text);

      isButtonEnabled = isValidInvoice && isCustomerSelected && isAmountEntered;
      buttonColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  void _onButtonPressed() {
    if (!_validateAmount()) {
      return; // Stop submission if validation fails
    }

    if (_formCashKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      // Capture pickup time and date
      DateTime pickupDateTime = DateTime.now(); // Example time
      String pickupTime = DateFormat('HH:mm').format(pickupDateTime); // "15:00"

      FocusScope.of(context).requestFocus(FocusNode());
      BlocProvider.of<CashBloc>(context).add(AddNewCashReceipt(
          addCashReceiptRequest: CashReceiptRequest(
              invoiceNumber: _selectedInvoiceNumber,
              receiptNumber: 'REC-$_selectedInvoiceNumber',
              customerId: _selectedCustomerId,
              amount: (int.parse(amountController.text)).toInt(),
              partialDelivery: _isPartialPayment,
              cashPickupDate: getCurrentTimeInISO8601Format(),
              pickupTime: pickupTime,
              pickedBy: pickupByController.text,
              currency: _selectedCurrency)));
    }
  }

  void _viewOrder(String orderNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return Container();
      },
    );
  }

  void _showEditCashDialog(BuildContext context, CashReceiptData cashReceipt) {
    double amountInHkd = double.parse(cashReceipt.amountInHkd!);
    amountController.text = amountInHkd.toStringAsFixed(0);
    pickupByController.text = cashReceipt.pickedBy!.toString();

    showDialog(
      context: context,
      builder: (context) {
        return EditCashReceiptDialog(
          invoiceNumber: cashReceipt.invoiceNumber!,
          companyName: cashReceipt.customer!.companyName!,
          initialPartialDelivery: _isPartialCashReceiptPayment,
          initialCurrency: _selectedCurrency!,
          onPartialDeliveryChanged: (value) {
            setState(() {
              _isPartialCashReceiptPayment = value;
            });
          },
          onCurrencyChanged: (value) {
            setState(() {
              _selectedCurrency = value;
            });
          },
          amountEditController: amountController,
          pickByEditController: pickupByController,
          callCancel: (BuildContext context) {
            Navigator.pop(context);
          },
          callSave: (BuildContext context, int units, String value) {
            DateTime pickupDateTime = DateTime.now(); // Example time
            String pickupTime =
                DateFormat('HH:mm').format(pickupDateTime); // "15:00"

            Navigator.pop(context);
            context.read<CashBloc>().add(EditCashReceipt(
                cashReceiptId: cashReceipt.id!,
                editCashReceiptRequest: EditCashReceiptRequest(
                    amount: units,
                    partialDelivery: _isPartialCashReceiptPayment,
                    cashPickupDate: getCurrentTimeInISO8601Format(),
                    pickupTime: pickupTime,
                    pickedBy: value,
                    currency: _selectedCurrency)));
          },
        );
      },
    );
  }

  // Function to handle modify action
  void _modifyOrder(String id) {
    // Navigate to a modify order screen or show a dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modify Order'),
          content: const Text('Modify order functionality goes here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle delete action
  void _deleteOrder(String invoiceId) {
    BlocProvider.of<CashBloc>(context)
        .add(DeleteCashReceipt(cashReceiptId: invoiceId));
  }

  // Function to handle print invoice action
  void _printInvoice(String cashId) {
    BlocProvider.of<CashBloc>(context, listen: false)
        .add(GetCashDetailsByID(cashId: cashId));
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    print("Get Invoice list");
    BlocProvider.of<InvoiceBloc>(context, listen: false)
        .add(const GetInvoiceDetails());
    userRole = Prefs.getUser('user')?.role!;
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CashBloc>().add(const GetCashReceiptFetchNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CashBloc, CashState>(
      listener: (context, state) async {
        if (state is CashAddInitialState) {
          const CircularProgressIndicator();
        } else if (state is CashAddLoadedState) {
          int code = state.cashAddResponse?.statusCode ?? 0;
          print('Response  : ${state.cashAddResponse}');
          print('Code : $code');
          setState(() {
            isSubmitting = false;
          });
          _formCashKey.currentState!.reset();

          if (code == SUCCESS_CREATE) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.successfully,
                  AppLocalizations.of(context)!.successMessageCash,
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
        } else if (state is CashGetLoadedState) {
          int? code = state.getCashReceiptResponse?.statusCode;
          if (code == SUCCESS) {
            if (state.getCashReceiptResponse?.total == 0) {
              setState(() {
                isCashReceiptList = false;
              });
            } else {
              setState(() {
                isCashReceiptList = true;
                cashReceiptList = state.getCashReceiptResponse?.data;
                //isHasReachMax = state.hasReachedMax;
              });
            }
          } else {
            //error
          }
        } else if (state is CashDeleteLoadedState) {
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
        } else if (state is CashDetailsLoadedState) {
          int code = state.cashDetailsByIdResponse?.statusCode ?? 0;
          print('Code : $code');
          if (code == SUCCESS) {
            CashReceiptDetails? cashReceiptData =
                state.cashDetailsByIdResponse?.data!;
            final pdfFile =
                await PdfService.generateCashReceiptPdf(cashReceiptData!);
            print('PDF saved at: ${pdfFile.path}');
            // Open the PDF file
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
        } else if (state is CashEditLoadedState) {
          int? code = state.editInvoiceResponse!.statusCode;
          print('Code : $code');
          if (code == SUCCESS) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.megUpdateCashReceipt)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          text: AppLocalizations.of(context)!.addCashReceipt,
                          fontSize: 16,
                          desiredLineHeight: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.02,
                          color: const Color(0xFF171717),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          print("Check Customer List API Request");
                          BlocProvider.of<CashBloc>(context, listen: false)
                              .add(GetCashReceiptList());
                          setState(() {
                            _isViewCashReceiptVisible =
                                !_isViewCashReceiptVisible; // Toggle visibility
                          });
                        },
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF85A5A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.viewCashReceipt,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ]),
                const SizedBox(height: 12),
                Expanded(
                  child: _isViewCashReceiptVisible
                      ? isCashReceiptList
                          ? _buildCashReceiptList()
                          : const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Form(
                            key: _formCashKey,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Invoice Number Field
                                  BlocBuilder<InvoiceBloc, InvoiceState>(
                                    builder: (context, state) {
                                      if (state is InvoiceGetInitialState) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (state
                                          is InvoiceGetLoadedState) {
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
                                                  invoice.invoiceNumber ??
                                                  AppLocalizations.of(context)!
                                                      .error_invoiceRequired)
                                              .toList(),
                                          dropdownDecoratorProps:
                                              DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              labelText:
                                                  AppLocalizations.of(context)!
                                                      .orderInvoiceNumber,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedInvoiceNumber = value;
                                              _fetchCustomerName(
                                                  value!, invoices);
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppLocalizations.of(
                                                      context)!
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

                                  // Partial Payment Radio Button
                                  Row(
                                    children: [
                                      Text(
                                          '${AppLocalizations.of(context)!.txtPartialPayment}:'),
                                      Radio(
                                        value: true,
                                        groupValue: _isPartialPayment,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPartialPayment = value as bool;
                                          });
                                        },
                                      ),
                                      Text(AppLocalizations.of(context)!.yes),
                                      Radio(
                                        value: false,
                                        groupValue: _isPartialPayment,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPartialPayment = value as bool;
                                          });
                                        },
                                      ),
                                      Text(AppLocalizations.of(context)!.no),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Amount Collected and Currency Dropdown
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color(0xFFE5E5E5),
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: TextFormField(
                                              controller: amountController,
                                              enabled: _isPartialPayment,
                                              onChanged: (value) {
                                                setState(() {
                                                  errorAmount =
                                                      Validator.amountValidate(
                                                              value)
                                                          ? ''
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .enterAmount;
                                                });
                                                _updateButtonColor();
                                              },
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                color: Color(0xFF171717),
                                                fontWeight: FontWeight.w400,
                                                height: 1.50,
                                                fontSize: 16,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText:
                                                    '${AppLocalizations.of(context)!.amount} *',
                                                labelStyle: const TextStyle(
                                                    color: Color(0xFF737373)),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      // Currency Dropdown
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xFFE5E5E5),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: DropdownButton<String>(
                                            value: _selectedCurrency,
                                            hint: Text(
                                                AppLocalizations.of(context)!
                                                    .select_currency),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedCurrency = newValue;
                                              });
                                            },
                                            items: _currencies
                                                .map<DropdownMenuItem<String>>(
                                                    (String currency) {
                                              return DropdownMenuItem<String>(
                                                value: currency,
                                                child: Text(currency),
                                              );
                                            }).toList(),
                                            underline: const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: errorAmount.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/error_icon.svg',
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
                                  const SizedBox(height: 12),

                                  // Pickup By Field
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        controller: pickupByController,
                                        onChanged: (value) {
                                          setState(() {
                                            errorPickupBy =
                                                Validator.stringValidate(value)
                                                    ? ''
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .enterValidPickupBy;
                                          });
                                          _updateButtonColor();
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          labelText:
                                              '${AppLocalizations.of(context)!.pickupBy} *',
                                          labelStyle: const TextStyle(
                                              color: Color(0xFF737373)),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: errorPickupBy.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/error_icon.svg',
                                            height: 12.67,
                                            width: 12.67,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: CustomText(
                                              text: errorPickupBy,
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
                                  const SizedBox(height: 12),

                                  // Submit Button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: buttonColor,
                                    ),
                                    child: TextButton(
                                      onPressed: _onButtonPressed,
                                      child: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .submit,
                                        fontSize: 16,
                                        desiredLineHeight: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _buildCashReceiptList() {
    final sortedList = cashReceiptList?.toList() ?? [];
    sortedList.sort((a, b) {
      final dateA = DateTime.parse(a.updatedAt!);
      final dateB = DateTime.parse(b.updatedAt!);
      return dateB.compareTo(dateA); // For newest first (descending)
      // Use dateA.compareTo(dateB) for oldest first (ascending)
    });
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: sortedList.length ?? 0,
      // Always use the length of the customers list
      itemBuilder: (context, index) {
        // Safely access the customer at the current index
        final cashReceipt = sortedList[index];
        String dateString = cashReceipt.updatedAt!;
        DateTime dateTime = DateTime.parse(dateString);
        // Extract date and time
        String date = DateFormat('yyyy-MM-dd').format(dateTime);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ListTile(
            title: Text(cashReceipt.customer!.companyName ?? 'No Name'),
            subtitle: Text(
                '${cashReceipt.customer!.mobileNumber ?? 'No Number'}\n$date'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (userRole == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditCashDialog(context, cashReceipt),
                  ),
                if (userRole == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(cashReceipt.id!),
                  ),
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.green),
                  onPressed: () => _printInvoice(cashReceipt.id!),
                ),
              ],
            ),
            onTap: () {
              // Navigate to an edit screen or show a dialog for updating
            },
          ),
        );
      },
    );
  }
}
