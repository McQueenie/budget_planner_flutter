import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/models/transaction.dart';
import 'package:budget_planner_flutter/models/budget.dart';
import 'package:budget_planner_flutter/models/monthly_stats.dart';
import 'package:budget_planner_flutter/services/database_service.dart';
import 'package:budget_planner_flutter/widgets/dashboard_tab.dart';
import 'package:budget_planner_flutter/widgets/transactions_tab.dart';
import 'package:budget_planner_flutter/widgets/budget_tab.dart';
import 'package:budget_planner_flutter/widgets/analytics_tab.dart';
import 'package:budget_planner_flutter/widgets/month_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  
  List<Transaction> _transactions = [];
  MonthlyStats _monthlyStats = MonthlyStats.empty();
  Budget? _budget;
  List<DailyExpense> _dailyExpenses = [];
  Map<String, double> _categoryExpenses = {};
  bool _loading = false;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    try {
      final db = DatabaseService.instance;
      
      final transactions = await db.getTransactions(month: _currentMonth, year: _currentYear);
      final stats = await db.getMonthlyStats(_currentMonth, _currentYear);
      final budget = await db.getBudget(_currentMonth, _currentYear);
      final dailyExpenses = await db.getDailyExpenses(_currentMonth, _currentYear);
      final categoryExpenses = await db.getCategoryExpenses(_currentMonth, _currentYear);
      
      setState(() {
        _transactions = transactions;
        _monthlyStats = stats;
        _budget = budget;
        _dailyExpenses = dailyExpenses;
        _categoryExpenses = categoryExpenses;
      });
    } catch (error) {
      debugPrint('Error loading data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleAddTransaction(Transaction transaction) async {
    try {
      await DatabaseService.instance.addTransaction(transaction);
      
      // If it's an income transaction, automatically increase the budget
      if (transaction.type == TransactionType.income) {
        await _updateBudgetForIncome(transaction);
      }
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully')),
        );
      }
    } catch (error) {
      debugPrint('Error adding transaction: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transaction: $error')),
        );
      }
    }
  }

  Future<void> _updateBudgetForIncome(Transaction incomeTransaction) async {
    try {
      final month = incomeTransaction.date.month;
      final year = incomeTransaction.date.year;
      
      // Get existing budget for the month/year
      final existingBudget = await DatabaseService.instance.getBudget(month, year);
      
      if (existingBudget != null) {
        // Increase total budget by income amount, keep planned budget unchanged
        final updatedBudget = Budget(
          id: existingBudget.id,
          month: month,
          year: year,
          amount: existingBudget.amount + incomeTransaction.amount,
          plannedAmount: existingBudget.plannedAmount, // Keep original planned budget
        );
        await DatabaseService.instance.setBudget(updatedBudget);
      } else {
        // Create new budget with income amount (no planned budget set yet)
        final newBudget = Budget(
          month: month,
          year: year,
          amount: incomeTransaction.amount,
          plannedAmount: 0, // No planned budget set yet
        );
        await DatabaseService.instance.setBudget(newBudget);
      }
    } catch (error) {
      debugPrint('Error updating budget for income: $error');
    }
  }

  Future<void> _decreaseBudgetForDeletedIncome(Transaction deletedIncomeTransaction) async {
    try {
      final month = deletedIncomeTransaction.date.month;
      final year = deletedIncomeTransaction.date.year;
      
      // Get existing budget for the month/year
      final existingBudget = await DatabaseService.instance.getBudget(month, year);
      
      if (existingBudget != null) {
        // Decrease total budget by deleted income amount, keep planned budget unchanged
        final newAmount = existingBudget.amount - deletedIncomeTransaction.amount;
        final finalAmount = newAmount >= existingBudget.plannedAmount 
            ? newAmount 
            : existingBudget.plannedAmount; // Don't go below planned budget
        
        final updatedBudget = Budget(
          id: existingBudget.id,
          month: month,
          year: year,
          amount: finalAmount,
          plannedAmount: existingBudget.plannedAmount, // Keep original planned budget
        );
        await DatabaseService.instance.setBudget(updatedBudget);
      }
    } catch (error) {
      debugPrint('Error decreasing budget for deleted income: $error');
    }
  }

  Future<void> _handleBudgetAdjustmentForUpdate(Transaction original, Transaction updated) async {
    try {
      final month = original.date.month;
      final year = original.date.year;
      final updatedMonth = updated.date.month;
      final updatedYear = updated.date.year;
      
      // Case 1: Original was income, updated is not income
      if (original.type == TransactionType.income && updated.type != TransactionType.income) {
        await _decreaseBudgetForDeletedIncome(original);
      }
      // Case 2: Original was not income, updated is income
      else if (original.type != TransactionType.income && updated.type == TransactionType.income) {
        await _updateBudgetForIncome(updated);
      }
      // Case 3: Both are income but amount or date changed
      else if (original.type == TransactionType.income && updated.type == TransactionType.income) {
        // If date changed, need to adjust both old and new month budgets
        if (month != updatedMonth || year != updatedYear) {
          await _decreaseBudgetForDeletedIncome(original);
          await _updateBudgetForIncome(updated);
        }
        // If only amount changed, adjust the budget accordingly
        else if (original.amount != updated.amount) {
          final amountDifference = updated.amount - original.amount;
          final existingBudget = await DatabaseService.instance.getBudget(month, year);
          
          if (existingBudget != null) {
            final updatedBudget = Budget(
              id: existingBudget.id,
              month: month,
              year: year,
              amount: existingBudget.amount + amountDifference,
              plannedAmount: existingBudget.plannedAmount, // Keep original planned budget
            );
            await DatabaseService.instance.setBudget(updatedBudget);
          }
        }
      }
    } catch (error) {
      debugPrint('Error handling budget adjustment for update: $error');
    }
  }

  Future<void> _handleUpdateTransaction(Transaction transaction) async {
    try {
      // Get original transaction to compare changes
      final originalTransaction = await DatabaseService.instance.getTransactionById(transaction.id!);
      
      await DatabaseService.instance.updateTransaction(transaction);
      
      // Handle budget adjustments for income transactions
      if (originalTransaction != null) {
        await _handleBudgetAdjustmentForUpdate(originalTransaction, transaction);
      }
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully')),
        );
      }
    } catch (error) {
      debugPrint('Error updating transaction: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction: $error')),
        );
      }
    }
  }

  Future<void> _handleDeleteTransaction(int id) async {
    try {
      // Get transaction before deletion to check if it's income
      final transactionToDelete = await DatabaseService.instance.getTransactionById(id);
      
      await DatabaseService.instance.deleteTransaction(id);
      
      // If it was an income transaction, decrease the budget
      if (transactionToDelete != null && transactionToDelete.type == TransactionType.income) {
        await _decreaseBudgetForDeletedIncome(transactionToDelete);
      }
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
      }
    } catch (error) {
      debugPrint('Error deleting transaction: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting transaction: $error')),
        );
      }
    }
  }

  Future<void> _handleSetBudget(Budget budget) async {
    try {
      await DatabaseService.instance.setBudget(budget);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget set successfully')),
        );
      }
    } catch (error) {
      debugPrint('Error setting budget: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting budget: $error')),
        );
      }
    }
  }

  void _handleMonthChange(int month, int year) {
    setState(() {
      _currentMonth = month;
      _currentYear = year;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final titleFontSize = screenWidth < 600 ? 18.0 : 22.0;
            
            return Text(
              'Budget Manager',
              style: TextStyle(
                fontSize: titleFontSize, 
                fontWeight: FontWeight.bold
              ),
            );
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final horizontalMargin = screenWidth < 600 ? 16.0 : 24.0;
          final verticalMargin = screenWidth < 600 ? 8.0 : 12.0;
          
          return Column(
            children: [
              MonthSelector(
                currentMonth: _currentMonth,
                currentYear: _currentYear,
                monthNames: _monthNames,
                onMonthChange: _handleMonthChange,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalMargin, 
                  vertical: verticalMargin
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(screenWidth < 600 ? 4.0 : 6.0),
                  tabs: [
                    Tab(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(fontSize: screenWidth < 600 ? 10.0 : 12.0),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Transactions',
                        style: TextStyle(fontSize: screenWidth < 600 ? 10.0 : 12.0),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Budget',
                        style: TextStyle(fontSize: screenWidth < 600 ? 10.0 : 12.0),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Analytics',
                        style: TextStyle(fontSize: screenWidth < 600 ? 10.0 : 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading data...'),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          DashboardTab(
                            monthlyStats: _monthlyStats,
                            budget: _budget,
                            transactions: _transactions,
                            monthName: _monthNames[_currentMonth - 1],
                            year: _currentYear,
                            dailyExpenses: _dailyExpenses,
                            currentMonth: _currentMonth,
                          ),
                          TransactionsTab(
                            transactions: _transactions,
                            onAddTransaction: _handleAddTransaction,
                            onUpdateTransaction: _handleUpdateTransaction,
                            onDeleteTransaction: _handleDeleteTransaction,
                          ),
                          BudgetTab(
                            currentMonth: _currentMonth,
                            currentYear: _currentYear,
                            budget: _budget,
                            monthlyStats: _monthlyStats,
                            onSetBudget: _handleSetBudget,
                          ),
                          AnalyticsTab(
                            categoryExpenses: _categoryExpenses,
                            monthName: _monthNames[_currentMonth - 1],
                            year: _currentYear,
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}