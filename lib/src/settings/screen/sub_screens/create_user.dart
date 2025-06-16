import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frequent_flow/src/settings/bloc/user_bloc/create_user_bloc.dart';
import 'package:frequent_flow/src/settings/bloc/user_bloc/create_user_event.dart';
import 'package:frequent_flow/src/settings/bloc/user_bloc/create_user_state.dart';
import 'package:frequent_flow/src/settings/model/user/create_user_request.dart';
import '../../../../utils/response_status.dart';
import '../../../../utils/route.dart';
import '../../../../utils/validation.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/error_dialog.dart';
import '../../../../widgets/show_alert_dialog.dart';

class CreateUser extends StatefulWidget {
  final void Function() onBackTap;

  const CreateUser({super.key, required this.onBackTap});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formCreateUserKey = GlobalKey<FormState>();
  final List<String> _roles = ['Admin', 'Executive'];
  String _name = '',
      _username = '',
      _role = 'Admin',
      _phoneNo = '',
      _emailId = '',
      _password = '';
  bool isSubmitting = false;

  void _submitForm() {
    if (_formCreateUserKey.currentState!.validate()) {
      _formCreateUserKey.currentState!.save();
      setState(() => isSubmitting = true);
      FocusScope.of(context).requestFocus(FocusNode());
      _username = '${_name.replaceAll(' ', '').toLowerCase()}$_phoneNo';
      context.read<CreateUserBloc>().add(AddNewUser(
          addUserRequest: CreateUserRequest(
              name: _name,
              username: _username,
              role: _role,
              phoneNo: _phoneNo,
              emailId: _emailId,
              password: _password)));
      _clearForm();
    }
  }

  void _clearForm() {
    _formCreateUserKey.currentState?.reset();
    setState(() {
      _name = _username = _phoneNo = _emailId = _password = '';
      _role = 'Admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateUserBloc, CreateUserState>(
      listener: (context, state) {
        if (state is CreateUserAddLoadedState) {
          setState(() => isSubmitting = false);
          if (state.userAddResponse?.statusCode == SUCCESS_CREATE) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.successfully,
                  AppLocalizations.of(context)!.successMessageUser,
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
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 68, right: 16, left: 16),
          child: Column(children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formCreateUserKey,
                child: ListView(children: [
                  _buildTextField(AppLocalizations.of(context)!.userName,
                      (value) => _name = value!,
                      validator: _validateName),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(AppLocalizations.of(context)!.userPhoneNumber,
                      (value) => _phoneNo = value!,
                      validator: _validatePhone),
                  const SizedBox(height: 16),
                  _buildTextField(AppLocalizations.of(context)!.emailTXT,
                      (value) => _emailId = value!,
                      validator: _validateEmail),
                  const SizedBox(height: 16),
                  _buildTextField(AppLocalizations.of(context)!.password,
                      (value) => _password = value!,
                      validator: _validatePassword, obscureText: true),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(AppLocalizations.of(context)!.submit),
                  )
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: widget.onBackTap,
          child: SvgPicture.asset('assets/icons/back_arrow_icon.svg',
              width: 40, height: 40),
        ),
        const SizedBox(width: 12),
        CustomText(
          text: AppLocalizations.of(context)!.prCreateUser,
          fontSize: 20,
          desiredLineHeight: 28,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.02,
          color: const Color(0xFF171717),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {String? Function(String?)? validator, bool obscureText = false}) {
    return TextFormField(
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.userRole,
          border: OutlineInputBorder()),
      value: _role,
      items: _roles
          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
          .toList(),
      onChanged: (value) => setState(() => _role = value!),
      validator: (value) =>
          value == null ? AppLocalizations.of(context)!.errorRole : null,
    );
  }

  // Updated validation methods using the Validator class
  String? _validateName(String? value) => Validator.stringValidate(value ?? '')
      ? null
      : AppLocalizations.of(context)!.errorUserName;

  String? _validatePhone(String? value) =>
      Validator.phoneNumberValidate(value ?? '')
          ? null
          : AppLocalizations.of(context)!.enterValidPhoneDigit;

  String? _validateEmail(String? value) => Validator.emailValidate(value ?? '')
      ? null
      : AppLocalizations.of(context)!.messageInvalidEmail;

  String? _validatePassword(String? value) =>
      Validator.passwordValidate(value ?? '')
          ? null
          : AppLocalizations.of(context)!.passwordPolicy;
}
