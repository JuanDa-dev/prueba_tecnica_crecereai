import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import '../models/deudor_model.dart';

/// Widget de gráfico de barras con tasa de acuerdo (quintiles/deciles)
class RateBarChart extends StatelessWidget {
  final List<QuintileData> data;
  final String title;
  final Color color;
  final double? averageLine;

  const RateBarChart({
    super.key,
    required this.data,
    required this.title,
    this.color = Colors.blue,
    this.averageLine,
  });

  @override
  Widget build(BuildContext context) {
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
              child: charts.BarChart(
                charts.BarChartData(
                  alignment: charts.BarChartAlignment.spaceAround,
                  maxY: (data.map((d) => d.tasaAcuerdo).reduce((a, b) => a > b ? a : b) * 1.2).clamp(0, 100),
                  extraLinesData: averageLine != null
                      ? charts.ExtraLinesData(
                          horizontalLines: [
                            charts.HorizontalLine(
                              y: averageLine!,
                              color: Colors.red,
                              strokeWidth: 2,
                              dashArray: [8, 4],
                              label: charts.HorizontalLineLabel(
                                show: true,
                                labelResolver: (line) => 'Promedio: ${averageLine!.toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.red, fontSize: 10),
                              ),
                            ),
                          ],
                        )
                      : null,
                  barGroups: data.asMap().entries.map((entry) {
                    final colorIntensity = (entry.key + 1) / data.length;
                    return charts.BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        charts.BarChartRodData(
                          toY: entry.value.tasaAcuerdo,
                          color: Color.lerp(color.withOpacity(0.4), color, colorIntensity),
                          width: 28,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [],
                    );
                  }).toList(),
                  titlesData: charts.FlTitlesData(
                    show: true,
                    bottomTitles: charts.AxisTitles(
                      sideTitles: charts.SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: RotatedBox(
                                quarterTurns: -1,
                                child: Text(
                                  data[value.toInt()].label,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: charts.AxisTitles(
                      sideTitles: charts.SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const charts.AxisTitles(sideTitles: charts.SideTitles(showTitles: false)),
                    rightTitles: const charts.AxisTitles(sideTitles: charts.SideTitles(showTitles: false)),
                  ),
                  gridData: const charts.FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: charts.FlBorderData(show: false),
                  barTouchData: charts.BarTouchData(
                    enabled: true,
                    touchTooltipData: charts.BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = data[group.x];
                        return charts.BarTooltipItem(
                          '${item.label}\n${item.tasaAcuerdo.toStringAsFixed(1)}%\n(n=${item.total})',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
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
}
