import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/models/budget.dart';
import 'package:budget_planner_flutter/models/monthly_stats.dart';

class BudgetTab extends StatefulWidget {
  final int currentMonth;
  final int currentYear;
  final Budget? budget;
  final MonthlyStats monthlyStats;
  final Function(Budget) onSetBudget;

  const BudgetTab({
    super.key,
    required this.currentMonth,
    required this.currentYear,
    required this.budget,
    required this.monthlyStats,
    required this.onSetBudget,
  });

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.plannedAmount.toStringAsFixed(2);
    }
  }

  @override
  void didUpdateWidget(BudgetTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budget != oldWidget.budget) {
      if (widget.budget != null) {
        _amountController.text = widget.budget!.plannedAmount.toStringAsFixed(2);
      } else {
        _amountController.clear();
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitBudget() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      // Calculate income for this month to set total budget correctly
      final currentIncomeFromBudget = widget.budget?.amount ?? 0;
      final currentPlannedFromBudget = widget.budget?.plannedAmount ?? 0;
      final incomeFromTransactions = currentIncomeFromBudget - currentPlannedFromBudget;
      
      final budget = Budget(
        month: widget.currentMonth,
        year: widget.currentYear,
        amount: amount + incomeFromTransactions, // planned + existing income
        plannedAmount: amount, // this is what user sets
      );

      widget.onSetBudget(budget);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetRemaining = widget.budget != null 
        ? widget.budget!.amount - widget.monthlyStats.expenses 
        : null;
    final budgetPercentage = widget.budget != null && widget.budget!.amount > 0
        ? (widget.monthlyStats.expenses / widget.budget!.amount) * 100 
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Budget form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Budget for ${_monthNames[widget.currentMonth - 1]} ${widget.currentYear}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Budget Amount (PLN):',
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
                        prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a budget amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitBudget,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.budget != null ? Icons.edit : Icons.add),
                            const SizedBox(width: 8),
                            Text(widget.budget != null ? 'Update Budget' : 'Set Budget'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Budget status (if budget exists)
          if (widget.budget != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Budget stats grid - compact like summary
                    GridView.count(
                      crossAxisCount: 5,
                      childAspectRatio: 1.3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _buildCompactStatCard(
                          'Planned Budget',
                          '${widget.budget!.plannedAmount.toStringAsFixed(2)} PLN',
                          const Color(0xFF4A4A4A),
                        ),
                        _buildCompactStatCard(
                          'Total Budget',
                          '${widget.budget!.amount.toStringAsFixed(2)} PLN',
                          const Color(0xFF10B981),
                        ),
                        _buildCompactStatCard(
                          'Current Expenses',
                          '${widget.monthlyStats.expenses.toStringAsFixed(2)} PLN',
                          const Color(0xFFEF4444),
                        ),
                        _buildCompactStatCard(
                          budgetRemaining != null && budgetRemaining >= 0 ? 'Remaining' : 'Overspent',
                          '${budgetRemaining?.toStringAsFixed(2)} PLN',
                          budgetRemaining != null && budgetRemaining >= 0 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFEF4444),
                        ),
                        _buildCompactStatCard(
                          'Budget Usage',
                          '${budgetPercentage?.toStringAsFixed(1)}%',
                          budgetPercentage != null && budgetPercentage > 100
                              ? const Color(0xFFEF4444)
                              : budgetPercentage != null && budgetPercentage > 80
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Budget tips
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget Tips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem(
                    Icons.lightbulb_outline,
                    'Set realistic budget goals based on your income and essential expenses.',
                  ),
                  _buildTipItem(
                    Icons.track_changes,
                    'Review your budget regularly and adjust it based on your spending patterns.',
                  ),
                  _buildTipItem(
                    Icons.savings,
                    'Try to allocate 20% of your budget for savings and emergency funds.',
                  ),
                  _buildTipItem(
                    Icons.warning_outlined,
                    'If you consistently overspend, consider reviewing your expenses and cutting unnecessary costs.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF667EEA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}