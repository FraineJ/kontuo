import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/transaction.dart';

class FinancialSummaryCard extends StatefulWidget {
  final UserProfile profile;
  final List<Transaction> transactions;

  const FinancialSummaryCard({
    super.key,
    required this.profile,
    required this.transactions,
  });

  @override
  State<FinancialSummaryCard> createState() => _FinancialSummaryCardState();
}

class _FinancialSummaryCardState extends State<FinancialSummaryCard>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true; // Inicialmente visible
  late AnimationController _animationController;
  late Animation<double> _balanceAnimation;
  late Animation<double> _incomeAnimation;
  late Animation<double> _expenseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _initializeAnimations();

    // Iniciar animación automáticamente cuando se muestra por primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isVisible) {
        _animationController.forward();
      }
    });
  }

  void _initializeAnimations() {
    final balance = _calculateBalance();
    final income = _calculateMonthlyIncome();
    final expenses = _calculateMonthlyExpenses();

    _balanceAnimation = Tween<double>(begin: 0, end: balance).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _incomeAnimation = Tween<double>(begin: 0, end: income).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _expenseAnimation = Tween<double>(begin: 0, end: expenses).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(FinancialSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si los valores cambian, actualizar las animaciones
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.profile != widget.profile) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final balance = _calculateBalance();
    final income = _calculateMonthlyIncome();
    final expenses = _calculateMonthlyExpenses();

    final currentBalance = _balanceAnimation.value;
    final currentIncome = _incomeAnimation.value;
    final currentExpense = _expenseAnimation.value;

    _balanceAnimation = Tween<double>(
      begin: currentBalance,
      end: balance,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _incomeAnimation = Tween<double>(
      begin: currentIncome,
      end: income,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _expenseAnimation = Tween<double>(
      begin: currentExpense,
      end: expenses,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (_isVisible) {
      if (_animationController.status == AnimationStatus.completed ||
          _animationController.status == AnimationStatus.forward) {
        _animationController.reset();
      }
      _animationController.forward();
    }
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _updateAnimations();
        _animationController.forward();
      } else {
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateBalance() {
    double income = 0;
    double expenses = 0;

    // Incluir TODAS las transacciones históricas para el balance total
    for (var transaction in widget.transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }

    return income - expenses;
  }

  double _calculateMonthlyIncome() {
    final now = DateTime.now();
    
    return widget.transactions
        .where((t) => 
            t.type == TransactionType.income && 
            t.date.year == now.year && 
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateMonthlyExpenses() {
    final now = DateTime.now();
    
    return widget.transactions
        .where((t) => 
            t.type == TransactionType.expense && 
            t.date.year == now.year && 
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(widget.profile.currency),
      decimalDigits: 0,
    );
    final balance = _calculateBalance();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Header con botón de toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance Actual',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isVisible ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                onPressed: _toggleVisibility,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Balance con animación y FittedBox
          AnimatedBuilder(
            animation: _balanceAnimation,
            builder: (context, child) {
              final animatedBalance = _isVisible ? _balanceAnimation.value : 0.0;
              final displayBalance = _isVisible ? animatedBalance : 0.0;
              
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _isVisible ? currencyFormat.format(displayBalance) : '••••••••',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: _isVisible && balance >= 0
                        ? AppTheme.positiveGreen
                        : _isVisible
                            ? AppTheme.negativeRed
                            : AppTheme.textTertiary,
                    letterSpacing: -1,
                  ),
                  maxLines: 1,
                ),
              );
            },
          ),
          if (_isVisible) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIndicator(
                  'Ingresos',
                  _incomeAnimation,
                  AppTheme.positiveGreen,
                  currencyFormat,
                ),
                const SizedBox(width: 16),
                _buildIndicator(
                  'Gastos',
                  _expenseAnimation,
                  AppTheme.negativeRed,
                  currencyFormat,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(
    String label,
    Animation<double> animation,
    Color color,
    NumberFormat currencyFormat,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
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
              _isVisible ? currencyFormat.format(animation.value) : '••••',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _isVisible ? color : AppTheme.textTertiary,
              ),
            ),
          ],
        );
      },
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

