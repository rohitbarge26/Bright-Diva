import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/src/customer_management/bloc/customer_bloc.dart';
import 'package:frequent_flow/src/customer_management/bloc/customer_event.dart';
import 'package:frequent_flow/src/customer_management/bloc/customer_state.dart';
import 'package:frequent_flow/utils/route.dart';
import 'package:frequent_flow/utils/validation.dart';

import '../../../utils/app_functions.dart';
import '../../../utils/prefs.dart';
import '../../../utils/response_status.dart';
import '../../../widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widgets/error_dialog.dart';
import '../../../widgets/show_alert_dialog.dart';
import '../model/add_customer_request.dart';
import '../model/get_customer.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final _formCustomerKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _brnController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _errorCompanyName = '';
  String _errorAddress1 = '';
  String _errorCity = '';
  String _errorCountry = '';
  String _errorBRN = '';
  String _errorContactPerson = '';
  String _errorContactNumber = '';
  String _errorEmail = '';

  bool _isButtonEnabled = false;
  bool _isViewCustomerVisible = false; // State variable for visibility
  bool isSubmitting = false;
  bool isCustomerList = false;
  bool isHasReachMax = false;
  List<Customers>? customers;
  final ScrollController _scrollController = ScrollController();

  void _updateButtonColor() {
    setState(() {
      _isButtonEnabled = _companyNameController.text
          .isNotEmpty; /* &&
          _address1Controller.text.isNotEmpty &&
          _cityController.text.isNotEmpty &&
          _countryController.text.isNotEmpty &&
          _brnController.text.isNotEmpty &&
          _contactPersonController.text.isNotEmpty &&
          _contactNumberController.text.isNotEmpty;
      //_emailController.text.isNotEmpty;*/
    });
  }

  void _onSubmit() {
    if (_formCustomerKey.currentState!.validate()) {
      // Handle form submission
      print('Form submitted successfully');
      // Add the new customer to the list
      setState(() {
        isSubmitting = true;
      });
      // Clear the form
      String timeStamp = getCurrentTimeStamp();
      FocusScope.of(context).requestFocus(FocusNode());
      final addCustomerRequest = CustomerAddRequest(
        customerName: _contactPersonController.text, // Assuming this is now required
        address: _address1Controller.text, // Required
        contactPersonName: _contactPersonController.text, // Required
        mobileNumber: _contactNumberController.text, // Required
        emailId: _emailController.text.isNotEmpty // Check if email is filled
            ? _emailController.text // Use user's input
            : "${_contactPersonController.text.isNotEmpty ? _contactPersonController.text.replaceAll(' ', '').toLowerCase() : "user"}.$timeStamp@example.com", // Your default logic
        businessRegistrationNumber: _brnController.text, // Required
        city: _cityController.text, // Required
        country: _countryController.text, // Required
        companyName: _companyNameController.text, // Required
      );
      BlocProvider.of<CustomerBloc>(context).add(AddNewCustomer(
        addCustomerRequest: addCustomerRequest,
      ));
      _clearForm();
    }else{
      print('Form validation failed');
    }
  }

  void _clearForm() {
    _companyNameController.clear();
    _address1Controller.clear();
    _cityController.clear();
    _countryController.clear();
    _brnController.clear();
    _contactPersonController.clear();
    _contactNumberController.clear();
    //_emailController.clear();
  }

  void _deleteCustomer(String id) {
    BlocProvider.of<CustomerBloc>(context).add(DeleteCustomer(customerId: id));
  }

  void _editCustomer(Customers customer) {
    _companyNameController.text = customer.contactPersonName!;
    _address1Controller.text = customer.emailId!;
    _cityController.text = customer.city!;
    _countryController.text = customer.country!;
    _brnController.text = customer.businessRegistrationNumber!;
    _emailController.text = customer.emailId!;
    _contactPersonController.text = customer.contactPersonName!;
    _contactNumberController.text = customer.mobileNumber!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.companyName),
                ),
                TextFormField(
                  controller: _address1Controller,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.address),
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.city),
                ),
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.country),
                ),
                TextFormField(
                  controller: _brnController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.brn),
                ),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.contactPersonName),
                ),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.contactNumber),
                ),
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
                context.read<CustomerBloc>().add(EditCustomer(
                    customerId: customer.id!,
                    addCustomerRequest: CustomerAddRequest(
                        address: _address1Controller.text,
                        contactPersonName: _contactPersonController.text,
                        mobileNumber: _contactNumberController.text,
                        emailId: _emailController.text,
                        businessRegistrationNumber: _brnController.text,
                        city: _cityController.text,
                        country: _countryController.text,
                        customerName: _companyNameController.text,
                        companyName: _companyNameController.text)));
              },
              child: Text(AppLocalizations.of(context)!.txtSave),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CustomerBloc>().add(const GetCustomerFetchNextPage());
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
    return PopScope(
      canPop: false,
      child: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerAddInitialState) {
            const CircularProgressIndicator();
          } else if (state is CustomerAddLoadedState) {
            int code = state.customerAddResponse?.statusCode ?? 0;
            print("Data in Class: ${state.customerAddResponse.toString()}");
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
                    AppLocalizations.of(context)!.successMessageCustomer,
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
          } else if (state is CustomerGetLoadedState) {
            int? code = state.customerGetResponse?.statusCode;
            if (code == SUCCESS) {
              if (state.customerGetResponse?.total == 0) {
                //Customer list not available
                setState(() {
                  isCustomerList = false;
                });
              } else {
                setState(() {
                  isCustomerList = true;
                  customers = state.customerGetResponse?.customers;
                });
              }
            } else {
              //error
            }
          } else if (state is CustomerDeleteLoadedState) {
            int? code = state.deleteCustomerResponse!.statusCode;
            if (code == SUCCESS) {
              Navigator.of(context).pop();
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
          } else if (state is CustomerEditLoadedState) {
            int? code = state.editCustomerResponse!.statusCode;
            if (code == SUCCESS) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.msgUpdateCustomer)),
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
                        text: AppLocalizations.of(context)!.addCustomer,
                        fontSize: 18,
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
                        BlocProvider.of<CustomerBloc>(context, listen: false)
                            .add(const GetCustomer());
                        setState(() {
                          _isViewCustomerVisible =
                              !_isViewCustomerVisible; // Toggle visibility
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
                          AppLocalizations.of(context)!.viewCustomer,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _isViewCustomerVisible
                      ? isCustomerList
                          ? _buildCustomerList()
                          : const Center(child: CircularProgressIndicator())
                      : Form(
                          key: _formCustomerKey,
                          child: ListView(
                            children: [
                              _buildTextField(
                                controller: _companyNameController,
                                labelText:
                                    AppLocalizations.of(context)!.companyName,
                                errorText: _errorCompanyName,
                                onChanged: (value) {
                                  setState(() {
                                    _errorCompanyName = value.isEmpty
                                        ? AppLocalizations.of(context)!
                                            .errorCompanyName
                                        : '';
                                  });
                                  _updateButtonColor();
                                },
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                              _buildTextField(
                                controller: _address1Controller,
                                labelText:
                                    AppLocalizations.of(context)!.address,
                                errorText: _errorAddress1,
                                onChanged: (value) {
                                  setState(() {
                                    _errorAddress1 = value.isEmpty ? '' : '';
                                  });
                                },
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                              _buildTextField(
                                controller: _cityController,
                                labelText: AppLocalizations.of(context)!.city,
                                errorText: _errorCity,
                                onChanged: (value) {
                                  setState(() {
                                    _errorCity = value.isEmpty ? '' : '';
                                  });
                                },
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                              _buildTextField(
                                controller: _countryController,
                                labelText:
                                    AppLocalizations.of(context)!.country,
                                errorText: _errorCountry,
                                onChanged: (value) {
                                  setState(() {
                                    _errorCountry = value.isEmpty ? '' : '';
                                  });
                                },
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                              _buildTextField(
                                controller: _brnController,
                                labelText: AppLocalizations.of(context)!.brn,
                                errorText: _errorBRN,
                                onChanged: (value) {
                                  setState(() {
                                    _errorBRN = value.isEmpty ? '' : '';
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                              ),
                              _buildTextField(
                                controller: _contactPersonController,
                                labelText: AppLocalizations.of(context)!
                                    .contactPersonName,
                                errorText: _errorContactPerson,
                                onChanged: (value) {
                                  setState(() {
                                    _errorContactPerson =
                                        value.isEmpty ? '' : '';
                                  });
                                },
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.none,
                              ),
                              _buildTextField(
                                controller: _contactNumberController,
                                labelText:
                                    AppLocalizations.of(context)!.contactNumber,
                                errorText: _errorContactNumber,
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  setState(() {
                                    _errorContactNumber =
                                        Validator.phoneNumberValidate(value)
                                            ? ''
                                            : '';
                                  });
                                },
                                textCapitalization: TextCapitalization.none,
                              ),
                              /*_buildTextField(
                                controller: _emailController,
                                labelText:
                                    AppLocalizations.of(context)!.emailTXT,
                                errorText: _errorEmail,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    _errorEmail = Validator.emailValidate(value)
                                        ? ''
                                        : AppLocalizations.of(context)!
                                            .messageInvalidEmail;
                                  });
                                  _updateButtonColor();
                                },
                              ),*/
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : _isButtonEnabled
                                        ? _onSubmit
                                        : null,
                                child:
                                    Text(AppLocalizations.of(context)!.submit),
                              ),
                            ],
                          )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: customers?.length ?? 0,
      // Always use the length of the customers list
      itemBuilder: (context, index) {
        // Safely access the customer at the current index
        final customer = customers?[index];
        if (customer == null) {
          return const SizedBox
              .shrink(); // Return an empty widget if customer is null
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ListTile(
            title: Text(customer.companyName ?? 'No Name'),
            subtitle: Text(
                customer.mobileNumber ?? 'No Number'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editCustomer(customer),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCustomer('${customer.id}'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String errorText,
    required Function(String) onChanged,
    required TextInputType keyboardType,
    required TextCapitalization textCapitalization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: const TextStyle(color: Color(0xFF737373)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8.0),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFF85A5A),
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
