import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:budget_planner_flutter/models/transaction.dart';
import 'package:budget_planner_flutter/models/budget.dart';
import 'package:budget_planner_flutter/models/monthly_stats.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'budget.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        date TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        amount REAL NOT NULL,
        planned_amount REAL NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(month, year)
      )
    ''');
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add planned_amount column to existing budgets table
      await db.execute('ALTER TABLE budgets ADD COLUMN planned_amount REAL DEFAULT 0');
      
      // Update existing budgets to set planned_amount equal to current amount
      await db.execute('UPDATE budgets SET planned_amount = amount WHERE planned_amount IS NULL OR planned_amount = 0');
    }
  }

  Future<int> addTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions({int? month, int? year}) async {
    final db = await database;
    String query = 'SELECT * FROM transactions';
    List<dynamic> params = [];

    if (month != null && year != null) {
      query += ' WHERE strftime("%m", date) = ? AND strftime("%Y", date) = ?';
      params = [month.toString().padLeft(2, '0'), year.toString()];
    }

    query += ' ORDER BY date DESC';

    final result = await db.rawQuery(query, params);
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) return null;
    return Transaction.fromMap(result.first);
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> setBudget(Budget budget) async {
    final db = await database;
    return await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Budget?> getBudget(int month, int year) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    if (result.isEmpty) return null;
    return Budget.fromMap(result.first);
  }

  Future<MonthlyStats> getMonthlyStats(int month, int year) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final yearStr = year.toString();

    final result = await db.rawQuery('''
      SELECT 
        type,
        SUM(amount) as total,
        COUNT(*) as count
      FROM transactions 
      WHERE strftime("%m", date) = ? AND strftime("%Y", date) = ?
      GROUP BY type
    ''', [monthStr, yearStr]);

    double income = 0;
    double expenses = 0;
    int transactionCount = 0;

    for (final row in result) {
      if (row['type'] == 'income') {
        income = (row['total'] as num).toDouble();
      } else if (row['type'] == 'expense') {
        expenses = (row['total'] as num).toDouble();
      }
      transactionCount += (row['count'] as int);
    }

    return MonthlyStats(
      income: income,
      expenses: expenses,
      balance: income - expenses,
      transactionCount: transactionCount,
    );
  }

  Future<Map<String, double>> getCategoryExpenses(int month, int year) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final yearStr = year.toString();

    final result = await db.rawQuery('''
      SELECT 
        description,
        SUM(amount) as total_amount
      FROM transactions 
      WHERE type = 'expense' 
        AND strftime("%m", date) = ? 
        AND strftime("%Y", date) = ?
      GROUP BY description
      ORDER BY total_amount DESC
    ''', [monthStr, yearStr]);

    final Map<String, double> categories = {};
    
    for (final row in result) {
      final description = row['description'] as String;
      final amount = (row['total_amount'] as num).toDouble();
      categories[description] = amount;
    }
    
    return categories;
  }

  Future<List<DailyExpense>> getDailyExpenses(int month, int year) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final yearStr = year.toString();

    final result = await db.rawQuery('''
      SELECT 
        date,
        SUM(amount) as total_expenses
      FROM transactions 
      WHERE type = 'expense' 
        AND strftime("%m", date) = ? 
        AND strftime("%Y", date) = ?
      GROUP BY date
      ORDER BY date ASC
    ''', [monthStr, yearStr]);

    return result.map((map) => DailyExpense.fromMap(map)).toList();
  }
}