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
  String? _selectedInvoiceNumber;
  String? _invoiceId;
  String? _selectedCustomerId;
  late DateTime selectedExpectedDate = DateTime.now();

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
    } else {
      _customerNameController.text = 'Unknown Customer';
    }
  }

  void _submitForm() {
    if (_formOrderKey.currentState!.validate()) {
      String expectedDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedExpectedDate);

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
                    alertLogoPath: 'assets/icon/error_icon.svg',
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
                              items: invoices.map((invoice) => invoice.invoiceNumber ??
                                  AppLocalizations.of(context)!.error_invoiceRequired).toList(),
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
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CalendarJobFilterDialog(
                                    currentDate: selectedExpectedDate,
                                    startDate: DateTime.utc(2023),
                                  );
                                }).then((value) {
                              if (value != null) {
                                setState(() {
                                  selectedExpectedDate = value;
                                });
                              }
                            });
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .txtExpectedDate,
                                        fontSize: 14,
                                        desiredLineHeight: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.28,
                                        color: const Color(0xFF737373),
                                      ),
                                      const SizedBox(height: 4),
                                      CustomText(
                                        text: DateFormat('EEEE, MMMM d')
                                            .format(selectedExpectedDate),
                                        fontSize: 14,
                                        desiredLineHeight: 20,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.28,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ]),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ]),
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
