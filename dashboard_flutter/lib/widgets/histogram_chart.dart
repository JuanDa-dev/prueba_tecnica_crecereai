import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget de histograma usando fl_chart
class HistogramChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final Color color;
  final String xlabel;
  final int bins;

  const HistogramChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
    required this.xlabel,
    this.bins = 10,
  });

  @override
  Widget build(BuildContext context) {
    final histogramData = _calculateHistogram();
    
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
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: histogramData.map((e) => e['count'] as double).reduce((a, b) => a > b ? a : b) * 1.1,
                  barGroups: histogramData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['count'] as double,
                          color: color,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(xlabel, style: const TextStyle(fontSize: 12)),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < histogramData.length) {
                            if (value.toInt() % 2 == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  histogramData[value.toInt()]['label'] as String,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
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
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateHistogram() {
    if (data.isEmpty) return [];
    
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final binWidth = (max - min) / bins;
    
    final counts = List.filled(bins, 0);
    for (var v in data) {
      var binIndex = ((v - min) / binWidth).floor();
      if (binIndex >= bins) binIndex = bins - 1;
      counts[binIndex]++;
    }
    
    return List.generate(bins, (i) => {
      'label': (min + i * binWidth).toStringAsFixed(0),
      'count': counts[i].toDouble(),
    });
  }
}
