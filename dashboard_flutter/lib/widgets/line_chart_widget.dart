import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/deudor_model.dart';

/// Widget de gráfico de líneas para series temporales
class TimeSeriesChart extends StatelessWidget {
  final List<LineChartDataPoint> data;
  final String title;
  final bool showRate;

  const TimeSeriesChart({
    super.key,
    required this.data,
    required this.title,
    this.showRate = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: _getMaxY() * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.map((d) => FlSpot(
                        d.mes.toDouble(),
                        showRate ? d.tasaExito : d.total.toDouble(),
                      )).toList(),
                      isCurved: true,
                      color: showRate ? Colors.green : colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: showRate ? Colors.green : colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (showRate ? Colors.green : colorScheme.primary).withOpacity(0.2),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                                         'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                          if (value.toInt() >= 1 && value.toInt() <= 12) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                meses[value.toInt()],
                                style: const TextStyle(fontSize: 10),
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            showRate 
                              ? '${value.toStringAsFixed(0)}%' 
                              : value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxY() / 5,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final dataPoint = data[spot.x.toInt() - 1];
                          return LineTooltipItem(
                            '${dataPoint.mesNombre}\n${showRate ? '${spot.y.toStringAsFixed(1)}%' : '${spot.y.toInt()} casos'}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final values = data.map((d) => showRate ? d.tasaExito : d.total.toDouble());
    return values.reduce((a, b) => a > b ? a : b);
  }
}
