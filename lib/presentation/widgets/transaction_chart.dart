import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction.dart';

class TransactionChart extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionChart({super.key, required this.transactions});

  List<FlSpot> _getChartData() {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
    // Get last 30 days data
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      double balance = 0;
      for (var transaction in transactions) {
        if (transaction.date.isAfter(dayStart) && transaction.date.isBefore(dayEnd)) {
          if (transaction.type == TransactionType.income) {
            balance += transaction.amount;
          } else {
            balance -= transaction.amount;
          }
        }
      }
      
      // Cumulative balance
      if (spots.isNotEmpty) {
        balance += spots.last.y;
      }
      
      spots.add(FlSpot((29 - i).toDouble(), balance));
    }
    
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartData();
    
    double minY = 0.0;
    double maxY = 100.0;
    
    if (spots.isNotEmpty) {
      minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      
      // Add padding
      final range = maxY - minY;
      if (range == 0) {
        // All values are the same, add a default range
        minY = minY - 50;
        maxY = maxY + 50;
      } else {
        minY = minY - range * 0.1;
        maxY = maxY + range * 0.1;
      }
    }
    
    final horizontalInterval = (maxY - minY) / 5;
    // Ensure minimum interval to avoid zero
    final safeInterval = horizontalInterval == 0 ? 1.0 : horizontalInterval;

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
          Text(
            'Flujo Mensual',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      'No hay datos para mostrar',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : LineChart(
                    LineChartData(
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
                              return Text(
                                '',
                                style: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 10,
                                ),
                              );
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
                      minX: 0,
                      maxX: 29,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppTheme.positiveGreen,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.positiveGreen.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

