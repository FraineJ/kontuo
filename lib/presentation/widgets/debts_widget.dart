import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/colombian_banks.dart';
import '../../data/models/debt.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/storage_service.dart';
import '../screens/debts/debts_screen.dart';
import '../screens/debts/add_debt_payment_dialog.dart';

class DebtsWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const DebtsWidget({super.key, required this.onRefresh});

  @override
  State<DebtsWidget> createState() => _DebtsWidgetState();
}

class _DebtsWidgetState extends State<DebtsWidget> {
  final StorageService _storageService = StorageService();
  List<Debt> _debts = [];
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final debts = await _storageService.getDebts();
    final profile = await _storageService.getUserProfile();
    setState(() {
      _debts = debts.where((d) => !d.isPaid).take(3).toList();
      _userProfile = profile;
      _isLoading = false;
    });
  }

  Future<void> _loadDebts() async {
    final debts = await _storageService.getDebts();
    final profile = await _storageService.getUserProfile();
    setState(() {
      _debts = debts.where((d) => !d.isPaid).take(3).toList();
      _userProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                'Deudas Vigentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DebtsScreen()),
                  ).then((_) {
                    _loadDebts();
                    widget.onRefresh();
                  });
                },
                child: Text(
                  'Ver todas',
                  style: TextStyle(color: AppTheme.positiveGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
              : _debts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 48,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay deudas registradas',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _debts.map((debt) {
                        return _DebtTile(
                          debt: debt,
                          userProfile: _userProfile,
                          onPayment: () async {
                            final result = await AddDebtPaymentDialog.show(
                              context,
                              debt,
                              _userProfile,
                            );
                            if (result == true) {
                              _loadDebts();
                              widget.onRefresh();
                            }
                          },
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final Debt debt;
  final UserProfile? userProfile;
  final VoidCallback onPayment;

  const _DebtTile({
    required this.debt,
    this.userProfile,
    required this.onPayment,
  });

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

  @override
  Widget build(BuildContext context) {
    final progress = debt.progress;
    final bank = ColombianBanks.getBankByName(debt.name);
    final currencyFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(userProfile?.currency),
      decimalDigits: 0,
    );
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Logo del banco si existe
                    if (bank != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          bank.logoUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: AppTheme.textTertiary,
                                size: 16,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppTheme.positiveGreen,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        debt.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(debt.remainingAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.negativeRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.5 ? AppTheme.positiveGreen : AppTheme.negativeRed,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% pagado',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              if (!debt.isPaid)
                TextButton(
                  onPressed: onPayment,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Pagar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.positiveGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


