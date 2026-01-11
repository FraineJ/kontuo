import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction.dart';

enum ChartPeriod { day, week, month }

class TransactionChart extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionChart({super.key, required this.transactions});

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  List<BarChartGroupData> _getChartData() {
    final now = DateTime.now();
    final groups = <BarChartGroupData>[];
    
    int itemCount;
    String dateFormat;
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        // Últimos 7 días
        itemCount = 7;
        dateFormat = 'EEE';
        startDate = now.subtract(const Duration(days: 6));
        break;
      case ChartPeriod.week:
        // Últimas 4 semanas
        itemCount = 4;
        dateFormat = 'MMM d';
        startDate = now.subtract(Duration(days: 7 * (itemCount - 1)));
        break;
      case ChartPeriod.month:
        // Últimos 6 meses
        itemCount = 6;
        dateFormat = 'MMM';
        startDate = DateTime(now.year, now.month - (itemCount - 1), 1);
        break;
    }
    
    for (int i = 0; i < itemCount; i++) {
      DateTime periodStart;
      DateTime periodEnd;
      
      switch (_selectedPeriod) {
        case ChartPeriod.day:
          periodStart = DateTime(startDate.year, startDate.month, startDate.day + i);
          periodEnd = periodStart.add(const Duration(days: 1));
          break;
        case ChartPeriod.week:
          periodStart = startDate.add(Duration(days: 7 * i));
          periodEnd = periodStart.add(const Duration(days: 7));
          break;
        case ChartPeriod.month:
          final monthIndex = (startDate.month - 1 + i) % 12;
          final year = startDate.year + ((startDate.month - 1 + i) ~/ 12);
          periodStart = DateTime(year, monthIndex + 1, 1);
          periodEnd = DateTime(year, monthIndex + 2, 1);
          break;
      }
      
      double income = 0;
      double expenses = 0;
      
      for (var transaction in widget.transactions) {
        if (transaction.date.isAfter(periodStart.subtract(const Duration(milliseconds: 1))) &&
            transaction.date.isBefore(periodEnd)) {
          if (transaction.type == TransactionType.income) {
            income += transaction.amount;
          } else {
            expenses += transaction.amount;
          }
        }
      }
      
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: AppTheme.positiveGreen,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: expenses,
              color: AppTheme.negativeRed,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          barsSpace: 4,
        ),
      );
    }
    
    return groups;
  }

  List<String> _getBottomLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    
    int itemCount;
    String dateFormat;
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        itemCount = 7;
        dateFormat = 'EEE';
        startDate = now.subtract(const Duration(days: 6));
        break;
      case ChartPeriod.week:
        itemCount = 4;
        dateFormat = 'MMM d';
        startDate = now.subtract(Duration(days: 7 * (itemCount - 1)));
        break;
      case ChartPeriod.month:
        itemCount = 6;
        dateFormat = 'MMM';
        startDate = DateTime(now.year, now.month - (itemCount - 1), 1);
        break;
    }
    
    final formatter = DateFormat(dateFormat, 'es');
    
    for (int i = 0; i < itemCount; i++) {
      DateTime date;
      switch (_selectedPeriod) {
        case ChartPeriod.day:
          date = DateTime(startDate.year, startDate.month, startDate.day + i);
          break;
        case ChartPeriod.week:
          date = startDate.add(Duration(days: 7 * i));
          break;
        case ChartPeriod.month:
          final monthIndex = (startDate.month - 1 + i) % 12;
          final year = startDate.year + ((startDate.month - 1 + i) ~/ 12);
          date = DateTime(year, monthIndex + 1, 1);
          break;
      }
      labels.add(formatter.format(date));
    }
    
    return labels;
  }

  double _getMaxY() {
    final groups = _getChartData();
    if (groups.isEmpty) return 100.0;
    
    double maxValue = 0;
    for (var group in groups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxValue) {
          maxValue = rod.toY;
        }
      }
    }
    
    // Add 20% padding
    return maxValue * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getChartData();
    final bottomLabels = _getBottomLabels();
    final maxY = _getMaxY();
    final safeMaxY = maxY == 0 ? 100.0 : maxY;
    final horizontalInterval = safeMaxY / 5;
    final safeInterval = horizontalInterval == 0 ? 1.0 : horizontalInterval;

    String title;
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        title = 'Flujo Diario';
        break;
      case ChartPeriod.week:
        title = 'Flujo Semanal';
        break;
      case ChartPeriod.month:
        title = 'Flujo Mensual';
        break;
    }

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
          // Header con título y filtros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              // Segmented control para filtros
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodButton(ChartPeriod.day, 'Día'),
                    _buildPeriodButton(ChartPeriod.week, 'Sem'),
                    _buildPeriodButton(ChartPeriod.month, 'Mes'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfico de barras
          SizedBox(
            height: 220,
            child: groups.isEmpty
                ? Center(
                    child: Text(
                      'No hay datos para mostrar',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: safeInterval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppTheme.borderColor,
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < bottomLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    bottomLabels[value.toInt()],
                                    style: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: AppTheme.borderColor, width: 0.5),
                      ),
                      minY: 0,
                      maxY: safeMaxY,
                      barGroups: groups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: AppTheme.cardBackground,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final value = rod.toY;
                            final isIncome = rodIndex == 0;
                            return BarTooltipItem(
                              value.toStringAsFixed(0),
                              TextStyle(
                                color: isIncome ? AppTheme.positiveGreen : AppTheme.negativeRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem('Ingresos', AppTheme.positiveGreen),
              const SizedBox(width: 24),
              _buildLegendItem('Gastos', AppTheme.negativeRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(ChartPeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.positiveGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppTheme.primaryBlack : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

