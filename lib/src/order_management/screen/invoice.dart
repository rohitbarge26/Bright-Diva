import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
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

  String dropDownSelectionCustomerError = '';

  String? _selectedCurrency = 'HKD'; // Default value
  final List<String> _currencies = ['HKD', 'MOP', 'CNY'];
  String? userRole;


  void _updateButtonColor() {
    setState(() {
      bool isValidInvoice =
          Validator.stringValidate(invoiceNumberController.text);
      bool isAmountEntered = Validator.amountValidate(amountController.text);

      isButtonEnabled = isValidInvoice && isAmountEntered;
      buttonColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  void _onButtonPressed() {
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
              amount: int.parse(amountController.text),
              invoiceDate: getCurrentTimeInISO8601Format(),
              currency: _selectedCurrency,
              totalUnits: 0)));
      _clearForm();
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
    //totalUnitsController.text = invoice.totalUnits!.toString();
    _selectedCurrency = invoice.currency!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Invoice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber!,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  invoice.customer!.companyName!,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.amount),
                ),
                DropdownButton<String>(
                  value: _selectedCurrency,
                  hint: const Text("Select Currency"),
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
                  underline: const SizedBox.shrink(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.txtCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<InvoiceBloc>().add(EditInvoice(
                    invoiceId: invoice.id!,
                    editRequest: InvoiceEditRequest(
                        customerId: invoice.customer!.id!,
                        amount: int.parse(amountController.text),
                        invoiceDate: getCurrentTimeInISO8601Format(),
                        currency: _selectedCurrency,
                        totalUnits: int.parse(totalUnitsController.text))));
              },
              child: Text(AppLocalizations.of(context)!.txtSave),
            ),
          ],
        );
      },
    );
  }

  // Function to handle delete action
  void _deleteOrder(String id) {
    BlocProvider.of<InvoiceBloc>(context).add(DeleteInvoice(invoiceId: id));
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.msgUpdateInvoice)),
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
                                // Auto Generate Checkbox and Manual Entry Field
                                /*Row(
                                  children: [
                                    Checkbox(
                                      value: isAutoGenerateInvoice,
                                      onChanged: (value) {
                                        setState(() {
                                          isAutoGenerateInvoice =
                                              value ?? false;
                                        });
                                      },
                                    ),
                                    Text(AppLocalizations.of(context)!
                                        .autoGenerateInvoice),
                                  ],
                                ),*/
                                /*Visibility(
                                  visible: !isAutoGenerateInvoice,
                                  child:
                                ),*/
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
                                      int code = state.getCustomerListResponse
                                              ?.statusCode ??
                                          0;
                                      print('Code : $code');
                                      customerList = state
                                          .getCustomerListResponse?.customers;
                                      int? totalCustomer =
                                          state.getCustomerListResponse?.total;
                                      if (totalCustomer == 0) {
                                        return const SizedBox.shrink();
                                      } else {
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  hintText: AppLocalizations.of(
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
                                                selectedCustomer = newValue?.id;
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
                                                color: const Color(0xFFDF4747),
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
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: TextFormField(
                                            controller: amountController,
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
                                            keyboardType: TextInputType.number,
                                            textCapitalization:
                                                TextCapitalization.none,
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
                                        borderRadius: BorderRadius.circular(8),
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
                                const SizedBox(height: 12),
                                // Total Units Field
                                /*Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFE5E5E5),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: TextFormField(
                                      controller: totalUnitsController,
                                      onChanged: (value) {
                                        setState(() {
                                          _updateButtonColor();
                                        });
                                      },
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Color(0xFF171717),
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        fontSize: 16,
                                      ),
                                      keyboardType: TextInputType.number,
                                      textCapitalization:
                                          TextCapitalization.none,
                                      decoration: InputDecoration(
                                        labelText:
                                            '${AppLocalizations.of(context)!.totalUnits} *',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF737373),
                                        ),
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      maxLength: 17,
                                    ),
                                  ),
                                ),*/
                                //const SizedBox(height: 12),
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
                                      text:
                                          AppLocalizations.of(context)!.submit,
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
    );
  }

  Widget _buildInvoiceList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: invoiceList?.length ?? 0,
      // Always use the length of the customers list
      itemBuilder: (context, index) {
        // Safely access the customer at the current index
        final invoice = invoiceList?[index];
        String dateString = invoice!.invoiceDate!;
        DateTime dateTime = DateTime.parse(dateString);

        // Extract date and time
        String date = DateFormat('yyyy-MM-dd').format(dateTime);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ListTile(
            title: Text(invoice.invoiceNumber ?? 'No Name'),
            subtitle: Text(
                '${invoice.customer!.companyName ?? 'No Email'} \n${double.parse(invoice.amountInHkd!).round()}\n$date'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (userRole == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _modifyOrder(invoice),
                  ),
                if (userRole == 'Admin')
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(invoice.id!),
                  ),
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.green),
                  onPressed: () => _printInvoice(invoice.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
