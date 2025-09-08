import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/src/order_management/model/invoice_request.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../../../utils/app_functions.dart';
import '../../../utils/prefs.dart';
import '../../../utils/print_order.dart';
import '../../../utils/response_status.dart';
import '../../../utils/route.dart';
import '../../../utils/validation.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../../customer_management/bloc/customer_bloc.dart';
import '../../customer_management/bloc/customer_event.dart';
import '../../customer_management/bloc/customer_state.dart';
import '../../customer_management/model/get_customer.dart';
import '../../settings/bloc/currency/currency_bloc.dart';
import '../../settings/bloc/currency/currency_event.dart';
import '../../settings/bloc/currency/currency_state.dart';
import '../invoice_bloc/invoice_bloc.dart';
import '../invoice_bloc/invoice_event.dart';
import '../invoice_bloc/invoice_state.dart';
import '../model/edit_invoice_request.dart';
import '../model/get_invoice_by_id.dart';
import '../model/get_invoice_response.dart';

class Invoice extends StatefulWidget {
  const Invoice({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  final _formInvoiceKey = GlobalKey<FormState>();
  TextEditingController invoiceNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController totalUnitsController = TextEditingController();
  TextEditingController invoiceDateController = TextEditingController();
  String errorInvoiceDate = '';
  DateTime? selectedInvoiceDate;
  String? selectedInvoiceDateAPI;
  String errorInvoiceNumber = '';
  String errorCustomer = '';
  String errorAmount = '';
  bool isButtonEnabled = false;
  Color buttonColor = const Color(0xFF88c2f7);
  bool isSubmitting = false;
  String? selectedCustomer;
  bool saveValidation = true;
  bool isAutoGenerateInvoice = false; // For auto-generate checkbox
  DateTime currentDate = DateTime.now(); // For invoice date
  List<Customers>? customerList;
  bool _isViewInvoiceVisible = false;
  bool isInvoiceList = false;
  List<Invoices>? invoiceList;
  double hkdToMop = 1.03; // Initial value for HKD to MOP
  double hkdToCny = 0.92; // Initial value for HKD to CNY
  String currency_id = "";
  String _conversionText = '';
  String dropDownSelectionCustomerError = '';

  String? _selectedCurrency = 'HKD'; // Default value
  final List<String> _currencies = ['HKD', 'MOP', 'CNY'];
  String? userRole;

  // Conversion rates (replace with actual rates or API calls)
  void _calculateConversion() {
    if (amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      setState(() => _conversionText = '');
      return;
    }

    final amount = double.parse(amountController.text);

    if (_selectedCurrency == 'HKD') {
      setState(() => _conversionText = ''); // Hide for HKD
    } else {
      final rate = _selectedCurrency == 'MOP' ? hkdToMop : hkdToCny;
      final convertedAmount = _selectedCurrency == 'MOP'
          ? amount / rate // Convert MOP→HKD (500 MOP → 500/1.03 ≈ 485.44 HKD)
          : amount / rate; // Convert CNY→HKD

      setState(() {
        _conversionText = '≈ ${convertedAmount.toStringAsFixed(2)} HKD';
      });
    }
  }

  void _updateButtonColor() {
    setState(() {
      bool isValidInvoice =
          Validator.stringValidate(invoiceNumberController.text);
      bool isAmountEntered = Validator.amountValidate(amountController.text);

      isButtonEnabled =
          isValidInvoice && isAmountEntered && selectedInvoiceDate != null;
      buttonColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }
  bool _validateFields() {
    bool isValid = true;

    // Validate Invoice Number
    if (!isAutoGenerateInvoice && (invoiceNumberController.text.isEmpty ||
        !Validator.alphanumericValidate(invoiceNumberController.text))) {
      setState(() {
        errorInvoiceNumber = AppLocalizations.of(context)!.enterValidInvoiceNumber;
      });
      isValid = false;
    }

    // Validate Customer Selection
    if (selectedCustomer == null) {
      setState(() {
        dropDownSelectionCustomerError = AppLocalizations.of(context)!.selectCustomer;
        saveValidation = false;
      });
      isValid = false;
    }

    // Validate Amount
    if (amountController.text.isEmpty ||
        !Validator.amountValidate(amountController.text) ||
        double.parse(amountController.text) <= 0) {
      setState(() {
        errorAmount = AppLocalizations.of(context)!.enterAmount;
      });
      isValid = false;
    }

    // Validate Invoice Date
    if (invoiceDateController.text.isEmpty) {
      setState(() {
        errorInvoiceDate = AppLocalizations.of(context)!.selectInvoiceDate;
      });
      isValid = false;
    }

    return isValid;
  }

  void _onButtonPressed() {
    if (!_validateFields()) {
      return; // Stop submission if validation fails
    }
    if (_formInvoiceKey.currentState!.validate()) {
      // Handle form submission
      print('Form submitted successfully');
      // Add the new customer to the list
      setState(() {
        isSubmitting = true;
      });
      // Clear the form
      FocusScope.of(context).requestFocus(FocusNode());
      BlocProvider.of<InvoiceBloc>(context).add(AddInvoice(
          addInvoiceRequest: InvoiceRequest(
              invoiceNumber: isAutoGenerateInvoice
                  ? generateInvoiceNumber() // Auto-generate invoice number
                  : invoiceNumberController.text,
              customerId: selectedCustomer,
              amount: num.tryParse(amountController.text),
              invoiceDate: selectedInvoiceDateAPI,
              currency: _selectedCurrency,
              totalUnits: 0)));
      _clearForm();
    }
  }

  Future<void> _selectInvoiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedInvoiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      // Allow dates from year 2000
      lastDate: DateTime(2100),
      // Allow dates up to year 2100
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedInvoiceDate) {
      setState(() {
        selectedInvoiceDate = picked;
        print('selectedInvoiceDate: $selectedInvoiceDate');
        // Format for API - dd/MM/yyyy
        selectedInvoiceDateAPI = _formatDateForAPI(picked);
        print('selectedInvoiceDateAPI: $selectedInvoiceDateAPI');

        invoiceDateController.text =
            _formatDateWithOrdinal(picked); // Updated formatting
        errorInvoiceDate = ''; // Clear any previous error
        _updateButtonColor();
      });
    }
  }

  String _formatDateForAPI(DateTime date) {
    // Format the date as dd/MM/yyyy
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _formatDateWithOrdinal(DateTime date) {
    final day = date.day;
    final month = DateFormat('MMMM').format(date); // Full month name
    final year = date.year;

    // Add ordinal suffix (st, nd, rd, th)
    String ordinalSuffix;
    if (day >= 11 && day <= 13) {
      ordinalSuffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          ordinalSuffix = 'st';
          break;
        case 2:
          ordinalSuffix = 'nd';
          break;
        case 3:
          ordinalSuffix = 'rd';
          break;
        default:
          ordinalSuffix = 'th';
      }
    }

    return '$day$ordinalSuffix $month $year';
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
      amountController.text = cleanedValue;
      amountController.selection =
          TextSelection.collapsed(offset: cleanedValue.length);
    }
  }

  void _clearForm() {
    invoiceNumberController.clear();
    amountController.clear();
    //totalUnitsController.clear();
  }

  // Function to handle modify action
  void _modifyOrder(Invoices invoice) {
    double amountInHkd = double.parse(invoice.amountInHkd!);
    amountController.text = amountInHkd.toStringAsFixed(0);
    _selectedCurrency = invoice.currency!;

    // Parse the invoice date from the invoice object
    DateTime invoiceDate = DateTime.parse(invoice.invoiceDate!);
    selectedInvoiceDate = invoiceDate;
    invoiceDateController.text = _formatDateWithOrdinal(invoiceDate);

    String? errorInvoiceDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Invoice',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.grey[600], size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFE5E5E5)),
                      const SizedBox(height: 20),

                      // Invoice Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                                'Invoice Number:', invoice.invoiceNumber!),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                                'Customer:', invoice.customer!.companyName!),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form Fields
                      Text(
                        'Edit Details',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount Field
                      Text(
                        'Amount *',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFE5E5E5), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextFormField(
                            controller: amountController,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF171717),
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter amount',
                              hintStyle: TextStyle(color: Color(0xFF737373)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Currency Dropdown
                      Text(
                        'Currency *',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFE5E5E5), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.grey[600]),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF171717),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          },
                          items: _currencies
                              .map<DropdownMenuItem<String>>((String currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Invoice Date Field
                      Text(
                        'Invoice Date *',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedInvoiceDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.blue[800]!,
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            setState(() {
                              selectedInvoiceDate = picked;
                              invoiceDateController.text =
                                  _formatDateWithOrdinal(picked);
                              errorInvoiceDate = null;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: errorInvoiceDate != null
                                    ? Colors.red
                                    : const Color(0xFFE5E5E5),
                                width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                invoiceDateController.text.isNotEmpty
                                    ? invoiceDateController.text
                                    : 'Select date',
                                style: TextStyle(
                                  color: invoiceDateController.text.isNotEmpty
                                      ? const Color(0xFF171717)
                                      : const Color(0xFF737373),
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.calendar_today,
                                  color: Colors.blue[800], size: 20),
                            ],
                          ),
                        ),
                      ),

                      if (errorInvoiceDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                errorInvoiceDate!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[800],
                              side: BorderSide(color: Colors.blue[800]!),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.txtCancel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedInvoiceDate == null) {
                                setState(() {
                                  errorInvoiceDate =
                                      AppLocalizations.of(context)!
                                          .selectInvoiceDate;
                                });
                                return;
                              }

                              if (amountController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .enterAmount),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(context);
                              context.read<InvoiceBloc>().add(EditInvoice(
                                    invoiceId: invoice.id!,
                                    editRequest: InvoiceEditRequest(
                                      customerId: invoice.customer!.id!,
                                      amount:
                                          double.parse(amountController.text)
                                              .round(),
                                      invoiceDate: selectedInvoiceDate!
                                          .toIso8601String(),
                                      currency: _selectedCurrency,
                                      totalUnits: 0,
                                    ),
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.txtSave,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ]),
              ),
            );
          },
        );
      },
    );
  }

