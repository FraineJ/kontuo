import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/transaction.dart';

class FinancialSummaryCard extends StatelessWidget {
  final UserProfile profile;
  final List<Transaction> transactions;

  const FinancialSummaryCard({
    super.key,
    required this.profile,
    required this.transactions,
  });

  double _calculateBalance() {
    double income = 0;
    double expenses = 0;

    final now = DateTime.now();

    for (var transaction in transactions) {
      // Incluir todas las transacciones del mes actual
      if (transaction.date.year == now.year && 
          transaction.date.month == now.month) {
        if (transaction.type == TransactionType.income) {
          income += transaction.amount;
        } else {
          expenses += transaction.amount;
        }
      }
    }

    return income - expenses;
  }

  double _calculateMonthlyIncome() {
    final now = DateTime.now();
    
    return transactions
        .where((t) => 
            t.type == TransactionType.income && 
            t.date.year == now.year && 
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateMonthlyExpenses() {
    final now = DateTime.now();
    
    return transactions
        .where((t) => 
            t.type == TransactionType.expense && 
            t.date.year == now.year && 
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: _getCurrencySymbol(profile.currency));
    final balance = _calculateBalance();
    final income = _calculateMonthlyIncome();
    final expenses = _calculateMonthlyExpenses();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Actual',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(balance),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: balance >= 0 ? AppTheme.positiveGreen : AppTheme.negativeRed,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildIndicator(
                  'Ingresos',
                  currencyFormat.format(income),
                  AppTheme.positiveGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIndicator(
                  'Gastos',
                  currencyFormat.format(expenses),
                  AppTheme.negativeRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getCurrencySymbol(String currency) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'CAD': '\$',
      'AUD': '\$',
      'MXN': '\$',
      'BRL': 'R\$',
      'ARS': '\$',
      'CLP': '\$',
      'COP': '\$',
      'PEN': 'S/',
    };
    return symbols[currency] ?? '\$';
  }
}

