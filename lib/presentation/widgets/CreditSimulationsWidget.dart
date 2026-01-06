import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kontuo/presentation/screens/credits/credits_screen.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/credit_simulation.dart';
import '../../../data/services/credit_storage_service.dart';

class CreditSimulationsWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const CreditSimulationsWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  State<CreditSimulationsWidget> createState() =>
      _CreditSimulationsWidgetState();
}

class _CreditSimulationsWidgetState extends State<CreditSimulationsWidget> {
  final CreditSimulationService _service = CreditSimulationService();

  List<CreditSimulation> _simulations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimulations();
  }

  Future<void> _loadSimulations() async {
    final data = await _service.getSimulations();
    setState(() {
      _simulations = data.take(3).toList(); // preview como Deudas
      _isLoading = false;
    });
  }

  Future<void> _deleteSimulation(String id) async {
    await _service.deleteSimulation(id);
    _loadSimulations();
    widget.onRefresh();
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
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Simulaciones de crédito',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreditSimulationScreen()),
                  );
                },
                child: Text(
                  'Ver todas',
                  style: TextStyle(color: AppTheme.positiveGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Content
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.positiveGreen,
                  ),
                )
              : _simulations.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calculate,
                              size: 48,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay simulaciones registradas',
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
                      children: _simulations.map((sim) {
                        return _CreditSimulationTile(
                          simulation: sim,
                          onDelete: () => _deleteSimulation(sim.id),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}

class _CreditSimulationTile extends StatelessWidget {
  final CreditSimulation simulation;
  final VoidCallback onDelete;

  const _CreditSimulationTile({
    required this.simulation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Crédito simulado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppTheme.negativeRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${simulation.months} meses • ${simulation.annualRate}%',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              Text(
                currency.format(simulation.amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Cuota: ${currency.format(simulation.monthlyPayment)}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),

          Text(
            'Total a pagar: ${currency.format(simulation.totalPayment)}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
