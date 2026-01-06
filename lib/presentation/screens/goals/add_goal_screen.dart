import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/goal.dart';
import '../../../data/services/storage_service.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? goal;
  
  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  GoalTimeframe _selectedTimeframe = GoalTimeframe.medium;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      final g = widget.goal!;
      _nameController.text = g.name;
      _descriptionController.text = g.description;
      _targetAmountController.text = g.targetAmount.toStringAsFixed(2);
      _selectedTimeframe = g.timeframe;
      _targetDate = g.targetDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.tryParse(_targetAmountController.text.replaceAll(',', '')) ?? 0;
      
      final goal = Goal(
        id: widget.goal?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: widget.goal?.currentAmount ?? 0,
        timeframe: _selectedTimeframe,
        targetDate: _targetDate,
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
      );

      if (widget.goal != null) {
        await _storageService.updateGoal(goal);
      } else {
        await _storageService.addGoal(goal);
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
        title: Text(widget.goal == null ? 'Nueva Meta' : 'Editar Meta'),
        actions: [
          TextButton(
            onPressed: _saveGoal,
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
                    labelText: 'Nombre de la Meta',
                    hintText: 'Ej: Viaje a Europa',
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
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Añade una descripción...',
                  ),
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Objetivo',
                    hintText: '0.00',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un monto objetivo';
                    }
                    final amount = double.tryParse(value.replaceAll(',', ''));
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Plazo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...GoalTimeframe.values.map((timeframe) {
                  final isSelected = _selectedTimeframe == timeframe;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTimeframe = timeframe;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.surfaceColor : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.positiveGreen : AppTheme.borderColor,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppConstants.goalTimeframeLabels[timeframe.toString().split('.').last] ?? timeframe.toString(),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.positiveGreen,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                        Expanded(
                          child: Text(
                            _targetDate != null
                                ? 'Fecha objetivo: ${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                                : 'Seleccionar fecha objetivo (opcional)',
                            style: TextStyle(
                              fontSize: 16,
                              color: _targetDate != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        if (_targetDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _targetDate = null;
                              });
                            },
                          ),
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


