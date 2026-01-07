import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/credit_simulation.dart';
import '../../../data/services/credit_storage_service.dart';

/// ===============================
/// ENUM PERIODO DE TASA
/// ===============================

class CreditSimulationScreen extends StatefulWidget {
  const CreditSimulationScreen({super.key});

  @override
  State<CreditSimulationScreen> createState() => _CreditSimulationScreenState();
}

class _CreditSimulationScreenState extends State<CreditSimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final CreditSimulationService _service = CreditSimulationService();

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _rateCtrl = TextEditingController();
  final TextEditingController _monthsCtrl = TextEditingController();

  CreditSimulation? _result;

  final currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  /// ===============================
  /// SIMULACIÓN
  /// ===============================
  void _simulate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountCtrl.text);
    final monthlyRatePercent = double.parse(_rateCtrl.text);
    final months = int.parse(_monthsCtrl.text);

    // TASA MENSUAL
    final monthlyRate = monthlyRatePercent / 100;

    final cuota =
        amount *
        (monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    final totalPayment = cuota * months;
    final totalInterest = totalPayment - amount;

    setState(() {
      _result = CreditSimulation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        annualRate: monthlyRatePercent, // ahora representa tasa mensual
        months: months,
        monthlyPayment: cuota,
        totalInterest: totalInterest,
        totalPayment: totalPayment,
        createdAt: DateTime.now(),
      );
    });
  }

  void _clearSimulation() {
  FocusScope.of(context).unfocus();

  setState(() {
    _result = null;
    _amountCtrl.text = '';
    _rateCtrl.text = '';
    _monthsCtrl.text = '';
  });

  _formKey.currentState?.reset();
}


  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _monthsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Simular crédito'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ===============================
            /// FORM CARD (solo cuando NO hay resultado)
            /// ===============================
            if (_result == null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Input(
                        label: 'Monto del crédito',
                        controller: _amountCtrl,
                        prefix: '\$',
                      ),
                      const SizedBox(height: 16),

                      _Input(
                        label: 'Tasa de interés mensual (%)',
                        controller: _rateCtrl,
                      ),
                      const SizedBox(height: 16),

                      _Input(
                        label: 'Plazo (meses)',
                        controller: _monthsCtrl,
                        keyboard: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _simulate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.positiveGreen,
                            foregroundColor: AppTheme.primaryBlack,
                          ),
                          child: const Text('Simular'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// ===============================
            /// RESULT CARD (solo cuando HAY resultado)
            /// ===============================
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado de la simulación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _ResultRow(
                      label: 'Monto del crédito',
                      value: currency.format(_result!.amount),
                    ),
                    _ResultRow(
                      label: 'Cantidad de cuotas',
                      value: '${_result!.months} meses',
                    ),
                    _ResultRow(
                      label: 'Tasa de interés mensual',
                      value: '${_result!.annualRate.toStringAsFixed(2)} %',
                    ),

                    const Divider(height: 24),

                    _ResultRow(
                      label: 'Cuota mensual',
                      value: currency.format(_result!.monthlyPayment),
                    ),
                    _ResultRow(
                      label: 'Total intereses',
                      value: currency.format(_result!.totalInterest),
                    ),
                    _ResultRow(
                      label: 'Total a pagar',
                      value: currency.format(_result!.totalPayment),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _clearSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Borrar simulación'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// INPUT REUTILIZABLE
/// ===============================
class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefix;
  final TextInputType keyboard;

  const _Input({
    required this.label,
    required this.controller,
    this.prefix,
    this.keyboard = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          decoration: InputDecoration(
            prefixText: prefix,
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// RESULT ROW
/// ===============================
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
