import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/utils/format.dart';
import 'package:rentease_simple/widgets/custom_button.dart';
import 'package:rentease_simple/widgets/custom_text_field.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final _tenantIdController = TextEditingController();
  final _rentController = TextEditingController();
  final _electricityController = TextEditingController();
  final _waterController = TextEditingController();
  final _gasController = TextEditingController();
  DateTime? _dueDate;

  double get _totalAmount {
    final rent = double.tryParse(_rentController.text) ?? 0;
    final electricity = double.tryParse(_electricityController.text) ?? 0;
    final water = double.tryParse(_waterController.text) ?? 0;
    final gas = double.tryParse(_gasController.text) ?? 0;
    return rent + electricity + water + gas;
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _createBill() async {
    if (_tenantIdController.text.isEmpty ||
        _rentController.text.isEmpty ||
        _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    paymentProvider.createBill(
      tenantId: _tenantIdController.text.trim(),
      rentAmount: double.parse(_rentController.text),
      electricityBill: double.tryParse(_electricityController.text) ?? 0,
      waterBill: double.tryParse(_waterController.text) ?? 0,
      gasBill: double.tryParse(_gasController.text) ?? 0,
      dueDate: _dueDate!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _tenantIdController.clear();
    _rentController.clear();
    _electricityController.clear();
    _waterController.clear();
    _gasController.clear();
    setState(() {
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Bill'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Bill for Tenant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _tenantIdController,
              label: 'Tenant ID *',
              hintText: 'Enter tenant ID',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _rentController,
              label: 'Rent Amount (৳) *',
              hintText: 'Enter rent amount',
              prefixIcon: Icons.home,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _electricityController,
              label: 'Electricity Bill (৳)',
              hintText: 'Enter electricity bill',
              prefixIcon: Icons.electrical_services,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _waterController,
              label: 'Water Bill (৳)',
              hintText: 'Enter water bill',
              prefixIcon: Icons.water_drop,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _gasController,
              label: 'Gas Bill (৳)',
              hintText: 'Enter gas bill',
              prefixIcon: Icons.gas_meter,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text(
              'Due Date *',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDueDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate == null
                          ? 'Select Due Date'
                          : AppFormat.formatDate(_dueDate!),
                      style: TextStyle(
                        color: _dueDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppFormat.formatCurrency(_totalAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Create Bill',
              onPressed: _createBill,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}