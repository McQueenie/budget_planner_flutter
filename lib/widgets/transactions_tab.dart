import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/models/transaction.dart';
import 'package:budget_planner_flutter/widgets/transaction_form.dart';
import 'package:budget_planner_flutter/widgets/transaction_list.dart';

class TransactionsTab extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onAddTransaction;
  final Function(Transaction) onUpdateTransaction;
  final Function(int) onDeleteTransaction;

  const TransactionsTab({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
    required this.onUpdateTransaction,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TransactionForm(onAddTransaction: onAddTransaction),
          const SizedBox(height: 20),
          TransactionList(
            transactions: transactions,
            onUpdateTransaction: onUpdateTransaction,
            onDeleteTransaction: onDeleteTransaction,
          ),
        ],
      ),
    );
  }
}