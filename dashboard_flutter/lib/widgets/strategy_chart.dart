import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import '../models/deudor_model.dart';

/// Widget para visualizar efecto de estrategia por nivel de ingreso
class StrategyChart extends StatelessWidget {
  final List<StrategyData> data;
  final String title;

  const StrategyChart({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final gruposIngreso = ['Bajo', 'Medio', 'Alto'];

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
              child: charts.BarChart(
                charts.BarChartData(
                  alignment: charts.BarChartAlignment.spaceAround,
                  maxY: _getMaxY() * 1.2,
                  barGroups: gruposIngreso.asMap().entries.map((entry) {
                    final ingreso = entry.value;
                    
                    final noAgresiva = data.firstWhere(
                      (d) => d.grupoIngreso == ingreso && !d.estrategiaAgresiva,
                      orElse: () => StrategyData(
                        grupoIngreso: ingreso,
                        estrategiaAgresiva: false,
                        tasaAcuerdo: 0,
                        total: 0,
                      ),
                    );
                    
                    final agresiva = data.firstWhere(
                      (d) => d.grupoIngreso == ingreso && d.estrategiaAgresiva,
                      orElse: () => StrategyData(
                        grupoIngreso: ingreso,
                        estrategiaAgresiva: true,
                        tasaAcuerdo: 0,
                        total: 0,
                      ),
                    );
                    
                    return charts.BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        charts.BarChartRodData(
                          toY: noAgresiva.tasaAcuerdo,
                          color: Colors.blue,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        charts.BarChartRodData(
                          toY: agresiva.tasaAcuerdo,
                          color: Colors.red,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: charts.FlTitlesData(
                    show: true,
                    bottomTitles: charts.AxisTitles(
                      sideTitles: charts.SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < gruposIngreso.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Ingreso ${gruposIngreso[value.toInt()]}',
                                style: const TextStyle(fontSize: 11),
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
                  gridData: charts.FlGridData(show: true, drawVerticalLine: false),
                  borderData: charts.FlBorderData(show: false),
                  barTouchData: charts.BarTouchData(
                    enabled: true,
                    touchTooltipData: charts.BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final ingreso = gruposIngreso[group.x];
                        final estrategia = rodIndex == 0 ? 'No Agresiva' : 'Agresiva';
                        final item = data.firstWhere(
                          (d) => d.grupoIngreso == ingreso && d.estrategiaAgresiva == (rodIndex == 1),
                        );
                        return charts.BarTooltipItem(
                          '$ingreso - $estrategia\n${item.tasaAcuerdo.toStringAsFixed(1)}%\n(n=${item.total})',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
        _legendItem('No Agresiva', Colors.blue),
        const SizedBox(width: 24),
        _legendItem('Agresiva', Colors.red),
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
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 30;
    return data.map((d) => d.tasaAcuerdo).reduce((a, b) => a > b ? a : b);
  }
}
