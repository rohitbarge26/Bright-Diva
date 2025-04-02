import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditOrderDialog extends StatefulWidget {
  final String invoiceNumber;
  final String companyName;
  final bool initialPartialDelivery;
  final String initialCurrency;
  final Function(bool) onPartialDeliveryChanged;
  final Function(String) onCurrencyChanged;
  final TextEditingController deliveredUnitsController;
  final TextEditingController deliveredValueController;
  final Function(BuildContext context, int units, String value)? callSave;
  final Function(BuildContext context)? callCancel;

  const EditOrderDialog({
    Key? key,
    required this.invoiceNumber,
    required this.companyName,
    required this.initialPartialDelivery,
    required this.initialCurrency,
    required this.onPartialDeliveryChanged,
    required this.onCurrencyChanged,
    required this.deliveredUnitsController,
    required this.deliveredValueController,
    required this.callSave,
    required this.callCancel,
  }) : super(key: key);

  @override
  _EditOrderDialogState createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late bool _isPartialEditDelivery;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _isPartialEditDelivery = widget.initialPartialDelivery;
    _selectedCurrency = widget.initialCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.invoiceNumber,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.companyName,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),

            // Partial Delivery (Radio Buttons)
            Text(
              AppLocalizations.of(context)!.partialDelivery,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _isPartialEditDelivery,
                  onChanged: (value) {
                    setState(() {
                      _isPartialEditDelivery = value!;
                    });
                    widget.onPartialDeliveryChanged(value!);
                  },
                ),
                const Text('Yes'),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: false,
                  groupValue: _isPartialEditDelivery,
                  onChanged: (value) {
                    setState(() {
                      _isPartialEditDelivery = value!;
                    });
                    widget.onPartialDeliveryChanged(value!);
                  },
                ),
                const Text('No'),
              ],
            ),

            TextFormField(
              controller: widget.deliveredUnitsController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.deliveredUnits),
            ),
            TextFormField(
              controller: widget.deliveredValueController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.deliveredValue),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: ['HKD', 'MOP', 'CNY'].map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
                widget.onCurrencyChanged(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.callCancel!(context);
          },
          child: Text(AppLocalizations.of(context)!.txtCancel),
        ),
        TextButton(
          onPressed: () {
            print("On change Unit :${widget.deliveredUnitsController.text}");
            int deliveredUnits = int.parse(widget.deliveredUnitsController.text);
            widget.callSave!(context,deliveredUnits,widget.deliveredValueController.text);
            // Handle save logic here
          },
          child: Text(AppLocalizations.of(context)!.txtSave),
        ),
      ],
    );
  }
}
