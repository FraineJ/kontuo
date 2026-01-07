class CreditSimulation {
  final String id;
  final double amount;
  final double annualRate;
  final int months;
  final double monthlyPayment;
  final double totalInterest;
  final double totalPayment;
  final DateTime createdAt;

  CreditSimulation({
    required this.id,
    required this.amount,
    required this.annualRate,
    required this.months,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.createdAt, 
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'annualRate': annualRate,
    'months': months,
    'monthlyPayment': monthlyPayment,
    'totalInterest': totalInterest,
    'totalPayment': totalPayment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CreditSimulation.fromJson(Map<String, dynamic> json) {
    return CreditSimulation(
      id: json['id'],
      amount: json['amount'],
      annualRate: json['annualRate'],
      months: json['months'],
      monthlyPayment: json['monthlyPayment'],
      totalInterest: json['totalInterest'],
      totalPayment: json['totalPayment'],
      createdAt: DateTime.parse(json['createdAt']), 
    );
  }
}
