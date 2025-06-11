class Transaction {
  final int? id;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.toString().split('.').last,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      date: DateTime.parse(map['date']),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Transaction copyWith({
    int? id,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum TransactionType { income, expense }