import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';
import 'add_goal_screen.dart';
import 'add_payment_dialog.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({
    super.key,
    required this.goal,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final StorageService _storageService = StorageService();
  Goal? _goal;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _loadData();
  }

  Future<void> _loadData() async {
    final goal = await _storageService.getGoals().then((goals) => 
      goals.firstWhere((g) => g.id == widget.goal.id, orElse: () => widget.goal));
    final profile = await _storageService.getUserProfile();
    
    setState(() {
      _goal = goal;
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

  String _getTimeframeLabel(GoalTimeframe timeframe) {
    switch (timeframe) {
      case GoalTimeframe.short:
        return 'Corto Plazo';
      case GoalTimeframe.medium:
        return 'Mediano Plazo';
      case GoalTimeframe.long:
        return 'Largo Plazo';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es').format(date);
  }

  String? _getDaysRemaining() {
    if (_goal?.targetDate == null) return null;
    final now = DateTime.now();
    final target = _goal!.targetDate!;
    final difference = target.difference(now).inDays;
    
    if (difference < 0) return 'Vencida';
    if (difference == 0) return 'Hoy';
    if (difference == 1) return '1 día restante';
    return '$difference días restantes';
  }

  double get _remainingAmount {
    if (_goal == null) return 0;
    final remaining = _goal!.targetAmount - _goal!.currentAmount;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> _deleteGoal() async {
    if (_goal == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Eliminar Meta'),
        content: Text('¿Estás seguro de que quieres eliminar "${_goal!.name}"? Esta acción no se puede deshacer.'),
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
      await _storageService.deleteGoal(_goal!.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _showAddPaymentDialog() async {
    if (_goal == null) return;
    
    final result = await AddPaymentDialog.show(context, _goal!);
    
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _goal == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.darkBackground,
          elevation: 0,
          title: const Text('Detalle de Meta'),
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

    final progress = _goal!.progress.clamp(0.0, 1.0);
    final isCompleted = _goal!.isCompleted;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Detalle de Meta'),
        actions: [
          PopupMenuButton<String>(
            iconColor: AppTheme.textPrimary,
            color: AppTheme.cardBackground,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddGoalScreen(goal: _goal),
                  ),
                ).then((_) => _loadData());
              } else if (value == 'delete') {
                _deleteGoal();
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
                  bottom: isCompleted ? 16 : 80,
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _goal!.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (_goal!.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _goal!.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isCompleted)
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
                                          'Completada',
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
                                    label: 'Plazo',
                                    value: _getTimeframeLabel(_goal!.timeframe),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: AppTheme.borderColor,
                                  ),
                                  _InfoItem(
                                    label: 'Creada',
                                    value: _formatDate(_goal!.createdAt),
                                  ),
                                  if (_goal!.targetDate != null) ...[
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: AppTheme.borderColor,
                                    ),
                                    _InfoItem(
                                      label: 'Objetivo',
                                      value: _formatDate(_goal!.targetDate!),
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
                                    label: 'Actual',
                                    amount: _goal!.currentAmount,
                                    currencyFormat: currencyFormat,
                                    color: isCompleted
                                        ? AppTheme.positiveGreen
                                        : AppTheme.accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _AmountCard(
                                    label: 'Objetivo',
                                    amount: _goal!.targetAmount,
                                    currencyFormat: currencyFormat,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
            
                            if (!isCompleted && _remainingAmount > 0) ...[
                              const SizedBox(height: 10),
                              _AmountCard(
                                label: 'Faltante',
                                amount: _remainingAmount,
                                currencyFormat: currencyFormat,
                                color: AppTheme.textTertiary,
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
                                            isCompleted
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
                                            'Completado',
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
                                            '${currencyFormat.format(_goal!.currentAmount)} / ${currencyFormat.format(_goal!.targetAmount)}',
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
                                            isCompleted
                                                ? AppTheme.positiveGreen
                                                : AppTheme.accentBlue,
                                          ),
                                        ),
                                      ),
                                      // Time remaining
                                      if (_goal!.targetDate != null && !isCompleted) ...[
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
            
                    if (isCompleted) ...[
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
                              '¡Meta completada!',
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
          if (!isCompleted)
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
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Abono'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.positiveGreen,
                    foregroundColor: AppTheme.darkBackground,
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

