import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/storage_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _type = t.type;
      _selectedCategory = t.category;
      _amountController.text = t.amount.toStringAsFixed(2);
      _selectedDate = t.date;
      _notesController.text = t.notes ?? '';
      _isRecurring = t.isRecurring;
    } else {
      _selectedCategory = _type == TransactionType.expense
          ? AppConstants.expenseCategories.first
          : AppConstants.incomeCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate() && _selectedCategory.isNotEmpty) {
      final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      
      final transaction = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        type: _type,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isRecurring: _isRecurring,
      );

      if (widget.transaction != null) {
        await _storageService.updateTransaction(transaction);
      } else {
        await _storageService.addTransaction(transaction);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  List<String> get _categories {
    return _type == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;
  }

  Map<String, String> get _categoryLabels {
    return _type == TransactionType.expense
        ? AppConstants.expenseCategoryLabels
        : AppConstants.incomeCategoryLabels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(
          widget.transaction == null ? 'Nueva Transacción' : 'Editar Transacción',
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
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
                // Type selector
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        TransactionType.expense,
                        'Gasto',
                        AppTheme.negativeRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeButton(
                        TransactionType.income,
                        'Ingreso',
                        AppTheme.positiveGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    hintText: '0.00',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24),
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
                const SizedBox(height: 24),
                
                // Category
                const Text(
                  'Categoría',
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
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(_categoryLabels[category] ?? category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
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
                
                // Date
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
                          DateFormat('EEEE, d MMMM y', 'es').format(_selectedDate),
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
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Añade una nota...',
                  ),
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 24),
                
                // Recurring
                if (_type == TransactionType.income)
                  SwitchListTile(
                    title: const Text('Ingreso Recurrente'),
                    subtitle: const Text('Este ingreso se repite periódicamente'),
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
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

  Widget _buildTypeButton(TransactionType type, String label, Color color) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () {
        setState(() {
          _type = type;
          _selectedCategory = _categories.first;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderColor,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? color : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

