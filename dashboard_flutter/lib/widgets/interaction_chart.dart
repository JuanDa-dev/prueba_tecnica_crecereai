import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/deudor_model.dart';

/// Widget para visualizar interacción descuento × antigüedad
class InteractionChart extends StatelessWidget {
  final List<InteractionData> data;
  final String title;

  const InteractionChart({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gruposAntiguedad = ['Baja', 'Media', 'Alta'];
    final gruposDescuento = ['0-20%', '20-40%', '40-60%', '60-80%', '80-100%'];
    final colores = [Colors.blue, Colors.orange, Colors.purple];

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
            _buildLegend(gruposAntiguedad, colores),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 4,
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: gruposAntiguedad.asMap().entries.map((entry) {
                    final antiguedad = entry.value;
                    final color = colores[entry.key];
                    final puntos = gruposDescuento.asMap().entries.map((descEntry) {
                      final descuento = descEntry.value;
                      final item = data.firstWhere(
                        (d) => d.grupoAntiguedad == antiguedad && d.grupoDescuento == descuento,
                        orElse: () => InteractionData(
                          grupoAntiguedad: antiguedad,
                          grupoDescuento: descuento,
                          tasaAcuerdo: 0,
                          total: 0,
                        ),
                      );
                      return FlSpot(descEntry.key.toDouble(), item.tasaAcuerdo);
                    }).toList();

                    return LineChartBarData(
                      spots: puntos,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Rango de Descuento', style: TextStyle(fontSize: 11)),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < gruposDescuento.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                gruposDescuento[value.toInt()],
                                style: const TextStyle(fontSize: 9),
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
                            '${value.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
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
                          final antiguedad = gruposAntiguedad[spot.barIndex];
                          final descuento = gruposDescuento[spot.x.toInt()];
                          return LineTooltipItem(
                            '$antiguedad\n$descuento: ${spot.y.toStringAsFixed(1)}%',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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

  Widget _buildLegend(List<String> labels, List<Color> colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: labels.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 3,
                color: colors[entry.key],
              ),
              const SizedBox(width: 4),
              Text('Antigüedad ${entry.value}', style: const TextStyle(fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 30;
    return (data.map((d) => d.tasaAcuerdo).reduce((a, b) => a > b ? a : b) * 1.2).clamp(0, 100);
  }
}
