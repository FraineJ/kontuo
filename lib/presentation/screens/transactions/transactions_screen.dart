import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/storage_service.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final StorageService _storageService = StorageService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _storageService.getTransactions();
    setState(() {
      _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Eliminar Transacción'),
        content: const Text('¿Estás seguro de que quieres eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.negativeRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteTransaction(transaction.id);
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Transacciones'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
          : RefreshIndicator(
              color: AppTheme.positiveGreen,
              onRefresh: _loadTransactions,
              child: _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay transacciones',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega tu primera transacción',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return _TransactionListItem(
                          transaction: transaction,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(transaction: transaction),
                              ),
                            );
                            _loadTransactions();
                          },
                          onDelete: () => _deleteTransaction(transaction),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          _loadTransactions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TransactionListItem({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.positiveGreen : AppTheme.negativeRed;
    final categoryLabel = isIncome
        ? AppConstants.incomeCategoryLabels[transaction.category] ?? transaction.category
        : AppConstants.expenseCategoryLabels[transaction.category] ?? transaction.category;
    
    final dateFormat = DateFormat('MMM d, y', 'es');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isToday = transaction.date.year == DateTime.now().year &&
        transaction.date.month == DateTime.now().month &&
        transaction.date.day == DateTime.now().day;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(
          categoryLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          isToday ? 'Hoy' : dateFormat.format(transaction.date),
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            if (transaction.isRecurring)
              Text(
                'Recurrente',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiary,
                ),
              ),
          ],
        ),
        onTap: onTap,
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppTheme.cardBackground,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppTheme.textPrimary),
                    title: const Text('Editar'),
                    onTap: () {
                      Navigator.of(context).pop();
                      onTap();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: AppTheme.negativeRed),
                    title: const Text('Eliminar', style: TextStyle(color: AppTheme.negativeRed)),
                    onTap: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

