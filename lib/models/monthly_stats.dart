class MonthlyStats {
  final double income;
  final double expenses;
  final double balance;
  final int transactionCount;

  MonthlyStats({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.transactionCount,
  });

  static MonthlyStats empty() {
    return MonthlyStats(
      income: 0.0,
      expenses: 0.0,
      balance: 0.0,
      transactionCount: 0,
    );
  }

  MonthlyStats copyWith({
    double? income,
    double? expenses,
    double? balance,
    int? transactionCount,
  }) {
    return MonthlyStats(
      income: income ?? this.income,
      expenses: expenses ?? this.expenses,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}

class DailyExpense {
  final String date;
  final double totalExpenses;

  DailyExpense({
    required this.date,
    required this.totalExpenses,
  });

  static DailyExpense fromMap(Map<String, dynamic> map) {
    return DailyExpense(
      date: map['date'],
      totalExpenses: map['total_expenses'].toDouble(),
    );
  }
}