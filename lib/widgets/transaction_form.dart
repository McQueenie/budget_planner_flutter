import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Function(Transaction) onAddTransaction;

  const TransactionForm({
    super.key,
    required this.onAddTransaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      final transaction = Transaction(
        description: _descriptionController.text.trim(),
        amount: amount,
        type: _type,
        date: _selectedDate,
      );

      widget.onAddTransaction(transaction);

      // Reset form
      _descriptionController.clear();
      _amountController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? tempSelectedDate = _selectedDate;
    
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
              surfaceVariant: Color(0xFF1A1A1A),
              onSurfaceVariant: Colors.grey,
            ),
            dialogBackgroundColor: const Color(0xFF2A2A2A),
          ),
          child: AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Select Date',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: 300,
              height: 300,
              child: StatefulBuilder(
                builder: (context, setDialogState) {
                  return CalendarDatePicker(
                    initialDate: tempSelectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (DateTime date) {
                      // Auto-select on single tap (like double-click behavior)
                      Navigator.of(context).pop(date);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(tempSelectedDate),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _type == TransactionType.income ? 'Add Income' : 'Add Expense',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Transaction type selection
              const Text(
                'Transaction type:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: const Text('Expense', style: TextStyle(color: Colors.white)),
                      value: TransactionType.expense,
                      groupValue: _type,
                      onChanged: (TransactionType? value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                      activeColor: const Color(0xFF4A4A4A),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: const Text('Income', style: TextStyle(color: Colors.white)),
                      value: TransactionType.income,
                      groupValue: _type,
                      onChanged: (TransactionType? value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                      activeColor: const Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description and Amount in a row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Grocery shopping',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLength: 100,
                          onFieldSubmitted: (_) => _submitForm(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amount (PLN):',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onFieldSubmitted: (_) => _submitForm(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(color: const Color(0xFF404040)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined, 
                            color: Colors.grey, 
                            size: 22
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Add Transaction'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}