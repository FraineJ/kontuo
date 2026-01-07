enum LoanType { personalLoan, creditCard, mortgage, other }

class Loan {
  final String id;
  final String name;
  final LoanType type;
  final double totalAmount;
  final double remainingAmount;
  final double? interestRate;
  final int? termMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final bool hasReminders;

  Loan({
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
  double get collectedAmount => totalAmount - remainingAmount;
  bool get isCollected => remainingAmount <= 0;

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

  factory Loan.fromJson(Map<String, dynamic> json) {
    LoanType type;
    switch (json['type']) {
      case 'personalLoan':
        type = LoanType.personalLoan;
        break;
      case 'creditCard':
        type = LoanType.creditCard;
        break;
      case 'mortgage':
        type = LoanType.mortgage;
        break;
      default:
        type = LoanType.other;
    }

    return Loan(
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

  Loan copyWith({
    String? id,
    String? name,
    LoanType? type,
    double? totalAmount,
    double? remainingAmount,
    double? interestRate,
    int? termMonths,
    DateTime? startDate,
    DateTime? endDate,
    bool? hasReminders,
  }) {
    return Loan(
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
