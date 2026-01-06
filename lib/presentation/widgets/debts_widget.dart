import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/debt.dart';
import '../../data/services/storage_service.dart';
import '../screens/debts/debts_screen.dart';

class DebtsWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const DebtsWidget({super.key, required this.onRefresh});

  @override
  State<DebtsWidget> createState() => _DebtsWidgetState();
}

class _DebtsWidgetState extends State<DebtsWidget> {
  final StorageService _storageService = StorageService();
  List<Debt> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final debts = await _storageService.getDebts();
    setState(() {
      _debts = debts.where((d) => !d.isPaid).take(3).toList();
      _isLoading = false;
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
                        return _DebtTile(debt: debt);
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final Debt debt;

  const _DebtTile({required this.debt});

  @override
  Widget build(BuildContext context) {
    final progress = debt.progress;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                debt.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '\$${debt.remainingAmount.toStringAsFixed(0)}',
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
          Text(
            '${(progress * 100).toInt()}% pagado',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}


