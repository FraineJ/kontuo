import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/goal.dart';
import '../../../data/services/storage_service.dart';

class AddPaymentDialog extends StatefulWidget {
  final Goal goal;

  const AddPaymentDialog({super.key, required this.goal});

  static Future<bool?> show(BuildContext context, Goal goal) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddPaymentDialog(goal: goal),
    );
  }

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _amountController = TextEditingController();
  final _storageService = StorageService();
  bool _isProcessing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double get _remainingAmount =>
      widget.goal.targetAmount - widget.goal.currentAmount;

  Future<void> _savePayment() async {
    final value = _amountController.text.trim();
    if (value.isEmpty) return;

    final amount = double.tryParse(value.replaceAll(',', '')) ?? 0;
    if (amount <= 0 || amount > _remainingAmount) return;

    setState(() => _isProcessing = true);

    final newAmount = widget.goal.currentAmount + amount;
    final finalAmount = newAmount > widget.goal.targetAmount
        ? widget.goal.targetAmount
        : newAmount;

    await _storageService.updateGoal(
        widget.goal.copyWith(currentAmount: finalAmount)
    );

    if (mounted) Navigator.of(context).pop(true);
  }

  void _setQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(symbol: '\$');
    final progress = widget.goal.progress;
    final amountText = _amountController.text;

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Padding(
        // Padding alrededor del diálogo para que no toque los bordes de la pantalla
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          constraints: BoxConstraints(
            // Limita la altura máxima al 85% de la pantalla
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            // Establece una altura mínima
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            // Sombra sutil para separación visual
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false, // No usar SafeArea en la parte superior para que se vea el redondeado
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra de agarre (opcional, para indicar que se puede arrastrar)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Agregar abono',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _savePayment,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Listo',
                            style: TextStyle(
                              color: amountText.isNotEmpty
                                  ? AppTheme.positiveGreen
                                  : AppTheme.textTertiary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido desplazable
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Info de la meta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.goal.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(progress * 100).toInt()}% completado',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.positiveGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.flag,
                                color: AppTheme.positiveGreen,
                                size: 24,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Campo de monto
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextFormField(
                            controller: _amountController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              labelText: 'Monto',
                              hintText: '0.00',
                              prefixText: '\$ ',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                            ],
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa un monto';
                              }
                              final amount = double.tryParse(value.replaceAll(',', ''));
                              if (amount == null || amount <= 0) {
                                return 'Ingresa un monto válido';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Montos rápidos
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickAmountChip(
                              label: '25%',
                              amount: _remainingAmount * 0.25,
                              onTap: _setQuickAmount,
                            ),
                            _QuickAmountChip(
                              label: '50%',
                              amount: _remainingAmount * 0.5,
                              onTap: _setQuickAmount,
                            ),
                            _QuickAmountChip(
                              label: '75%',
                              amount: _remainingAmount * 0.75,
                              onTap: _setQuickAmount,
                            ),
                            _QuickAmountChip(
                              label: '100%',
                              amount: _remainingAmount,
                              onTap: _setQuickAmount,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Info de montos
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Faltante',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    format.format(_remainingAmount),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    format.format(widget.goal.targetAmount),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Espacio extra para el teclado
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final double amount;
  final Function(double) onTap;

  const _QuickAmountChip({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}