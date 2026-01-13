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
  final _customAmountController = TextEditingController();
  String _selectedMethod = 'bkash';
  late double _paymentAmount;
  String _selectedAmountOption = 'full'; // 'full', 'half', 'custom'

  final Map<String, String> _paymentMethods = {
    'bkash': 'bKash',
    'nagad': 'Nagad',
    'rocket': 'Rocket',
    'card': 'Card',
    'bank': 'Bank Transfer',
  };

  @override
  void initState() {
    super.initState();
    _paymentAmount = widget.amount;
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _updatePaymentAmount(String option) {
    setState(() {
      _selectedAmountOption = option;
      switch (option) {
        case 'full':
          _paymentAmount = widget.amount;
          _customAmountController.clear();
          break;
        case 'half':
          _paymentAmount = widget.amount / 2;
          _customAmountController.clear();
          break;
        case 'custom':
          _paymentAmount = 0;
          _customAmountController.clear();
          break;
      }
    });
  }

  void _updateCustomAmount(String value) {
    if (value.isEmpty) {
      setState(() {
        _paymentAmount = 0;
      });
      return;
    }
    try {
      final amount = double.parse(value);
      if (amount > 0 && amount <= widget.amount) {
        setState(() {
          _paymentAmount = amount;
        });
      }
    } catch (e) {
      // Invalid input
    }
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

    if (_paymentAmount <= 0) {
      Fluttertoast.showToast(
        msg: 'Please select a valid payment amount',
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
      msg: 'Payment of ${AppFormat.formatCurrency(_paymentAmount)} successful!',
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
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppFormat.formatCurrency(widget.amount),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Amount Selection
            const Text(
              'Select Payment Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                // Full Amount
                GestureDetector(
                  onTap: () => _updatePaymentAmount('full'),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAmountOption == 'full'
                            ? Colors.green
                            : Colors.grey[300]!,
                        width: _selectedAmountOption == 'full' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: _selectedAmountOption == 'full'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Full Amount',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Pay entire bill',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppFormat.formatCurrency(widget.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Half Amount
                GestureDetector(
                  onTap: () => _updatePaymentAmount('half'),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAmountOption == 'half'
                            ? Colors.orange
                            : Colors.grey[300]!,
                        width: _selectedAmountOption == 'half' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: _selectedAmountOption == 'half'
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Half Amount',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Pay 50% of bill',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppFormat.formatCurrency(widget.amount / 2),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Custom Amount
                GestureDetector(
                  onTap: () => _updatePaymentAmount('custom'),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedAmountOption == 'custom'
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: _selectedAmountOption == 'custom' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: _selectedAmountOption == 'custom'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Custom Amount',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Enter your own amount',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedAmountOption == 'custom' && _paymentAmount > 0)
                              Text(
                                AppFormat.formatCurrency(_paymentAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        if (_selectedAmountOption == 'custom') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            onChanged: _updateCustomAmount,
                            decoration: InputDecoration(
                              hintText: 'Enter amount (max: ${AppFormat.formatCurrency(widget.amount)})',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Payment Summary with selected amount
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You will pay:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppFormat.formatCurrency(_paymentAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
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
                          ? '1. Dial *247#\n2. Select Send Money\n3. Enter: 017XXXXXXXX\n4. Amount: ${AppFormat.formatCurrency(_paymentAmount)}\n5. Enter your PIN\n6. Copy Transaction ID'
                          : _selectedMethod == 'nagad'
                              ? '1. Open Nagad App\n2. Select Send Money\n3. Enter: 017XXXXXXXX\n4. Amount: ${AppFormat.formatCurrency(_paymentAmount)}\n5. Enter your PIN\n6. Copy Transaction ID'
                              : 'Complete the payment of ${AppFormat.formatCurrency(_paymentAmount)} and enter the transaction ID provided.',
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