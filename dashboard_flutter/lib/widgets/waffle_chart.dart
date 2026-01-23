import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget tipo Waffle/Pictograma para mostrar proporciones
class WaffleChart extends StatelessWidget {
  final int conAcuerdo;
  final int sinAcuerdo;
  final String title;

  const WaffleChart({
    super.key,
    required this.conAcuerdo,
    required this.sinAcuerdo,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final total = conAcuerdo + sinAcuerdo;
    final pctAcuerdo = total > 0 ? (conAcuerdo / total * 100).round() : 0;
    final pctSinAcuerdo = 100 - pctAcuerdo;

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
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = constraints.maxWidth / 10;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(10, (row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(10, (col) {
                              final index = (9 - row) * 10 + col;
                              final isAcuerdo = index < pctAcuerdo;
                              return Container(
                                width: cellSize - 4,
                                height: cellSize - 4,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isAcuerdo 
                                    ? Colors.green.shade400 
                                    : Colors.red.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(pctAcuerdo, pctSinAcuerdo),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: $total casos',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(int pctAcuerdo, int pctSinAcuerdo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem('Con acuerdo: $pctAcuerdo%', Colors.green.shade400),
        const SizedBox(width: 24),
        _legendItem('Sin acuerdo: $pctSinAcuerdo%', Colors.red.shade300),
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
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Widget de gráfico circular (pie chart)
class PieChartWidget extends StatelessWidget {
  final int conAcuerdo;
  final int sinAcuerdo;
  final String title;

  const PieChartWidget({
    super.key,
    required this.conAcuerdo,
    required this.sinAcuerdo,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final total = conAcuerdo + sinAcuerdo;
    
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
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: conAcuerdo.toDouble(),
                      title: '${(conAcuerdo / total * 100).toStringAsFixed(1)}%',
                      color: Colors.green.shade400,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    PieChartSectionData(
                      value: sinAcuerdo.toDouble(),
                      title: '${(sinAcuerdo / total * 100).toStringAsFixed(1)}%',
                      color: Colors.red.shade300,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem('Con acuerdo ($conAcuerdo)', Colors.green.shade400),
                const SizedBox(width: 24),
                _legendItem('Sin acuerdo ($sinAcuerdo)', Colors.red.shade300),
              ],
            ),
          ],
        ),
      ),
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
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
