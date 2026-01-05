import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/transaction.dart';
import '../../data/services/storage_service.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/transactions/transactions_screen.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onRefresh;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  List<Transaction> _getRecentTransactions() {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recent = _getRecentTransactions();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transacciones Recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                  ).then((_) => onRefresh());
                },
                child: Text(
                  'Ver todas',
                  style: TextStyle(color: AppTheme.positiveGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          recent.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay transacciones',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddTransactionScreen(),
                              ),
                            ).then((_) => onRefresh());
                          },
                          child: Text(
                            'Agregar transacción',
                            style: TextStyle(color: AppTheme.positiveGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: recent.map((transaction) {
                    return _TransactionTile(transaction: transaction);
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.positiveGreen : AppTheme.negativeRed;
    final categoryLabel = isIncome
        ? AppConstants.incomeCategoryLabels[transaction.category] ?? transaction.category
        : AppConstants.expenseCategoryLabels[transaction.category] ?? transaction.category;
    
    final dateFormat = DateFormat('MMM d', 'es');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(transaction.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

