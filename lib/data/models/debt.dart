enum DebtType { personalLoan, creditCard, mortgage, other }

class Debt {
  final String id;
  final String name;
  final DebtType type;
  final double totalAmount;
  final double remainingAmount;
  final double? interestRate;
  final int? termMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final bool hasReminders;

  Debt({
    required this.id,
    required this.name,
    required this.type,
    required this.totalAmount,
    required this.remainingAmount,
    this.interestRate,
    this.termMonths,
    required this.startDate,
    this.endDate,
    this.hasReminders = false,
  });

  double get progress => totalAmount > 0 ? (totalAmount - remainingAmount) / totalAmount : 0;
  double get paidAmount => totalAmount - remainingAmount;
  bool get isPaid => remainingAmount <= 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'interest_rate': interestRate,
      'term_months': termMonths,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'has_reminders': hasReminders,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    DebtType type;
    switch (json['type']) {
      case 'personalLoan':
        type = DebtType.personalLoan;
        break;
      case 'creditCard':
        type = DebtType.creditCard;
        break;
      case 'mortgage':
        type = DebtType.mortgage;
        break;
      default:
        type = DebtType.other;
    }

    return Debt(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: type,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      interestRate: json['interest_rate']?.toDouble(),
      termMonths: json['term_months'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      hasReminders: json['has_reminders'] ?? false,
    );
  }

  Debt copyWith({
    String? id,
    String? name,
    DebtType? type,
    double? totalAmount,
    double? remainingAmount,
    double? interestRate,
    int? termMonths,
    DateTime? startDate,
    DateTime? endDate,
    bool? hasReminders,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hasReminders: hasReminders ?? this.hasReminders,
    );
  }
}

