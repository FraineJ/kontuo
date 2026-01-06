import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/credit_simulation.dart';
import '../../../data/services/credit_storage_service.dart';

/// ===============================
/// ENUM PERIODO DE TASA
/// ===============================
enum RatePeriod {
  annual,
  monthly,
  biweekly,
  weekly,
}

extension RatePeriodX on RatePeriod {
  String get label {
    switch (this) {
      case RatePeriod.annual:
        return 'Anual';
      case RatePeriod.monthly:
        return 'Mensual';
      case RatePeriod.biweekly:
        return 'Quincenal';
      case RatePeriod.weekly:
        return 'Semanal';
    }
  }
}

class CreditSimulationScreen extends StatefulWidget {
  const CreditSimulationScreen({super.key});

  @override
  State<CreditSimulationScreen> createState() =>
      _CreditSimulationScreenState();
}

class _CreditSimulationScreenState extends State<CreditSimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final CreditSimulationService _service = CreditSimulationService();

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _rateCtrl = TextEditingController();
  final TextEditingController _monthsCtrl = TextEditingController();

  RatePeriod _ratePeriod = RatePeriod.annual;

  CreditSimulation? _result;

  final currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  /// ===============================
  /// CONVERTIR A TASA MENSUAL
  /// ===============================
  double _toMonthlyRate(double rate, RatePeriod period) {
    switch (period) {
      case RatePeriod.annual:
        return rate / 12 / 100;
      case RatePeriod.monthly:
        return rate / 100;
      case RatePeriod.biweekly:
        return (rate * 2) / 100;
      case RatePeriod.weekly:
        return (rate * 4) / 100;
    }
  }

  /// ===============================
  /// SIMULACIÓN
  /// ===============================
  void _simulate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountCtrl.text);
    final rateValue = double.parse(_rateCtrl.text);
    final months = int.parse(_monthsCtrl.text);

    final monthlyRate = _toMonthlyRate(rateValue, _ratePeriod);

    final cuota = amount *
        (monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    final totalPayment = cuota * months;
    final totalInterest = totalPayment - amount;

    setState(() {
      _result = CreditSimulation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        annualRate: rateValue, // tasa original ingresada
        months: months,
        monthlyPayment: cuota,
        totalInterest: totalInterest,
        totalPayment: totalPayment,
        createdAt: DateTime.now(),
      );
    });
  }

  /// ===============================
  /// GUARDAR SIMULACIÓN
  /// ===============================
  Future<void> _saveSimulation() async {
    if (_result == null) return;

    await _service.addSimulation(_result!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Simulación guardada'),
        backgroundColor: AppTheme.positiveGreen,
      ),
    );

    setState(() => _result = null);
    _formKey.currentState!.reset();
    _ratePeriod = RatePeriod.annual;
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
            /// FORM CARD
            /// ===============================
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

                    /// TASA + PERIODO
                    Text(
                      'Tasa de interés',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _rateCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Campo requerido' : null,
                            decoration: InputDecoration(
                              suffixText: '%',
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<RatePeriod>(
                            value: _ratePeriod,
                            items: RatePeriod.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _ratePeriod = value);
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
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

            const SizedBox(height: 24),

            /// ===============================
            /// RESULT CARD
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
                      'Resultado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        onPressed: _saveSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.positiveGreen,
                          foregroundColor: AppTheme.primaryBlack,
                        ),
                        child: const Text('Guardar simulación'),
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
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
