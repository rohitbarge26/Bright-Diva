import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frequent_flow/src/settings/bloc/currency/currency_bloc.dart';
import 'package:frequent_flow/src/settings/bloc/currency/currency_state.dart';
import 'package:frequent_flow/utils/prefs.dart';
import '../../../../utils/response_status.dart';
import '../../../../utils/route.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/error_dialog.dart';
import '../../../../widgets/show_alert_dialog.dart';
import '../../bloc/currency/currency_event.dart';
import '../../model/currency/currency_request.dart';

class Currency extends StatefulWidget {
  const Currency({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<Currency> createState() => _CurrencyState();
}

class _CurrencyState extends State<Currency> {
  double hkdToMop = 1.03; // Initial value for HKD to MOP
  double hkdToCny = 0.92; // Initial value for HKD to CNY
  String currency_id = "";
  // Controllers for the text fields
  final TextEditingController mopController = TextEditingController();
  final TextEditingController cnyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text fields with the initial values
    BlocProvider.of<CurrencyBloc>(context).add(const GetCurrencyUpdate());
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed
    mopController.dispose();
    cnyController.dispose();
    super.dispose();
  }

  // Function to update conversion rates based on user input
  void updateConversionRates() {
    setState(() {
      hkdToMop =
          double.tryParse(mopController.text) ?? hkdToMop; // Update HKD to MOP
      hkdToCny =
          double.tryParse(cnyController.text) ?? hkdToCny; // Update HKD to CNY
      String? userId = Prefs.getUser('user')?.id!;
      CurrencyRequest currencyRequest =
          CurrencyRequest(hkdToMop: hkdToMop, hkdToCny: hkdToCny);

      BlocProvider.of<CurrencyBloc>(context).add(
          UpdateCurrency(currencyRequest: currencyRequest, user_Id: currency_id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyInitialState) {
          const CircularProgressIndicator();
        } else if (state is CurrencyLoadedState) {
          int code = state.currencyResponse?.statusCode ?? 0;
          print('Code : $code');
          if (code == SUCCESS) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => ShowAlertDialog(
                  AppLocalizations.of(context)!.successfully,
                  AppLocalizations.of(context)!.successMessageCurrency,
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
        }else if(state is GetCurrencyLoadedState){
          int code = state.getCurrencyResponse?.statusCode ?? 0;
          print('Code : $code');
          if(code == SUCCESS){
            setState(() {
              currency_id = state.getCurrencyResponse!.currency![0].id!;
              hkdToMop = state.getCurrencyResponse!.currency![0].hkdToMop!;
              hkdToCny = state.getCurrencyResponse!.currency![0].hkdToCny!;
              mopController.text = state.getCurrencyResponse?.currency![0].hkdToMop.toString() ?? '';
              cnyController.text = state.getCurrencyResponse?.currency![0].hkdToCny.toString() ?? '';
            });
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 68, right: 16.0, left: 16),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
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
                      text: AppLocalizations.of(context)!.prCurrencySetup,
                      fontSize: 20,
                      desiredLineHeight: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.02,
                      color: const Color(0xFF171717),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text field for HKD to MOP
                TextField(
                  controller: mopController,
                  decoration: InputDecoration(
                    labelText: '1 HKD = ___ MOP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 10),
                // Text field for HKD to CNY
                TextField(
                  controller: cnyController,
                  decoration: InputDecoration(
                    labelText: '1 HKD = ___ CNY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 20),
                // Button to update the rates
                ElevatedButton(
                  onPressed: updateConversionRates,
                  child: Text('Update Rates'),
                ),
                SizedBox(height: 20),
                Text(
                  'Current Rates:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '1 HKD = $hkdToMop MOP',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  '1 HKD = $hkdToCny CNY',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ))
          ]),
        ),
      ),
    );
  }
}