// Helper method for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF171717),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Function to handle delete action
  void _deleteInvoice(String id) {
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
                BlocProvider.of<InvoiceBloc>(context)
                    .add(DeleteInvoice(invoiceId: id));
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle print invoice action
  void _printInvoice(String invoiceId) {
    BlocProvider.of<InvoiceBloc>(context, listen: false)
        .add(GetInvoiceDetailsByID(invoiceId: invoiceId));
  }

  @override
  void initState() {
    super.initState();
    print("Get Customer list");
    BlocProvider.of<CustomerBloc>(context, listen: false)
        .add(const GetCustomerList());
    userRole = Prefs.getUser('user')?.role!;
    BlocProvider.of<CurrencyBloc>(context).add(const GetCurrencyUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) async {
        if (state is InvoiceAddInitialState) {
          const CircularProgressIndicator();
        } else if (state is InvoiceAddLoadedState) {
          int code = state.addInvoiceResponse?.statusCode ?? 0;
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
                  AppLocalizations.of(context)!.successMessageInvoice,
                  AppLocalizations.of(context)!.btnContinue,
                  ROUT_HOME,
                  false,
                  0),
            );
          } else if (code == INTERNAL_SERVER_ERROR) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.unableToProcess,
                  AppLocalizations.of(context)!.duplicateMessageInvoice,
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
        } else if (state is InvoiceGetLoadedState) {
          int? code = state.getInvoiceDetailsResponse?.statusCode;
          if (code == SUCCESS) {
            if (state.getInvoiceDetailsResponse?.total == 0) {
              //Customer list not available
              setState(() {
                isInvoiceList = false;
              });
            } else {
              setState(() {
                isInvoiceList = true;
                invoiceList = state.getInvoiceDetailsResponse?.invoices;
                //isHasReachMax = state.hasReachedMax;
              });
            }
          } else {
            //error
          }
        } else if (state is InvoiceGetDetailsLoadedState) {
          int code = state.getDetailsById?.statusCode ?? 0;
          print("Print Invoice Class:: ${state.getDetailsById.toString()}");
          print('Code : $code');
          if (code == SUCCESS) {
            InvoiceDetails? orders = state.getDetailsById?.invoice;
            print('Date: ${orders?.createdAt}');
            final pdfFile = await PdfService.generateInvoicePdf(orders!);
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
        } else if (state is InvoiceDeleteLoadedState) {
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
        } else if (state is InvoiceEditLoadedState) {
          int? code = state.editInvoiceResponse!.statusCode;
          print('Code : $code');
          if (code == SUCCESS) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.msgUpdateInvoice)),
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
                        const SizedBox(width: 12),
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: AppLocalizations.of(context)!.addInvoice,
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
                            print("Check Customer List API Request");
                            BlocProvider.of<InvoiceBloc>(context, listen: false)
                                .add(const GetInvoiceDetails());
                            setState(() {
                              _isViewInvoiceVisible =
                                  !_isViewInvoiceVisible; // Toggle visibility
                            });
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF85A5A),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.viewInvoice,
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
                      ]),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isViewInvoiceVisible
                        ? isInvoiceList
                            ? _buildInvoiceList()
                            : const Center(child: CircularProgressIndicator())
                        : Form(
                            key: _formInvoiceKey,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                        controller: invoiceNumberController,
                                        onChanged: (value) {
                                          setState(() {
                                            errorInvoiceNumber = Validator
                                                    .alphanumericValidate(value)
                                                ? ''
                                                : AppLocalizations.of(context)!
                                                    .enterValidInvoiceNumber;
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
                                        keyboardType: TextInputType.name,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: InputDecoration(
                                          labelText:
                                              '${AppLocalizations.of(context)!.invoiceNumber} *',
                                          labelStyle: const TextStyle(
                                            color: Color(0xFF737373),
                                          ),
                                          counterText: '',
                                          border: InputBorder.none,
                                        ),
                                        maxLength: 17,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: errorInvoiceNumber.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icons/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: CustomText(
                                                text: errorInvoiceNumber,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Customer Dropdown with Concatenated Address
                                  BlocBuilder<CustomerBloc, CustomerState>(
                                    builder: (context, state) {
                                      if (state is CustomerListInitialState) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (state
                                          is CustomerListLoadedState) {
                                        customerList = state
                                            .getCustomerListResponse?.customers;
                                        int? totalCustomer = state
                                            .getCustomerListResponse?.total;
                                        if (totalCustomer == 0) {
                                          return const SizedBox.shrink();
                                        } else {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 15),
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE2E3E6)),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            child: DropdownSearch<Customers>(
                                              popupProps: PopupProps.menu(
                                                showSearchBox: true,
                                                searchFieldProps:
                                                    TextFieldProps(
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .searchCustomer,
                                                  ),
                                                ),
                                              ),
                                              items: customerList ?? [],
                                              itemAsString: (Customers u) =>
                                                  '${u.companyName} - ${u.city}',
                                              dropdownDecoratorProps:
                                                  DropDownDecoratorProps(
                                                dropdownSearchDecoration:
                                                    InputDecoration(
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .selectCustomer,
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                              onChanged: (Customers? newValue) {
                                                setState(() {
                                                  selectedCustomer =
                                                      newValue?.id;
                                                  saveValidation = true;
                                                });
                                              },
                                            ),
                                          );
                                        }
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                  Visibility(
                                    visible: !saveValidation,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/error_icon.svg',
                                                  height: 12.67,
                                                  width: 12.67,
                                                ),
                                                const SizedBox(width: 4),
                                                CustomText(
                                                  text:
                                                      dropDownSelectionCustomerError,
                                                  fontSize: 12,
                                                  desiredLineHeight: 16,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFFDF4747),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ]),
                                        ]),
                                  ),
                                  const SizedBox(height: 12),
                                  // Amount and Currency Dropdown
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
                                              onChanged: (value) {
                                                // Format the input to allow only numbers and up to 2 decimal places
                                                _formatAmountInput(value);

                                                setState(() {
                                                  errorAmount =
                                                      Validator.amountValidate(
                                                              value)
                                                          ? ''
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .enterAmount;
                                                  _calculateConversion();
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
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d*\.?\d{0,2}')),
                                                // Allow only numbers and up to 2 decimals
                                              ],
                                              decoration: InputDecoration(
                                                labelText:
                                                    '${AppLocalizations.of(context)!.amount} *',
                                                labelStyle: const TextStyle(
                                                  color: Color(0xFF737373),
                                                ),
                                                counterText: '',
                                                border: InputBorder.none,
                                              ),
                                              maxLength: 17,
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
                                                _calculateConversion();
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
                                  const SizedBox(height: 5),
                                  Visibility(
                                    visible: errorAmount.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: SvgPicture.asset(
                                              'assets/icons/error_icon.svg',
                                              height: 12.67,
                                              width: 12.67,
                                              alignment: Alignment.center,
                                            ),
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

                                  if (_conversionText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        _conversionText,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  // Invoice Date Field
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
                                        controller: invoiceDateController,
                                        readOnly: true,
                                        // Prevent manual editing
                                        onTap: () =>
                                            _selectInvoiceDate(context),
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          labelText:
                                              '${AppLocalizations.of(context)!.invoiceDate} *',
                                          labelStyle: const TextStyle(
                                              color: Color(0xFF737373)),
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                                Icons.calendar_today,
                                                size: 20),
                                            onPressed: () =>
                                                _selectInvoiceDate(context),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: errorInvoiceDate.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: SvgPicture.asset(
                                              'assets/icons/error_icon.svg',
                                              height: 12.67,
                                              width: 12.67,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: CustomText(
                                              text: errorInvoiceDate,
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
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceList() {
    final sortedList = invoiceList?.toList() ?? [];
    sortedList.sort((a, b) {
      final dateA = DateTime.parse(a.updatedAt!);
      final dateB = DateTime.parse(b.updatedAt!);
      return dateB.compareTo(dateA); // Newest first
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final invoice = sortedList[index];
        String dateString = invoice.invoiceDate!;
        DateTime dateTime = DateTime.parse(dateString);
        String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
        String formattedTime = DateFormat('hh:mm a').format(dateTime);

        double amount = double.parse(invoice.amountInHkd!);
        String formattedAmount = NumberFormat('#,##0').format(amount.round());

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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Invoice Number
                        Text(
                          invoice.invoiceNumber ?? 'INV-0000',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A5B92),
                            fontFamily: 'Inter',
                          ),
                        ),

                        // Status Badge (You can customize based on status)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Text(
                            'Paid', // Change based on your status field
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Customer Info
                    Text(
                      invoice.customer!.companyName ?? 'No Company',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171717),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Details Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'HK\$ $formattedAmount',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF171717),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),

                        // Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF171717),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Print Button
                        _buildActionButton(
                          icon: Icons.print,
                          color: Colors.green,
                          tooltip: 'Print Invoice',
                          onPressed: () => _printInvoice(invoice.id!),
                        ),

                        if (userRole == 'Admin') ...[
                          const SizedBox(width: 8),
                          // Edit Button
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.orange,
                            tooltip: 'Edit Invoice',
                            onPressed: () => _modifyOrder(invoice),
                          ),

                          const SizedBox(width: 8),
                          // Delete Button
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            tooltip: 'Delete Invoice',
                            onPressed: () => _deleteInvoice(invoice.id!),
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
