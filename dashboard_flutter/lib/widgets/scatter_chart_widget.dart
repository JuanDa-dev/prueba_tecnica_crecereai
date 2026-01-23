import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget de gráfico de dispersión (scatter plot)
class ScatterChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String xLabel;
  final String yLabel;

  const ScatterChartWidget({
    super.key,
    required this.data,
    required this.title,
    required this.xLabel,
    required this.yLabel,
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
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 16),
            Expanded(
              child: ScatterChart(
                ScatterChartData(
                  minX: 0,
                  maxX: _getMaxX() * 1.1,
                  minY: 0,
                  maxY: _getMaxY() * 1.1,
                  scatterSpots: data.map((d) {
                    final acuerdo = d['acuerdo'] as bool;
                    return ScatterSpot(
                      (d['x'] as num).toDouble(),
                      (d['y'] as num).toDouble(),
                      dotPainter: FlDotCirclePainter(
                        color: acuerdo 
                          ? Colors.green.withOpacity(0.6) 
                          : Colors.red.withOpacity(0.6),
                        radius: 6,
                      ),
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(xLabel, style: const TextStyle(fontSize: 12)),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(yLabel, style: const TextStyle(fontSize: 12)),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  scatterTouchData: ScatterTouchData(
                    enabled: true,
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipItems: (spot) {
                        return ScatterTooltipItem(
                          '$xLabel: ${spot.x.toStringAsFixed(2)}\n$yLabel: ${spot.y.toStringAsFixed(2)}',
                          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Sin acuerdo', Colors.red.withOpacity(0.6)),
        const SizedBox(width: 24),
        _legendItem('Con acuerdo', Colors.green.withOpacity(0.6)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  double _getMaxX() {
    if (data.isEmpty) return 10;
    return data.map((d) => (d['x'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    return data.map((d) => (d['y'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
  }
}
