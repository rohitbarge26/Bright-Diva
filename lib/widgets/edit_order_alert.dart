import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditOrderDialog extends StatefulWidget {
  final String invoiceNumber;
  final String companyName;
  final bool initialPartialDelivery;
  final String initialCurrency;
  final ValueChanged<bool> onPartialDeliveryChanged;
  final ValueChanged<String> onCurrencyChanged;
  final TextEditingController deliveredUnitsController;
  final TextEditingController deliveredValueController;
  final Function(BuildContext) callCancel;
  final Function(BuildContext, int, String) callSave;

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
    required this.callCancel,
    required this.callSave,
  }) : super(key: key);

  @override
  _EditOrderDialogState createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  late bool _isPartialDelivery;
  late String _selectedCurrency;
  final TextEditingController _deliveredByController = TextEditingController();
  final TextEditingController _orderedAmountController = TextEditingController();
  final TextEditingController _balanceAmountController = TextEditingController();
  String _errorDeliveredBy = '';

  @override
  void initState() {
    super.initState();
    _isPartialDelivery = widget.initialPartialDelivery;
    _selectedCurrency = widget.initialCurrency;
    _orderedAmountController.text = widget.deliveredValueController.text;
    _calculateBalance();
  }

  void _calculateBalance() {
    final orderedAmount = double.tryParse(_orderedAmountController.text) ?? 0;
    final deliveredAmount = double.tryParse(widget.deliveredValueController.text) ?? 0;
    final balance = orderedAmount - deliveredAmount;
    _balanceAmountController.text = balance.toStringAsFixed(2);
  }

  bool _validateForm() {
    bool isValid = true;

    if (_deliveredByController.text.isEmpty) {
      setState(() {
        _errorDeliveredBy = 'Please enter delivered by';
      });
      isValid = false;
    } else {
      setState(() {
        _errorDeliveredBy = '';
      });
    }

    if (widget.deliveredValueController.text.isEmpty) {
      isValid = false;
    }

    if (widget.deliveredUnitsController.text.isEmpty) {
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0.00');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit height to 80% of screen
        ),
        child: SingleChildScrollView( // Add this wrapper
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keep this as min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Order Delivery',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => widget.callCancel(context),
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
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Ordered Amount:',
                      'HK\$ ${numberFormat.format(double.tryParse(_orderedAmountController.text) ?? 0)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Balance Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance Amount:',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      'HK\$ ${numberFormat.format(double.tryParse(_balanceAmountController.text) ?? 0)}',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Delivery Details
              Text(
                'Delivery Details',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),

              const SizedBox(height: 16),

              // Delivered Units
              _buildFormField(
                label: 'Delivered Units *',
                controller: widget.deliveredUnitsController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateBalance(),
              ),

              const SizedBox(height: 16),

              // Delivered Value
              _buildFormField(
                label: 'Delivered Value *',
                controller: widget.deliveredValueController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateBalance(),
                prefixText: 'HK\$ ',
              ),

              const SizedBox(height: 16),

              // Delivered By
              _buildFormField(
                label: 'Delivered By *',
                controller: _deliveredByController,
                hintText: 'Enter delivery person name',
                errorText: _errorDeliveredBy,
              ),

              const SizedBox(height: 16),

              // Currency Selection
              _buildCurrencyDropdown(),

              const SizedBox(height: 16),

              // Partial Delivery Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _isPartialDelivery,
                    onChanged: (value) {
                      setState(() {
                        _isPartialDelivery = value ?? false;
                        widget.onPartialDeliveryChanged(_isPartialDelivery);
                      });
                    },
                  ),
                  Text(
                    'Partial Delivery',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => widget.callCancel(context),
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
                          widget.callSave(
                            context,
                            int.parse(widget.deliveredUnitsController.text),
                            widget.deliveredValueController.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Order updated successfully!'),
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
                        'Update Order',
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
    ValueChanged<String>? onChanged,
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
              onChanged: onChanged,
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
          'Currency',
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
            items: ['HKD', 'USD', 'CNY'].map<DropdownMenuItem<String>>((String currency) {
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
}