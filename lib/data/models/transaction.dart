enum TransactionType { expense, income }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final List<String> tags;
  final bool isRecurring;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.tags = const [],
    this.isRecurring = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == TransactionType.expense ? 'expense' : 'income',
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'is_recurring': isRecurring,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      type: json['type'] == 'expense'
          ? TransactionType.expense
          : TransactionType.income,
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      isRecurring: json['is_recurring'] ?? false,
    );
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    List<String>? tags,
    bool? isRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}


