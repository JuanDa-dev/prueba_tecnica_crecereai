import 'package:flutter/material.dart';
import '../models/deudor_model.dart';

/// Widget de mapa de calor para correlaciones
class HeatmapChart extends StatelessWidget {
  final List<CorrelationData> data;
  final String title;

  const HeatmapChart({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Extraer variables únicas MANTENIENDO EL ORDEN original
    final seen = <String>{};
    final variables = <String>[];
    for (final d in data) {
      if (seen.add(d.variable1)) {
        variables.add(d.variable1);
      }
    }
    final n = variables.length;
    
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
                  final cellSize = (constraints.maxWidth - 100) / n;
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        // Header row
                        Row(
                          children: [
                            const SizedBox(width: 100), // Espacio para labels de filas
                            ...variables.map((v) => SizedBox(
                              width: cellSize,
                              child: RotatedBox(
                                quarterTurns: -1,
                                child: Text(
                                  _truncate(v, 10),
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Data rows
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: variables.map((rowVar) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        _truncate(rowVar, 12),
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    ...variables.map((colVar) {
                                      final corr = _getCorrelation(rowVar, colVar);
                                      return Container(
                                        width: cellSize,
                                        height: cellSize,
                                        margin: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: _getColor(corr),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            corr.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: corr.abs() > 0.5 
                                                ? Colors.white 
                                                : Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Color scale legend
                        _buildColorScale(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getCorrelation(String var1, String var2) {
    final item = data.firstWhere(
      (d) => d.variable1 == var1 && d.variable2 == var2,
      orElse: () => CorrelationData(variable1: var1, variable2: var2, correlation: 0),
    );
    return item.correlation;
  }

  Color _getColor(double correlation) {
    // Escala de colores: rojo (-1) → blanco (0) → azul (1)
    if (correlation >= 0) {
      return Color.lerp(Colors.white, Colors.blue.shade700, correlation) ?? Colors.white;
    } else {
      return Color.lerp(Colors.white, Colors.red.shade700, -correlation) ?? Colors.white;
    }
  }

  Widget _buildColorScale() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('-1', style: TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        Container(
          width: 150,
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade700, Colors.white, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        const Text('+1', style: TextStyle(fontSize: 10)),
      ],
    );
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 2)}..';
  }
}
