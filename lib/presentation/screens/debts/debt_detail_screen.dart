import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colombian_banks.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';
import 'add_debt_screen.dart';
import 'add_debt_payment_dialog.dart';

class DebtDetailScreen extends StatefulWidget {
  final Debt debt;

  const DebtDetailScreen({
    super.key,
    required this.debt,
  });

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final StorageService _storageService = StorageService();
  Debt? _debt;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
    _loadData();
  }

  Future<void> _loadData() async {
    final debt = await _storageService.getDebts().then((debts) => 
      debts.firstWhere((d) => d.id == widget.debt.id, orElse: () => widget.debt));
    final profile = await _storageService.getUserProfile();
    
    setState(() {
      _debt = debt;
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

  String _getDebtTypeLabel(DebtType type) {
    return AppConstants.debtTypeLabels[type.toString().split('.').last] ?? 'Otro';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es').format(date);
  }

  String? _getDaysRemaining() {
    if (_debt?.endDate == null) return null;
    final now = DateTime.now();
    final end = _debt!.endDate!;
    final difference = end.difference(now).inDays;
    
    if (difference < 0) return 'Vencida';
    if (difference == 0) return 'Hoy';
    if (difference == 1) return '1 día restante';
    return '$difference días restantes';
  }

  Future<void> _deleteDebt() async {
    if (_debt == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Eliminar Deuda'),
        content: Text('¿Estás seguro de que quieres eliminar "${_debt!.name}"? Esta acción no se puede deshacer.'),
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
      await _storageService.deleteDebt(_debt!.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _showAddPaymentDialog() async {
    if (_debt == null) return;
    
    final result = await AddDebtPaymentDialog.show(
      context,
      _debt!,
      _userProfile,
    );
    
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _debt == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBackground,
          elevation: 0,
          title: const Text('Detalle de Deuda'),
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

    final progress = _debt!.progress.clamp(0.0, 1.0);
    final isPaid = _debt!.isPaid;
    final bank = ColombianBanks.getBankByName(_debt!.name);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Detalle de Deuda'),
        actions: [
          PopupMenuButton<String>(
            iconColor: AppTheme.textPrimary,
            color: AppTheme.cardBackground,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddDebtScreen(debt: _debt),
                  ),
                ).then((_) => _loadData());
              } else if (value == 'delete') {
                _deleteDebt();
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
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.positiveGreen,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: isPaid ? 16 : 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card - Compact
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Bank logo if available
                                if (bank != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      bank.logoUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.account_balance,
                                            color: AppTheme.textTertiary,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _debt!.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getDebtTypeLabel(_debt!.type),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isPaid)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.positiveGreen.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppTheme.positiveGreen,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Pagada',
                                          style: TextStyle(
                                            color: AppTheme.positiveGreen,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _InfoItem(
                                    label: 'Inicio',
                                    value: _formatDate(_debt!.startDate),
                                  ),
                                  if (_debt!.endDate != null) ...[
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: AppTheme.borderColor,
                                    ),
                                    _InfoItem(
                                      label: 'Fin',
                                      value: _formatDate(_debt!.endDate!),
                                    ),
                                  ],
                                  if (_debt!.termMonths != null) ...[
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: AppTheme.borderColor,
                                    ),
                                    _InfoItem(
                                      label: 'Plazo',
                                      value: '${_debt!.termMonths} meses',
                                    ),
                                  ],
                                  if (_debt!.interestRate != null) ...[
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: AppTheme.borderColor,
                                    ),
                                    _InfoItem(
                                      label: 'Interés',
                                      value: '${_debt!.interestRate!.toStringAsFixed(1)}%',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress Card - Reorganized
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Amounts first - more visible
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: _AmountCard(
                                    label: 'Pagado',
                                    amount: _debt!.paidAmount,
                                    currencyFormat: currencyFormat,
                                    color: isPaid
                                        ? AppTheme.positiveGreen
                                        : AppTheme.accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _AmountCard(
                                    label: 'Total',
                                    amount: _debt!.totalAmount,
                                    currencyFormat: currencyFormat,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            if (!isPaid && _debt!.remainingAmount > 0) ...[
                              const SizedBox(height: 10),
                              _AmountCard(
                                label: 'Restante',
                                amount: _debt!.remainingAmount,
                                currencyFormat: currencyFormat,
                                color: AppTheme.negativeRed,
                                isFullWidth: true,
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Circular Progress - Smaller
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 10,
                                          backgroundColor: AppTheme.borderColor,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isPaid
                                                ? AppTheme.positiveGreen
                                                : AppTheme.accentBlue,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${(progress * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Pagado',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Linear Progress
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Progreso',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            '${currencyFormat.format(_debt!.paidAmount)} / ${currencyFormat.format(_debt!.totalAmount)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor: AppTheme.borderColor,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isPaid
                                                ? AppTheme.positiveGreen
                                                : AppTheme.accentBlue,
                                          ),
                                        ),
                                      ),
                                      // Time remaining
                                      if (_debt!.endDate != null && !isPaid) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              color: AppTheme.textSecondary,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                _getDaysRemaining() ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isPaid) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.positiveGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.positiveGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.celebration,
                              color: AppTheme.positiveGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '¡Deuda pagada!',
                              style: const TextStyle(
                                color: AppTheme.positiveGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Fixed button at bottom
          if (!isPaid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: _showAddPaymentDialog,
                  icon: const Icon(Icons.payment),
                  label: const Text('Realizar Pago'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.positiveGreen,
                    foregroundColor: AppTheme.textPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String label;
  final double amount;
  final NumberFormat currencyFormat;
  final Color color;
  final bool isFullWidth;

  const _AmountCard({
    required this.label,
    required this.amount,
    required this.currencyFormat,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
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

