import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/utils/format.dart';
import 'package:rentease_simple/widgets/custom_button.dart';
import 'package:rentease_simple/widgets/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentScreen extends StatefulWidget {
  final String billId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.billId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _transactionIdController = TextEditingController();
  String _selectedMethod = 'bkash';

  final Map<String, String> _paymentMethods = {
    'bkash': 'bKash',
    'nagad': 'Nagad',
    'rocket': 'Rocket',
    'card': 'Card',
    'bank': 'Bank Transfer',
  };

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_transactionIdController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter transaction ID',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    paymentProvider.makePayment(
      widget.billId,
      _selectedMethod,
      _transactionIdController.text.trim(),
    );

    Fluttertoast.showToast(
      msg: 'Payment successful!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bill ID:'),
                        Text(widget.billId),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppFormat.formatCurrency(widget.amount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._paymentMethods.entries.map((method) {
              return RadioListTile<String>(
                title: Text(method.value),
                value: method.key,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _transactionIdController,
              label: 'Transaction ID',
              hintText: 'Enter your transaction ID',
              prefixIcon: Icons.receipt,
            ),
            const SizedBox(height: 10),
            Text(
              'Note: Complete the payment in your ${_paymentMethods[_selectedMethod]} app first, then enter the transaction ID here.',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Pay:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedMethod == 'bkash'
                          ? '1. Dial *247#\n2. Select Send Money\n3. Enter: 017XXXXXXXX\n4. Amount: ${widget.amount}\n5. Enter your PIN\n6. Copy Transaction ID'
                          : _selectedMethod == 'nagad'
                              ? '1. Open Nagad App\n2. Select Send Money\n3. Enter: 017XXXXXXXX\n4. Amount: ${widget.amount}\n5. Enter your PIN\n6. Copy Transaction ID'
                              : 'Complete the payment and enter the transaction ID provided.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                return CustomButton(
                  text: 'Confirm Payment',
                  onPressed: paymentProvider.isLoading ? () {} : _processPayment,
                  isLoading: paymentProvider.isLoading,
                  color: Colors.green,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}