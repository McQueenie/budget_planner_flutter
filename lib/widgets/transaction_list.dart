import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onUpdateTransaction;
  final Function(int) onDeleteTransaction;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onUpdateTransaction,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No transactions',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionItem(context, transaction, index == transactions.length - 1);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast 
            ? null 
            : const Border(bottom: BorderSide(color: Color(0xFF404040))),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.type == TransactionType.income 
                  ? const Color(0xFF48BB78).withOpacity(0.2)
                  : const Color(0xFFF56565).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.type == TransactionType.income 
                  ? Icons.arrow_upward 
                  : Icons.arrow_downward,
              color: transaction.type == TransactionType.income 
                  ? const Color(0xFF48BB78)
                  : const Color(0xFFF56565),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(transaction.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: transaction.type == TransactionType.income 
                            ? const Color(0xFF48BB78).withOpacity(0.2)
                            : const Color(0xFFF56565).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.type == TransactionType.income ? 'Income' : 'Expense',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: transaction.type == TransactionType.income 
                              ? const Color(0xFF48BB78)
                              : const Color(0xFFF56565),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} PLN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.type == TransactionType.income 
                      ? const Color(0xFF48BB78) 
                      : const Color(0xFFF56565),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showEditDialog(context, transaction),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context, transaction),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        onUpdate: onUpdateTransaction,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Delete Transaction', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${transaction.description}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteTransaction(transaction.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction) onUpdate;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.onUpdate,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late TransactionType _type;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _type = widget.transaction.type;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      final updatedTransaction = widget.transaction.copyWith(
        description: _descriptionController.text.trim(),
        amount: amount,
        type: _type,
        date: _selectedDate,
      );

      widget.onUpdate(updatedTransaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: const Text('Edit Transaction', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (PLN)',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: const Text('Expense', style: TextStyle(color: Colors.white)),
                      value: TransactionType.expense,
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      activeColor: const Color(0xFF4A4A4A),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: const Text('Income', style: TextStyle(color: Colors.white)),
                      value: TransactionType.income,
                      groupValue: _type,
                      onChanged: (value) => setState(() => _type = value!),
                      activeColor: const Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Update', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}