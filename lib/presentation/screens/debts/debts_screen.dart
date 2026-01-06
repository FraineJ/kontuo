import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/debt.dart';
import '../../../data/services/storage_service.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
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
      _debts = debts..sort((a, b) => b.startDate.compareTo(a.startDate));
      _isLoading = false;
    });
  }

  Future<void> _deleteDebt(Debt debt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Eliminar Deuda'),
        content: Text('¿Estás seguro de que quieres eliminar "${debt.name}"? Esta acción no se puede deshacer.'),
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
      await _storageService.deleteDebt(debt.id);
      _loadDebts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Deudas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
          : RefreshIndicator(
              color: AppTheme.positiveGreen,
              onRefresh: _loadDebts,
              child: _debts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay deudas registradas',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Registra tus deudas para hacer seguimiento',
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
                      itemCount: _debts.length,
                      itemBuilder: (context, index) {
                        final debt = _debts[index];
                        return _DebtListItem(
                          debt: debt,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddDebtScreen(debt: debt),
                              ),
                            );
                            _loadDebts();
                          },
                          onDelete: () => _deleteDebt(debt),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_debts',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddDebtScreen()),
          );
          _loadDebts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DebtListItem extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DebtListItem({
    required this.debt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = debt.progress;
    
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      debt.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '\$${debt.remainingAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.negativeRed,
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
                    progress > 0.5 ? AppTheme.positiveGreen : AppTheme.negativeRed,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% pagado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Total: \$${debt.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

