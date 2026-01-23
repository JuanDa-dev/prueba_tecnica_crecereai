import 'package:flutter/material.dart';

/// Widget de boxplot simplificado para comparar distribuciones
class BoxPlotChart extends StatelessWidget {
  final Map<String, List<double>> data;
  final String title;
  final String yLabel;

  const BoxPlotChart({
    super.key,
    required this.data,
    required this.title,
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
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final entries = data.entries.toList();
                  final boxWidth = constraints.maxWidth / (entries.length * 2 + 1);
                  
                  // Calcular escala Y
                  final allValues = data.values.expand((v) => v).toList();
                  final double minY = allValues.isEmpty ? 0.0 : allValues.reduce((a, b) => a < b ? a : b);
                  final double maxY = allValues.isEmpty ? 1.0 : allValues.reduce((a, b) => a > b ? a : b);
                  final range = maxY - minY;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Eje Y
                      SizedBox(
                        width: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(maxY.toStringAsFixed(2), style: const TextStyle(fontSize: 10)),
                            Text(((maxY + minY) / 2).toStringAsFixed(2), style: const TextStyle(fontSize: 10)),
                            Text(minY.toStringAsFixed(2), style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Área de gráfico
                      Expanded(
                        child: CustomPaint(
                          painter: _BoxPlotPainter(
                            data: data,
                            minY: minY,
                            maxY: maxY,
                            colors: [Colors.red.shade300, Colors.green.shade400],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: entries.map((e) => Text(
                                  e.key,
                                  style: const TextStyle(fontSize: 11),
                                )).toList(),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                yLabel,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxPlotPainter extends CustomPainter {
  final Map<String, List<double>> data;
  final double minY;
  final double maxY;
  final List<Color> colors;

  _BoxPlotPainter({
    required this.data,
    required this.minY,
    required this.maxY,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final entries = data.entries.toList();
    if (entries.isEmpty) return;

    final boxWidth = size.width / (entries.length * 2 + 1);
    final range = maxY - minY;
    if (range == 0) return;

    for (var i = 0; i < entries.length; i++) {
      final values = entries[i].value..sort();
      if (values.isEmpty) continue;

      final color = colors[i % colors.length];
      final centerX = boxWidth * (i * 2 + 1.5);

      // Calcular estadísticas
      final q1 = _percentile(values, 25);
      final q2 = _percentile(values, 50);
      final q3 = _percentile(values, 75);
      final iqr = q3 - q1;
      final whiskerLow = values.firstWhere((v) => v >= q1 - 1.5 * iqr, orElse: () => values.first);
      final whiskerHigh = values.lastWhere((v) => v <= q3 + 1.5 * iqr, orElse: () => values.last);

      // Convertir a coordenadas de pantalla
      double toY(double val) => size.height - 30 - ((val - minY) / range) * (size.height - 40);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Dibujar caja
      final rect = Rect.fromLTRB(
        centerX - boxWidth * 0.4,
        toY(q3),
        centerX + boxWidth * 0.4,
        toY(q1),
      );
      canvas.drawRect(rect, paint..color = color.withOpacity(0.5));
      canvas.drawRect(rect, strokePaint);

      // Dibujar mediana
      canvas.drawLine(
        Offset(centerX - boxWidth * 0.4, toY(q2)),
        Offset(centerX + boxWidth * 0.4, toY(q2)),
        Paint()..color = Colors.black..strokeWidth = 2,
      );

      // Dibujar bigotes
      canvas.drawLine(
        Offset(centerX, toY(q1)),
        Offset(centerX, toY(whiskerLow)),
        strokePaint,
      );
      canvas.drawLine(
        Offset(centerX - boxWidth * 0.2, toY(whiskerLow)),
        Offset(centerX + boxWidth * 0.2, toY(whiskerLow)),
        strokePaint,
      );

      canvas.drawLine(
        Offset(centerX, toY(q3)),
        Offset(centerX, toY(whiskerHigh)),
        strokePaint,
      );
      canvas.drawLine(
        Offset(centerX - boxWidth * 0.2, toY(whiskerHigh)),
        Offset(centerX + boxWidth * 0.2, toY(whiskerHigh)),
        strokePaint,
      );
    }
  }

  double _percentile(List<double> sorted, int percentile) {
    final index = (sorted.length - 1) * percentile / 100;
    final lower = sorted[index.floor()];
    final upper = sorted[index.ceil()];
    return lower + (upper - lower) * (index - index.floor());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
