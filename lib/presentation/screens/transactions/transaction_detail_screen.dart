import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final StorageService _storageService = StorageService();
  Transaction? _transaction;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    _loadData();
  }

  Future<void> _loadData() async {
    final transaction = await _storageService.getTransactions().then((transactions) => 
      transactions.firstWhere((t) => t.id == widget.transaction.id, orElse: () => widget.transaction));
    final profile = await _storageService.getUserProfile();
    
    setState(() {
      _transaction = transaction;
      _userProfile = profile;
      _isLoading = false;
    });
  }

  String _getCurrencySymbol(String? currency) {
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
    return symbols[currency ?? 'USD'] ?? '\$';
  }

  String _getCategoryLabel(String category, TransactionType type) {
    if (type == TransactionType.income) {
      return AppConstants.incomeCategoryLabels[category] ?? category;
    } else {
      return AppConstants.expenseCategoryLabels[category] ?? category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);
    
    if (transactionDay == today) {
      return 'Hoy, ${DateFormat('HH:mm', 'es').format(date)}';
    } else if (transactionDay == today.subtract(const Duration(days: 1))) {
      return 'Ayer, ${DateFormat('HH:mm', 'es').format(date)}';
    } else {
      return DateFormat('EEEE, d MMMM y, HH:mm', 'es').format(date);
    }
  }

  Future<void> _deleteTransaction() async {
    if (_transaction == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Eliminar Transacción'),
        content: Text('¿Estás seguro de que quieres eliminar esta transacción de ${_getCurrencySymbol(_userProfile?.currency)}${_transaction!.amount.toStringAsFixed(0)}? Esta acción no se puede deshacer.'),
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

    if (confirmed == true && mounted) {
      await _storageService.deleteTransaction(_transaction!.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _transaction == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBackground,
          elevation: 0,
          title: const Text('Detalle de Transacción'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.positiveGreen),
        ),
      );
    }

    final currencySymbol = _getCurrencySymbol(_userProfile?.currency);
    final currencyFormat = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 0,
    );

    final isIncome = _transaction!.type == TransactionType.income;
    final color = isIncome ? AppTheme.positiveGreen : AppTheme.negativeRed;
    final categoryLabel = _getCategoryLabel(_transaction!.category, _transaction!.type);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Detalle de Transacción'),
        actions: [
          PopupMenuButton<String>(
            iconColor: AppTheme.textPrimary,
            color: AppTheme.cardBackground,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(transaction: _transaction),
                  ),
                ).then((_) => _loadData());
              } else if (value == 'delete') {
                _deleteTransaction();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppTheme.textPrimary, size: 20),
                    SizedBox(width: 12),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppTheme.negativeRed, size: 20),
                    SizedBox(width: 12),
                    Text('Eliminar', style: TextStyle(color: AppTheme.negativeRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.positiveGreen,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Card - Prominent
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.height,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isIncome ? 'Ingreso' : 'Gasto',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isIncome ? '+' : '-'}${currencyFormat.format(_transaction!.amount)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.category,
                        label: 'Categoría',
                        value: categoryLabel,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Fecha',
                        value: _formatDate(_transaction!.date),
                      ),
                      if (_transaction!.isRecurring) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.repeat,
                          label: 'Tipo',
                          value: 'Recurrente',
                          valueColor: AppTheme.accentBlue,
                        ),
                      ],
                      if (_transaction!.notes != null && _transaction!.notes!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Notas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _transaction!.notes!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_transaction!.tags.isNotEmpty) ...[
                        const Divider(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.label,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Etiquetas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _transaction!.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.borderColor,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Información',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'ID',
                        value: _transaction!.id.substring(0, 8),
                      ),
                      const SizedBox(height: 8),
                      _InfoItem(
                        label: 'Tipo',
                        value: isIncome ? 'Ingreso' : 'Gasto',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

