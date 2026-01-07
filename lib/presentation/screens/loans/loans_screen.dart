import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colombian_banks.dart';
import '../../../data/models/loan.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/storage_service.dart';
import 'add_loan_screen.dart';
import 'add_loan_payment_dialog.dart';
import 'loan_detail_screen.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
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
      _loans = loans..sort((a, b) => b.startDate.compareTo(a.startDate));
      _userProfile = profile;
      _isLoading = false;
    });
  }

  Future<void> _loadLoans() async {
    final loans = await _storageService.getLoans();
    setState(() {
      _loans = loans..sort((a, b) => b.startDate.compareTo(a.startDate));
    });
  }

  Future<void> _deleteLoan(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Eliminar Préstamo'),
        content: Text('¿Estás seguro de que quieres eliminar "${loan.name}"? Esta acción no se puede deshacer.'),
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
      await _storageService.deleteLoan(loan.id);
      _loadLoans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Préstamos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
          : RefreshIndicator(
              color: AppTheme.positiveGreen,
              onRefresh: _loadLoans,
              child: _loans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay préstamos registrados',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Registra tus préstamos para hacer seguimiento',
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
                      itemCount: _loans.length,
                      itemBuilder: (context, index) {
                        final loan = _loans[index];
                        return _LoanListItem(
                          loan: loan,
                          userProfile: _userProfile,
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoanDetailScreen(loan: loan,),
                              ),
                            );
                            if (result == true) {
                              _loadLoans();
                            }
                          },
                          onEdit: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddLoanScreen(loan: loan),
                              ),
                            );
                            _loadLoans();
                          },
                          onDelete: () => _deleteLoan(loan),
                          onPayment: () async {
                            final result = await AddLoanPaymentDialog.show(
                              context,
                              loan,
                              _userProfile,
                            );
                            if (result == true) {
                              _loadLoans();
                            }
                          },
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_loans',
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddLoanScreen()),
          );
          if (result == true) _loadLoans();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LoanListItem extends StatelessWidget {
  final Loan loan;
  final UserProfile? userProfile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPayment;

  const _LoanListItem({
    required this.loan,
    this.userProfile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
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
                    leading: const Icon(Icons.visibility, color: AppTheme.textPrimary),
                    title: const Text('Ver Detalle'),
                    onTap: () {
                      Navigator.of(context).pop();
                      onTap();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppTheme.textPrimary),
                    title: const Text('Editar'),
                    onTap: () {
                      Navigator.of(context).pop();
                      onEdit();
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
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              bank.logoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_balance,
                                    color: AppTheme.textTertiary,
                                    size: 20,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
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
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            loan.name,
                            style: const TextStyle(
                              fontSize: 16,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.positiveGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.5 ? AppTheme.positiveGreen : AppTheme.positiveGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% cobrado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Total: ${currencyFormat.format(loan.totalAmount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              if (!loan.isCollected) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onPayment,
                    icon: const Icon(Icons.attach_money, size: 16),
                    label: const Text('Registrar Cobro', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.positiveGreen,
                      side: const BorderSide(color: AppTheme.positiveGreen),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
