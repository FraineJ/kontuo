import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/colombian_banks.dart';
import '../../data/models/loan.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/storage_service.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/loans/add_loan_payment_dialog.dart';

class LoansWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const LoansWidget({super.key, required this.onRefresh});

  @override
  State<LoansWidget> createState() => _LoansWidgetState();
}

class _LoansWidgetState extends State<LoansWidget> {
  final StorageService _storageService = StorageService();
  List<Loan> _loans = [];
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loans = await _storageService.getLoans();
    final profile = await _storageService.getUserProfile();
    setState(() {
      _loans = loans.where((d) => !d.isCollected).take(3).toList();
      _userProfile = profile;
      _isLoading = false;
    });
  }

  Future<void> _loadLoans() async {
    final loans = await _storageService.getLoans();
    final profile = await _storageService.getUserProfile();
    setState(() {
      _loans = loans.where((d) => !d.isCollected).take(3).toList();
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
                'Préstamos Vigentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoansScreen()),
                  ).then((_) {
                    _loadData();
                    widget.onRefresh();
                  });
                },
                child: Text(
                  'Ver todos',
                  style: TextStyle(color: AppTheme.positiveGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
              : _loans.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 48,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay préstamos registrados',
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
                      children: _loans.map((loan) {
                        return _LoanTile(
                          loan: loan,
                          userProfile: _userProfile,
                          onPayment: () async {
                            final result = await AddLoanPaymentDialog.show(
                              context,
                              loan,
                              _userProfile,
                            );
                            if (result == true) {
                              _loadData();
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

class _LoanTile extends StatelessWidget {
  final Loan loan;
  final UserProfile? userProfile;
  final VoidCallback onPayment;

  const _LoanTile({
    required this.loan,
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
    final progress = loan.progress;
    final bank = ColombianBanks.getBankByName(loan.name);
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
                    if (bank != null)
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
                    Expanded(
                      child: Text(
                        loan.name,
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
                    currencyFormat.format(loan.remainingAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.positiveGreen,
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.positiveGreen),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% cobrado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  if (!loan.isCollected)
                    TextButton(
                      onPressed: onPayment,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Cobrar',
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