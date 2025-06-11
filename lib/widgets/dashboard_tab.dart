import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/models/transaction.dart';
import 'package:budget_planner_flutter/models/budget.dart';
import 'package:budget_planner_flutter/models/monthly_stats.dart';
import 'package:budget_planner_flutter/widgets/spending_chart.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatelessWidget {
  final MonthlyStats monthlyStats;
  final Budget? budget;
  final List<Transaction> transactions;
  final String monthName;
  final int year;
  final List<DailyExpense> dailyExpenses;
  final int currentMonth;

  const DashboardTab({
    super.key,
    required this.monthlyStats,
    required this.budget,
    required this.transactions,
    required this.monthName,
    required this.year,
    required this.dailyExpenses,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final recentTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(5).toList();

    final budgetRemaining = budget != null ? budget!.amount - monthlyStats.expenses : null;
    final budgetPercentage = budget != null && budget!.amount > 0 ? (monthlyStats.expenses / budget!.amount) * 100 : null;
    final actualBalance = budget != null ? budget!.amount - monthlyStats.expenses : monthlyStats.balance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main statistics card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary - $monthName $year',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 4.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    children: [
                      _buildBudgetCard(),
                      _buildStatCard(
                        'Expenses',
                        '${monthlyStats.expenses.toStringAsFixed(2)} PLN',
                        const Color(0xFFEF4444),
                      ),
                      _buildStatCard(
                        'Balance',
                        '${actualBalance.toStringAsFixed(2)} PLN',
                        actualBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                      _buildStatCard(
                        'Transactions',
                        monthlyStats.transactionCount.toString(),
                        const Color(0xFF4A4A4A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Spending chart
          const SizedBox(height: 20),
          SpendingChart(
            dailyExpenses: dailyExpenses,
            budget: budget,
            currentMonth: currentMonth,
            currentYear: year,
          ),

          // Recent transactions
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No transactions',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (budget != null) ...[
            Text(
              '${budget!.amount.toStringAsFixed(0)} PLN',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (budget!.plannedAmount != budget!.amount)
              Text(
                'Plan: ${budget!.plannedAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
          ] else
            const Text(
              'Not set',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 2),
          const Text(
            'Budget',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF404040))),
      ),
      child: Row(
        children: [
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
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} PLN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.type == TransactionType.income 
                  ? const Color(0xFF10B981) 
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}