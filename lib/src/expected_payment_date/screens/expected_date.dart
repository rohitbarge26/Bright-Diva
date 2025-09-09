import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frequent_flow/src/expected_payment_date/bloc/expected_bloc.dart';
import 'package:frequent_flow/utils/response_status.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_functions.dart';
import '../../../utils/route.dart';
import '../../../widgets/calendar_job_filter_dialog.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../../order_management/invoice_bloc/invoice_bloc.dart';
import '../../order_management/invoice_bloc/invoice_event.dart';
import '../../order_management/invoice_bloc/invoice_state.dart';
import '../../order_management/model/get_invoice_response.dart';
import '../bloc/expected_event.dart';
import '../bloc/expected_state.dart';
import '../model/expected_date_request.dart';

class ExpectedDate extends StatefulWidget {
  const ExpectedDate({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<ExpectedDate> createState() => _ExpectedDateState();
}

class _ExpectedDateState extends State<ExpectedDate> {
  final _formOrderKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  TextEditingController invoiceDateController = TextEditingController();
  String? _selectedInvoiceNumber;
  String? _invoiceId;
  String? _selectedCustomerId;
  DateTime? selectedInvoiceDate;
  String errorInvoiceDate = '';

  void _fetchCustomerName(String invoiceNumber, List<Invoices> invoices) {
    Invoices? selectedInvoice = invoices.firstWhere(
          (invoice) => invoice.invoiceNumber == invoiceNumber,
      orElse: () => Invoices(),
    );

    if (selectedInvoice.customer != null) {
      _customerNameController.text = selectedInvoice.customer!.companyName ??
          selectedInvoice.customer!.contactPersonName ??
          'Unknown Customer';
      _selectedCustomerId = selectedInvoice.customerId;
      _invoiceId = selectedInvoice.id;
      // --- This is the key change ---
      if (selectedInvoice.expectedPaymentDate != null &&
          selectedInvoice.expectedPaymentDate!.isNotEmpty) {
        try {
          DateTime parsedExpectedDate = DateTime.parse(selectedInvoice.expectedPaymentDate!);
          setState(() {
            selectedInvoiceDate = parsedExpectedDate;
            invoiceDateController.text = _formatDateWithOrdinal(parsedExpectedDate);
          });
          print('Fetched and Parsed Expected Date: $selectedInvoiceDate');
        } catch (e) {
          print('Error parsing expectedPaymentDate: $e');
        }
      } else {
        print('No expected payment date found for this invoice.');
      }
    } else {
      _customerNameController.text = 'Unknown Customer';
    }
  }

  void _submitForm() {
    // Validate that date is not in the past
    if (selectedInvoiceDate != null && selectedInvoiceDate!.isBefore(DateTime.now())) {
      setState(() {
        errorInvoiceDate = 'Past dates are not allowed for expected payment date';
      });
      return;
    }

    if (_formOrderKey.currentState!.validate()) {
      String expectedDate =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedInvoiceDate!);

      print('Expected Date: $expectedDate');
      // Handle form submission here
      BlocProvider.of<ExpectedBloc>(context).add(UpdateExpectedDateInvoice(
          request: ExpectedDateRequest(
              customerId: _selectedCustomerId,
              invoiceDate: getCurrentTimeInISO8601Format(),
              expectedPaymentDate: expectedDate),
          invoiceId: _invoiceId!));
    }
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

  @override
  void initState() {
    super.initState();
    BlocProvider.of<InvoiceBloc>(context, listen: false)
        .add(const GetInvoiceDetails());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpectedBloc, ExpectedState>(
      listener: (BuildContext context, state) {
        if (state is ExpectedDateInitialState) {
          const CircularProgressIndicator();
        } else if (state is ExpectedDateLoadedState) {
          int code = state.expectedDateResponse?.statusCode ?? 0;
          print('Code : $code');
          if (code == SUCCESS) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.successfully,
                  AppLocalizations.of(context)!.exPaymentDateUpdateMessage,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: widget.onBackTap,
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow_icon.svg',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomText(
                      text: AppLocalizations.of(context)!.expectedPaymentDate,
                      fontSize: 20,
                      desiredLineHeight: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.02,
                      color: const Color(0xFF171717),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Expanded(
                  child: Form(
                    key: _formOrderKey,
                    child: ListView(children: [
                      // Invoice Number Dropdown
                      BlocBuilder<InvoiceBloc, InvoiceState>(
                        builder: (context, state) {
                          if (state is InvoiceGetInitialState) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is InvoiceGetLoadedState) {
                            List<Invoices> invoices = state.getInvoiceDetailsResponse?.invoices ?? [];

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
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.orderInvoiceNumber,
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
                                  return AppLocalizations.of(context)!.errorOrderInvoiceNumber;
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
                      // Customer Name (Auto-filled)
                      TextFormField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          labelText:
                          '${AppLocalizations.of(context)!.customerName} *',
                          border: const OutlineInputBorder(),
                          enabled: false,
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
                      // Expected Date Section
                      Text(
                        'Expected Payment Date *',
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
                            firstDate: DateTime.now(), // KEY CHANGE: Prevent past dates
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
                              errorInvoiceDate = ""; // Clear any previous error
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: errorInvoiceDate.isNotEmpty
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
                                selectedInvoiceDate != null
                                    ? _formatDateWithOrdinal(selectedInvoiceDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  color: selectedInvoiceDate != null
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
                      // Error message for past date
                      if (errorInvoiceDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            errorInvoiceDate,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),
                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.submit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
}