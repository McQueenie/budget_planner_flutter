class Budget {
  final int? id;
  final int month;
  final int year;
  final double amount;          // Total budget (planned + income)
  final double plannedAmount;   // Original planned budget set by user
  final DateTime? createdAt;

  Budget({
    this.id,
    required this.month,
    required this.year,
    required this.amount,
    required this.plannedAmount,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'amount': amount,
      'planned_amount': plannedAmount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static Budget fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      month: map['month'],
      year: map['year'],
      amount: map['amount'].toDouble(),
      plannedAmount: (map['planned_amount'] ?? map['amount']).toDouble(), // Fallback for existing data
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Budget copyWith({
    int? id,
    int? month,
    int? year,
    double? amount,
    double? plannedAmount,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}