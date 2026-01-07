import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/loan.dart';
import '../../../data/services/storage_service.dart';

class AddLoanScreen extends StatefulWidget {
  final Loan? loan;
  final String? initialBankName;

  const AddLoanScreen({super.key, this.loan, this.initialBankName});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _termMonthsController = TextEditingController();
  final StorageService _storageService = StorageService();

  LoanType _selectedType = LoanType.personalLoan;
  DateTime _startDate = DateTime.now();
  bool _hasReminders = false;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      final d = widget.loan!;
      _nameController.text = d.name;
      _selectedType = d.type;
      _totalAmountController.text = d.totalAmount.toStringAsFixed(2);
      _interestRateController.text = d.interestRate?.toStringAsFixed(2) ?? '';
      _termMonthsController.text = d.termMonths?.toString() ?? '';
      _startDate = d.startDate;
      _hasReminders = d.hasReminders;
    } else if (widget.initialBankName != null) {
      _nameController.text = widget.initialBankName!;
      _selectedType = LoanType.creditCard;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _interestRateController.dispose();
    _termMonthsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.positiveGreen,
              onPrimary: AppTheme.primaryBlack,
              surface: AppTheme.cardBackground,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.tryParse(_totalAmountController.text.replaceAll(',', '')) ?? 0;
      final interestRate = _interestRateController.text.isNotEmpty
          ? double.tryParse(_interestRateController.text.replaceAll(',', ''))
          : null;
      final termMonths = _termMonthsController.text.isNotEmpty
          ? int.tryParse(_termMonthsController.text)
          : null;

      final remainingAmount = widget.loan?.remainingAmount ?? totalAmount;

      final loan = Loan(
        id: widget.loan?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        totalAmount: totalAmount,
        remainingAmount: remainingAmount,
        interestRate: interestRate,
        termMonths: termMonths,
        startDate: _startDate,
        hasReminders: _hasReminders,
      );

      if (widget.loan != null) {
        await _storageService.updateLoan(loan);
      } else {
        await _storageService.addLoan(loan);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(widget.loan == null ? 'Nuevo Préstamo' : 'Editar Préstamo'),
        actions: [
          TextButton(
            onPressed: _saveLoan,
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppTheme.positiveGreen),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: Préstamo personal',
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tipo de Préstamo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LoanType.values.map((type) {
                    final isSelected = _selectedType == type;
                    final label = AppConstants.debtTypeLabels[type.toString().split('.').last] ?? type.toString();
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      selectedColor: AppTheme.surfaceColor,
                      checkmarkColor: AppTheme.positiveGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.positiveGreen : AppTheme.borderColor,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _totalAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Total',
                    hintText: '0.00',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  style: const TextStyle(color: AppTheme.textPrimary),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el monto total';
                    }
                    final amount = double.tryParse(value.replaceAll(',', ''));
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _interestRateController,
                        decoration: const InputDecoration(
                          labelText: 'Tasa de Interés % (opcional)',
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                        ],
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _termMonthsController,
                        decoration: const InputDecoration(
                          labelText: 'Plazo (meses) (opcional)',
                          hintText: '12',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Fecha de inicio: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Recordatorios'),
                  subtitle: const Text('Recibir notificaciones de cobros'),
                  value: _hasReminders,
                  onChanged: (value) {
                    setState(() {
                      _hasReminders = value;
                    });
                  },
                  activeColor: AppTheme.positiveGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
