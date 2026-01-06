import 'dart:math' as Math;

import 'package:kontuo/data/models/credit_simulation.dart';

class CreditCalculator {
  static CreditSimulation simulate({
    required double amount,
    required double annualRate,
    required int months,
  }) {
    final monthlyRate = annualRate / 12 / 100;

    final cuota = amount *
        (monthlyRate * Math.pow(1 + monthlyRate, months)) /
        (Math.pow(1 + monthlyRate, months) - 1);

    final totalPayment = cuota * months;
    final interest = totalPayment - amount;

    return CreditSimulation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      annualRate: annualRate,
      months: months,
      monthlyPayment: cuota,
      totalInterest: interest,
      totalPayment: totalPayment,
      createdAt: DateTime.now(),
    );
  }
}
