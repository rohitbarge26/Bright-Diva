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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete), // 确认删除
          content: Text(AppLocalizations.of(context)!.areYouSureDelete), // 您确定要删除吗？
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
                BlocProvider.of<CustomerBloc>(context).add(DeleteCustomer(customerId: id));
              },
            ),
          ],
        );
      },
    );
  }

  void _editCustomer(Customers customer) {
    _companyNameController.text = customer.companyName ?? '';
    _address1Controller.text = customer.address ?? '';
    _cityController.text = customer.city ?? '';
    _countryController.text = customer.country ?? '';
    _brnController.text = customer.businessRegistrationNumber ?? '';
    _emailController.text = customer.emailId ?? '';
    _contactPersonController.text = customer.contactPersonName ?? '';
    _contactNumberController.text = customer.mobileNumber ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.editCustomer,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                          fontFamily: 'Inter',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  const SizedBox(height: 24),

                  // Form Fields
                  _buildFormField(
                    controller: _companyNameController,
                    label: AppLocalizations.of(context)!.companyName,
                    icon: Icons.business,
                  ),

                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _contactPersonController,
                    label: AppLocalizations.of(context)!.contactPersonName,
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _emailController,
                    label: AppLocalizations.of(context)!.email,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _contactNumberController,
                    label: AppLocalizations.of(context)!.contactNumber,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _brnController,
                    label: AppLocalizations.of(context)!.brn,
                    icon: Icons.assignment,
                  ),

                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _address1Controller,
                    label: AppLocalizations.of(context)!.address,
                    icon: Icons.location_on,
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          controller: _cityController,
                          label: AppLocalizations.of(context)!.city,
                          icon: Icons.location_city,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          controller: _countryController,
                          label: AppLocalizations.of(context)!.country,
                          icon: Icons.public,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF171717),
                            side: const BorderSide(color: Color(0xFFE5E5E5)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.txtCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
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
                                companyName: _companyNameController.text,
                              ),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.txtSave),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Helper method to build consistent form fields
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Inter',
        color: Color(0xFF171717),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF737373),
          fontFamily: 'Inter',
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF737373)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
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
                      alertLogoPath: 'assets/icons/error_icon.svg',
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
                                isMandatory: true,
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
                                isMandatory: true,
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
                                isMandatory: true,
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
                                isMandatory: true,
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
                                isMandatory: true,
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
                                isMandatory: true,
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
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      itemCount: customers?.length ?? 0,
      itemBuilder: (context, index) {
        final customer = customers?[index];
        if (customer == null) {
          return const SizedBox.shrink();
        }

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
                    Text(
                      customer.companyName ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A5B92),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Contact Person
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Contact Person',
                      value: customer.contactPersonName ?? 'N/A',
                    ),

                    const SizedBox(height: 8),

                    // Mobile Number
                    _buildDetailRow(
                      icon: Icons.phone,
                      label: 'Mobile',
                      value: customer.mobileNumber ?? 'No Number',
                    ),

                    const SizedBox(height: 8),

                    // Email
                    _buildDetailRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: customer.emailId ?? 'N/A',
                    ),

                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${customer.city ?? ''}${customer.city != null && customer.country != null ? ', ' : ''}${customer.country ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        // Edit Button
                        _buildActionButton(
                          icon: Icons.edit,
                          color: Colors.blue,
                          tooltip: 'Edit Customer',
                          onPressed: () => _editCustomer(customer),
                        ),

                        const SizedBox(width: 8),

                        // Delete Button
                        _buildActionButton(
                          icon: Icons.delete,
                          color: Colors.red,
                          tooltip: 'Delete Customer',
                          onPressed: () => _deleteCustomer('${customer.id}'),
                        ),
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

// Helper method for detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String errorText,
    required Function(String) onChanged,
    required TextInputType keyboardType,
    required TextCapitalization textCapitalization,
    bool isMandatory = false,
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
              validator: isMandatory ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              } : null,
            ),
          ),
        ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
