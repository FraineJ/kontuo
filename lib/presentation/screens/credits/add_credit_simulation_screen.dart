// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:uuid/uuid.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/utils/credit_calculator.dart';
// import '../../../data/models/credit_simulation.dart';
// import '../../../data/services/credit_storage_service.dart';

// class AddCreditSimulationScreen extends StatefulWidget {
//   const AddCreditSimulationScreen({super.key});

//   @override
//   State<AddCreditSimulationScreen> createState() =>
//       _AddCreditSimulationScreenState();
// }

// class _AddCreditSimulationScreenState
//     extends State<AddCreditSimulationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountCtrl = TextEditingController();
//   final _rateCtrl = TextEditingController();
//   final _monthsCtrl = TextEditingController();

//   CreditType _type = CreditType.amortized;
//   final CreditStorageService _storageService = CreditStorageService();

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;

//     final simulation = CreditCalculator.calculate(
//       id: const Uuid().v4(),
//       amount: double.parse(_amountCtrl.text),
//       annualRate: double.parse(_rateCtrl.text),
//       months: int.parse(_monthsCtrl.text),
//       type: _type,
//     );

//     await _storageService.addSimulation(simulation);
//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.darkBackground,
//       appBar: AppBar(
//         backgroundColor: AppTheme.darkBackground,
//         title: const Text('Nueva Simulación'),
//         actions: [
//           TextButton(
//             onPressed: _save,
//             child: const Text(
//               'Guardar',
//               style: TextStyle(color: AppTheme.positiveGreen),
//             ),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _buildField(_amountCtrl, 'Monto', '\$'),
//               _buildField(_rateCtrl, 'Tasa anual (%)'),
//               _buildField(_monthsCtrl, 'Plazo (meses)'),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(child: _typeButton(CreditType.amortized, 'Amortizado')),
//                   const SizedBox(width: 12),
//                   Expanded(child: _typeButton(CreditType.simple, 'Simple')),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField(TextEditingController ctrl, String label, [String? prefix]) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: ctrl,
//         keyboardType: TextInputType.number,
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
//         ],
//         decoration: InputDecoration(
//           labelText: label,
//           prefixText: prefix,
//         ),
//         validator: (v) =>
//             v == null || v.isEmpty ? 'Campo requerido' : null,
//       ),
//     );
//   }

//   Widget _typeButton(CreditType type, String label) {
//     final selected = _type == type;
//     return InkWell(
//       onTap: () => setState(() => _type = type),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: selected
//               ? AppTheme.positiveGreen.withOpacity(0.2)
//               : AppTheme.cardBackground,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected
//                 ? AppTheme.positiveGreen
//                 : AppTheme.borderColor,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: selected
//                   ? AppTheme.positiveGreen
//                   : AppTheme.textSecondary,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
