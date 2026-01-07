import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction.dart';

enum ChartMode { daily, hourly }

enum SeriesType { balance, incomes, expenses }

class TransactionChart extends StatefulWidget {
  final List<Transaction> transactions;
  final ChartMode mode;
  final SeriesType seriesType;

  const TransactionChart({super.key, required this.transactions, this.mode = ChartMode.daily, this.seriesType = SeriesType.balance});

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  late ChartMode mode;

  @override
  void initState() {
    super.initState();
    mode = widget.mode;
  }

  Map<String, List<FlSpot>> _getChartSeries() {
    final now = DateTime.now();
    final cumulative = <FlSpot>[];
    final incomes = <FlSpot>[];
    final expenses = <FlSpot>[];

    if (mode == ChartMode.daily) {
      // Calcular balance inicial (todas las transacciones anteriores al período de 30 días)
      final firstDay = now.subtract(const Duration(days: 29));
      final firstDayStart = DateTime(firstDay.year, firstDay.month, firstDay.day);

      double initialBalance = 0;
      for (var transaction in widget.transactions) {
        if (transaction.date.isBefore(firstDayStart)) {
          if (transaction.type == TransactionType.income) {
            initialBalance += transaction.amount;
          } else {
            initialBalance -= transaction.amount;
          }
        }
      }

      // Get last 30 days data con balance acumulado e ingresos/gastos diarios
      double cumulativeBalance = initialBalance;
      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        double dailyIncome = 0;
        double dailyExpense = 0;
        for (var transaction in widget.transactions) {
          if (!transaction.date.isBefore(dayStart) && transaction.date.isBefore(dayEnd)) {
            if (transaction.type == TransactionType.income) {
              dailyIncome += transaction.amount;
            } else {
              dailyExpense += transaction.amount;
            }
          }
        }

        cumulativeBalance += (dailyIncome - dailyExpense);
        final x = (29 - i).toDouble();
        cumulative.add(FlSpot(x, cumulativeBalance));
        incomes.add(FlSpot(x, dailyIncome));
        expenses.add(FlSpot(x, -dailyExpense)); // mostrar gastos como negativos
      }
    } else {
      // Horario: últimas 24 horas (por hora)
      final firstHour = DateTime.now().subtract(const Duration(hours: 23));
      final firstHourStart = DateTime(firstHour.year, firstHour.month, firstHour.day, firstHour.hour);

      double initialBalance = 0;
      for (var transaction in widget.transactions) {
        if (transaction.date.isBefore(firstHourStart)) {
          if (transaction.type == TransactionType.income) {
            initialBalance += transaction.amount;
          } else {
            initialBalance -= transaction.amount;
          }
        }
      }

      double cumulativeBalance = initialBalance;
      for (int i = 23; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(hours: i));
        final hourStart = DateTime(date.year, date.month, date.day, date.hour);
        final hourEnd = hourStart.add(const Duration(hours: 1));

        double hourlyIncome = 0;
        double hourlyExpense = 0;
        for (var transaction in widget.transactions) {
          if (!transaction.date.isBefore(hourStart) && transaction.date.isBefore(hourEnd)) {
            if (transaction.type == TransactionType.income) {
              hourlyIncome += transaction.amount;
            } else {
              hourlyExpense += transaction.amount;
            }
          }
        }

        cumulativeBalance += (hourlyIncome - hourlyExpense);
        final x = (23 - i).toDouble();
        cumulative.add(FlSpot(x, cumulativeBalance));
        incomes.add(FlSpot(x, hourlyIncome));
        expenses.add(FlSpot(x, -hourlyExpense));
      }
    }

    return {'cumulative': cumulative, 'incomes': incomes, 'expenses': expenses};
  }

  @override
  Widget build(BuildContext context) {
    final series = _getChartSeries();
    final cumulative = series['cumulative']!;
    final incomes = series['incomes']!;
    final expenses = series['expenses']!;

    // Elegir la única serie a mostrar
    late final List<FlSpot> spotsToShow;
    late final String legendText;
    late final Color seriesColor;

    switch (widget.seriesType) {
      case SeriesType.balance:
        spotsToShow = cumulative;
        legendText = 'Balance';
        seriesColor = AppTheme.accentBlue;
        break;
      case SeriesType.incomes:
        spotsToShow = incomes;
        legendText = 'Ingresos';
        seriesColor = AppTheme.positiveGreen;
        break;
      case SeriesType.expenses:
        spotsToShow = expenses;
        legendText = 'Gastos';
        seriesColor = AppTheme.negativeRed;
        break;
    }

    final hasData = spotsToShow.isNotEmpty;

    double minY = 0.0;
    double maxY = 100.0;

    if (hasData) {
      final allYs = spotsToShow.map((s) => s.y).toList();

      minY = allYs.reduce((a, b) => a < b ? a : b);
      maxY = allYs.reduce((a, b) => a > b ? a : b);

      final range = maxY - minY;
      if (range == 0) {
        minY = minY - 50;
        maxY = maxY + 50;
      } else {
        minY = minY - range * 0.1;
        maxY = maxY + range * 0.1;
      }
    }

    final horizontalInterval = (maxY - minY) / 5;
    final safeInterval = horizontalInterval == 0 ? 1.0 : horizontalInterval;

    Widget legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          ),
        ],
      );
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
          Text(
            mode == ChartMode.daily ? 'Flujo diario (últimos 30 días)' : 'Flujo por hora (últimas 24 horas)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ToggleButtons(
                isSelected: [mode == ChartMode.daily, mode == ChartMode.hourly],
                onPressed: (index) {
                  setState(() {
                    mode = index == 0 ? ChartMode.daily : ChartMode.hourly;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: AppTheme.textPrimary,
                color: AppTheme.textSecondary,
                fillColor: AppTheme.surfaceColor,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text('Diario', style: TextStyle(fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text('Horario', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              legendItem(seriesColor, legendText),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: !hasData
                ? Center(
                    child: Text(
                      'No hay datos para mostrar',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 0,
                            color: AppTheme.textTertiary,
                            strokeWidth: 1,
                          ),
                        ],
                      ),
                      // Tooltips y puntos tocados
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: AppTheme.surfaceColor,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItems: (touchedSpots) {
                            if (touchedSpots.isEmpty) return [];

                            final currencyFormat = NumberFormat.currency(symbol: '\$');

                            return touchedSpots.map((spot) {
                              final x = spot.x.round();
                              DateTime date;
                              if (mode == ChartMode.daily) {
                                date = DateTime.now().subtract(Duration(days: 29 - x));
                              } else {
                                date = DateTime.now().subtract(Duration(hours: 23 - x));
                              }

                              String label;
                              String amountStr;

                              if (widget.seriesType == SeriesType.incomes) {
                                label = 'Ingresos';
                                amountStr = currencyFormat.format(spot.y);
                              } else if (widget.seriesType == SeriesType.expenses) {
                                label = 'Gastos';
                                amountStr = '-${currencyFormat.format(spot.y.abs())}';
                              } else {
                                label = 'Balance';
                                amountStr = currencyFormat.format(spot.y);
                              }

                              final df = mode == ChartMode.daily ? DateFormat('d MMM', 'es') : DateFormat('HH:mm');
                              final text = '${df.format(date)}\n$label: $amountStr';
                              return LineTooltipItem(text, TextStyle(color: AppTheme.textPrimary, fontSize: 12));
                            }).toList();
                          },
                        ),
                        getTouchedSpotIndicator: (barData, indicators) {
                          return indicators.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: AppTheme.borderColor,
                                strokeWidth: 1.5,
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) =>
                                    FlDotCirclePainter(
                                      radius: 4,
                                      color: bar.color ?? AppTheme.textPrimary,
                                      strokeWidth: 1.5,
                                      strokeColor: AppTheme.cardBackground,
                                    ),
                              ),
                            );
                          }).toList();
                        },
                      ),
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
                              final x = value.round();
                              if (mode == ChartMode.daily) {
                                final date = DateTime.now().subtract(
                                  Duration(days: 29 - x),
                                );
                                // Mostrar etiqueta cada 5 días para evitar sobreposición
                                if (x % 5 == 0 || x == 29) {
                                  final dateFormat = DateFormat('d MMM', 'es');
                                  return Text(
                                    dateFormat.format(date),
                                    style: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              } else {
                                final date = DateTime.now().subtract(
                                  Duration(hours: 23 - x),
                                );
                                // Mostrar etiqueta cada 4 horas
                                if (x % 4 == 0 || x == 23) {
                                  final dateFormat = DateFormat('HH:mm');
                                  return Text(
                                    dateFormat.format(date),
                                    style: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
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
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 0.5,
                        ),
                      ),
                      minX: 0,
                      maxX: mode == ChartMode.daily ? 29 : 23,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spotsToShow,
                          isCurved: true,
                          color: seriesColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: widget.seriesType != SeriesType.balance,
                            color: seriesColor.withOpacity(0.08),
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
