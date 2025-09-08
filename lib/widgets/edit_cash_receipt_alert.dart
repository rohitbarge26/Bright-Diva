import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class EditCashReceiptDialog extends StatefulWidget {
  final String invoiceNumber;
  final String companyName;
  final bool initialPartialDelivery;
  final String initialCurrency;
  final Function(bool) onPartialDeliveryChanged;
  final Function(String) onCurrencyChanged;
  final TextEditingController amountEditController;
  final TextEditingController pickByEditController;
  final Function(BuildContext context, int units, String value)? callSave;
  final Function(BuildContext context)? callCancel;

  const EditCashReceiptDialog({
    Key? key,
    required this.invoiceNumber,
    required this.companyName,
    required this.initialPartialDelivery,
    required this.initialCurrency,
    required this.onPartialDeliveryChanged,
    required this.onCurrencyChanged,
    required this.amountEditController,
    required this.pickByEditController,
    required this.callSave,
    required this.callCancel,
  }) : super(key: key);

  @override
  _EditCashReceiptDialogState createState() => _EditCashReceiptDialogState();
}

class _EditCashReceiptDialogState extends State<EditCashReceiptDialog> {
  late bool _isPartialEditDelivery;
  late String _selectedCurrency;
  final _formKey = GlobalKey<FormState>();
  String _errorPickupBy = '';

  @override
  void initState() {
    super.initState();
    _isPartialEditDelivery = widget.initialPartialDelivery;
    _selectedCurrency = widget.initialCurrency;
  }

  bool _validateForm() {
    bool isValid = true;

    if (widget.pickByEditController.text.isEmpty) {
      setState(() {
        _errorPickupBy = 'Please enter picked by name';
      });
      isValid = false;
    } else {
      setState(() {
        _errorPickupBy = '';
      });
    }

    if (widget.amountEditController.text.isEmpty) {
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Cash Receipt',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => widget.callCancel!(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E5E5)),
                const SizedBox(height: 20),

                // Order Information
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
                      _buildInfoRow('Invoice No:', widget.invoiceNumber),
                      const SizedBox(height: 8),
                      _buildInfoRow('Customer:', widget.companyName),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Amount Section
                Text(
                  'Amount Details',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),

                const SizedBox(height: 16),

                // Amount Field
                _buildFormField(
                  label: 'Amount *',
                  controller: widget.amountEditController,
                  keyboardType: TextInputType.number,
                  prefixText: 'HK\$ ',
                ),

                const SizedBox(height: 16),

                // Currency Selection
                _buildCurrencyDropdown(),

                const SizedBox(height: 16),

                // Picked By Field
                _buildFormField(
                  label: 'Picked By *',
                  controller: widget.pickByEditController,
                  hintText: 'Enter pickup person name',
                  errorText: _errorPickupBy,
                ),

                const SizedBox(height: 16),

                // Partial Delivery Section
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
                      Text(
                        'Partial Delivery *',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Yes Option
                          _buildRadioOption(
                            value: true,
                            label: 'Yes',
                          ),
                          const SizedBox(width: 24),
                          // No Option
                          _buildRadioOption(
                            value: false,
                            label: 'No',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => widget.callCancel!(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          side: BorderSide(color: Colors.blue[800]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
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
                          if (_validateForm()) {
                            final amount = int.tryParse(widget.amountEditController.text) ?? 0;
                            widget.callSave!(context, amount, widget.pickByEditController.text);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Cash receipt updated successfully!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Update Receipt',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF171717),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? errorText,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFFE5E5E5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF171717),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF737373)),
                prefixText: prefixText,
                prefixStyle: const TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency *',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: _selectedCurrency,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF171717),
              fontSize: 16,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCurrency = newValue!;
                widget.onCurrencyChanged(newValue);
              });
            },
            items: ['HKD', 'MOP', 'CNY'].map<DropdownMenuItem<String>>((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({required bool value, required String label}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPartialEditDelivery = value;
          widget.onPartialDeliveryChanged(value);
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isPartialEditDelivery == value ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            child: _isPartialEditDelivery == value
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _isPartialEditDelivery == value ? Colors.blue : Colors.grey[700],
              fontWeight: _isPartialEditDelivery == value ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}