import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../models/deudor_model.dart';

/// Servicio para cargar y procesar los datos del dashboard
class DataService {
  List<Deudor>? _deudores;
  
  /// Carga los datos desde el archivo JSON
  Future<List<Deudor>> loadDeudores() async {
    if (_deudores != null) return _deudores!;
    
    final jsonString = await rootBundle.loadString('assets/data/deudores.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _deudores = jsonList.map((json) => Deudor.fromJson(json)).toList();
    return _deudores!;
  }

  /// Obtiene estadísticas generales del dashboard
  Future<DashboardStats> getStats() async {
    final deudores = await loadDeudores();
    return DashboardStats.fromDeudores(deudores);
  }

  /// Genera datos para histograma de edad
  Future<List<HistogramBin>> getHistogramaEdad() async {
    final deudores = await loadDeudores();
    return _generarHistograma(
      valores: deudores.map((d) => d.edad.toDouble()).toList(),
      bins: 10,
    );
  }

  /// Genera datos para histograma de monto de deuda
  Future<List<HistogramBin>> getHistogramaDeuda() async {
    final deudores = await loadDeudores();
    return _generarHistograma(
      valores: deudores.map((d) => d.montoDeuda / 1000000).toList(), // En millones
      bins: 10,
    );
  }

  /// Genera datos para histograma de ingreso
  Future<List<HistogramBin>> getHistogramaIngreso() async {
    final deudores = await loadDeudores();
    return _generarHistograma(
      valores: deudores.map((d) => d.ingreso / 1000000).toList(), // En millones
      bins: 10,
    );
  }

  /// Genera datos para histograma de días en mora
  Future<List<HistogramBin>> getHistogramaDiasMora() async {
    final deudores = await loadDeudores();
    return _generarHistograma(
      valores: deudores.map((d) => d.diasMora.toDouble()).toList(),
      bins: 10,
    );
  }

  /// Obtiene datos agrupados por tipo de crédito
  Future<List<BarChartGroupData>> getDatosPorTipoCredito() async {
    final deudores = await loadDeudores();
    return _agruparPorCategoria(
      deudores: deudores,
      getCategoria: (d) => d.tipoCredito,
    );
  }

  /// Obtiene datos agrupados por estado civil
  Future<List<BarChartGroupData>> getDatosPorEstadoCivil() async {
    final deudores = await loadDeudores();
    return _agruparPorCategoria(
      deudores: deudores,
      getCategoria: (d) => d.estadoCivil,
    );
  }

  /// Obtiene datos agrupados por país de origen
  Future<List<BarChartGroupData>> getDatosPorPaisOrigen() async {
    final deudores = await loadDeudores();
    return _agruparPorCategoria(
      deudores: deudores,
      getCategoria: (d) => d.paisOrigen,
    );
  }

  /// Obtiene datos agrupados por estrategia de negociación
  Future<List<BarChartGroupData>> getDatosPorEstrategia() async {
    final deudores = await loadDeudores();
    return _agruparPorCategoria(
      deudores: deudores,
      getCategoria: (d) => d.negociacionAgresiva ? 'Agresiva' : 'Normal',
    );
  }

  /// Obtiene datos de evolución mensual
  Future<List<LineChartDataPoint>> getDatosPorMes() async {
    final deudores = await loadDeudores();
    
    final Map<int, List<Deudor>> porMes = {};
    for (var d in deudores) {
      porMes.putIfAbsent(d.mes, () => []).add(d);
    }

    return List.generate(12, (i) {
      final mes = i + 1;
      final lista = porMes[mes] ?? [];
      return LineChartDataPoint(
        mes: mes,
        total: lista.length,
        acuerdos: lista.where((d) => d.acuerdoLogrado).length,
      );
    });
  }

  /// Obtiene datos para scatter plot ingreso vs deuda
  Future<List<Map<String, dynamic>>> getScatterIngresoDeuda() async {
    final deudores = await loadDeudores();
    return deudores.map((d) => {
      'x': d.ingreso / 1000000,
      'y': d.montoDeuda / 1000000,
      'acuerdo': d.acuerdoLogrado,
    }).toList();
  }

  /// Calcula la matriz de correlaciones
  Future<List<CorrelationData>> getCorrelaciones() async {
    final deudores = await loadDeudores();
    
    final variables = {
      'Días Mora': deudores.map((d) => d.diasMora.toDouble()).toList(),
      'Monto Deuda': deudores.map((d) => d.montoDeuda).toList(),
      'Edad': deudores.map((d) => d.edad.toDouble()).toList(),
      'Cuotas': deudores.map((d) => d.cuotasOfrecidas.toDouble()).toList(),
      'Descuento': deudores.map((d) => d.descuentoOfrecido).toList(),
      'Ingreso': deudores.map((d) => d.ingreso).toList(),
      'Acuerdo': deudores.map((d) => d.acuerdoLogrado ? 1.0 : 0.0).toList(),
    };

    final correlaciones = <CorrelationData>[];
    final keys = variables.keys.toList();
    
    for (var i = 0; i < keys.length; i++) {
      for (var j = 0; j < keys.length; j++) {
        correlaciones.add(CorrelationData(
          variable1: keys[i],
          variable2: keys[j],
          correlation: _calcularCorrelacion(variables[keys[i]]!, variables[keys[j]]!),
        ));
      }
    }
    
    return correlaciones;
  }

  /// Obtiene datos para boxplot por resultado
  Future<Map<String, Map<String, List<double>>>> getBoxplotData() async {
    final deudores = await loadDeudores();
    
    final conAcuerdo = deudores.where((d) => d.acuerdoLogrado).toList();
    final sinAcuerdo = deudores.where((d) => !d.acuerdoLogrado).toList();
    
    return {
      'edad': {
        'Con Acuerdo': conAcuerdo.map((d) => d.edad.toDouble()).toList(),
        'Sin Acuerdo': sinAcuerdo.map((d) => d.edad.toDouble()).toList(),
      },
      'deuda': {
        'Con Acuerdo': conAcuerdo.map((d) => d.montoDeuda / 1000000).toList(),
        'Sin Acuerdo': sinAcuerdo.map((d) => d.montoDeuda / 1000000).toList(),
      },
      'ingreso': {
        'Con Acuerdo': conAcuerdo.map((d) => d.ingreso / 1000000).toList(),
        'Sin Acuerdo': sinAcuerdo.map((d) => d.ingreso / 1000000).toList(),
      },
    };
  }

  // ============ MÉTODOS AUXILIARES ============

  // ============ PARTE 3: ANÁLISIS DESCRIPTIVO ============

  /// 3.1 Tasa de acuerdo por quintil de ingreso
  Future<List<QuintileData>> getTasaPorQuintilIngreso() async {
    final deudores = await loadDeudores();
    final ingresos = deudores.map((d) => d.ingreso).toList()..sort();
    
    final quintiles = <QuintileData>[];
    final labels = ['Q1 (Bajo)', 'Q2', 'Q3', 'Q4', 'Q5 (Alto)'];
    final n = deudores.length;
    
    for (var i = 0; i < 5; i++) {
      final startIdx = (n * i / 5).floor();
      final endIdx = (n * (i + 1) / 5).floor();
      final minIngreso = ingresos[startIdx];
      final maxIngreso = ingresos[endIdx - 1];
      
      final deudoresQuintil = deudores.where((d) => 
        d.ingreso >= minIngreso && d.ingreso <= maxIngreso).toList();
      
      final acuerdos = deudoresQuintil.where((d) => d.acuerdoLogrado).length;
      final total = deudoresQuintil.length;
      
      quintiles.add(QuintileData(
        label: labels[i],
        tasaAcuerdo: total > 0 ? (acuerdos / total) * 100 : 0,
        total: total,
        acuerdos: acuerdos,
      ));
    }
    
    return quintiles;
  }

  /// 3.2 Datos de ratio de pago (esfuerzo de pago)
  Future<Map<String, List<double>>> getRatioPagoData() async {
    final deudores = await loadDeudores();
    
    // Calcular ratio de pago para cada deudor
    final ratios = <Deudor, double>{};
    for (var d in deudores) {
      final cuotaImplicita = d.montoDeuda * (1 - d.descuentoOfrecido) / d.cuotasOfrecidas;
      final ratio = cuotaImplicita / d.ingreso;
      ratios[d] = ratio;
    }
    
    // Eliminar valores extremos (percentil 99)
    final allRatios = ratios.values.toList()..sort();
    final p99 = allRatios[(allRatios.length * 0.99).floor()];
    
    final sinAcuerdo = <double>[];
    final conAcuerdo = <double>[];
    
    for (var entry in ratios.entries) {
      if (entry.value <= p99) {
        if (entry.key.acuerdoLogrado) {
          conAcuerdo.add(entry.value);
        } else {
          sinAcuerdo.add(entry.value);
        }
      }
    }
    
    return {
      'sinAcuerdo': sinAcuerdo,
      'conAcuerdo': conAcuerdo,
    };
  }

  /// 3.3 Tasa de acuerdo por decil de descuento
  Future<List<QuintileData>> getTasaPorDecilDescuento() async {
    final deudores = await loadDeudores();
    final descuentos = deudores.map((d) => d.descuentoOfrecido).toList()..sort();
    
    final deciles = <QuintileData>[];
    final n = deudores.length;
    
    for (var i = 0; i < 10; i++) {
      final startIdx = (n * i / 10).floor();
      final endIdx = (n * (i + 1) / 10).floor();
      final minDesc = descuentos[startIdx];
      final maxDesc = descuentos[endIdx - 1];
      
      final deudoresDecil = deudores.where((d) => 
        d.descuentoOfrecido >= minDesc && d.descuentoOfrecido <= maxDesc).toList();
      
      final acuerdos = deudoresDecil.where((d) => d.acuerdoLogrado).length;
      final total = deudoresDecil.length;
      
      deciles.add(QuintileData(
        label: '${(i * 10)}-${((i + 1) * 10)}%',
        tasaAcuerdo: total > 0 ? (acuerdos / total) * 100 : 0,
        total: total,
        acuerdos: acuerdos,
      ));
    }
    
    return deciles;
  }

  /// 3.4 Interacción descuento × antigüedad
  Future<List<InteractionData>> getInteraccionDescuentoAntiguedad() async {
    final deudores = await loadDeudores();
    
    // Dividir antigüedad en terciles (como pd.qcut en el notebook)
    final diasMora = deudores.map((d) => d.diasMora).toList()..sort();
    final n = diasMora.length;
    final tercil1 = diasMora[(n / 3).floor()];
    final tercil2 = diasMora[(2 * n / 3).floor()];
    
    String getGrupoAntiguedad(int dias) {
      if (dias <= tercil1) return 'Baja';
      if (dias <= tercil2) return 'Media';
      return 'Alta';
    }
    
    // Dividir descuento en quintiles REALES (como pd.qcut en el notebook)
    final descuentos = deudores.map((d) => d.descuentoOfrecido).toList()..sort();
    final nDesc = descuentos.length;
    final q1 = descuentos[(nDesc * 0.2).floor()];
    final q2 = descuentos[(nDesc * 0.4).floor()];
    final q3 = descuentos[(nDesc * 0.6).floor()];
    final q4 = descuentos[(nDesc * 0.8).floor()];
    
    String getGrupoDescuento(double desc) {
      if (desc <= q1) return '0-20%';
      if (desc <= q2) return '20-40%';
      if (desc <= q3) return '40-60%';
      if (desc <= q4) return '60-80%';
      return '80-100%';
    }
    
    final Map<String, Map<String, List<Deudor>>> grupos = {};
    for (var d in deudores) {
      final antiguedad = getGrupoAntiguedad(d.diasMora);
      final descuento = getGrupoDescuento(d.descuentoOfrecido);
      grupos.putIfAbsent(antiguedad, () => {});
      grupos[antiguedad]!.putIfAbsent(descuento, () => []).add(d);
    }
    
    final result = <InteractionData>[];
    for (var antiguedad in ['Baja', 'Media', 'Alta']) {
      for (var descuento in ['0-20%', '20-40%', '40-60%', '60-80%', '80-100%']) {
        final lista = grupos[antiguedad]?[descuento] ?? [];
        final acuerdos = lista.where((d) => d.acuerdoLogrado).length;
        result.add(InteractionData(
          grupoAntiguedad: antiguedad,
          grupoDescuento: descuento,
          tasaAcuerdo: lista.isNotEmpty ? (acuerdos / lista.length) * 100 : 0,
          total: lista.length,
        ));
      }
    }
    
    return result;
  }

  /// 3.5 y 3.6 Efecto de estrategia por nivel de ingreso
  Future<List<StrategyData>> getEfectoEstrategiaPorIngreso() async {
    final deudores = await loadDeudores();
    
    // Dividir ingreso en terciles
    final ingresos = deudores.map((d) => d.ingreso).toList()..sort();
    final n = ingresos.length;
    final tercil1 = ingresos[(n / 3).floor()];
    final tercil2 = ingresos[(2 * n / 3).floor()];
    
    String getGrupoIngreso(double ingreso) {
      if (ingreso <= tercil1) return 'Bajo';
      if (ingreso <= tercil2) return 'Medio';
      return 'Alto';
    }
    
    final Map<String, Map<bool, List<Deudor>>> grupos = {};
    for (var d in deudores) {
      final ingreso = getGrupoIngreso(d.ingreso);
      grupos.putIfAbsent(ingreso, () => {});
      grupos[ingreso]!.putIfAbsent(d.negociacionAgresiva, () => []).add(d);
    }
    
    final result = <StrategyData>[];
    for (var ingreso in ['Bajo', 'Medio', 'Alto']) {
      for (var agresiva in [false, true]) {
        final lista = grupos[ingreso]?[agresiva] ?? [];
        final acuerdos = lista.where((d) => d.acuerdoLogrado).length;
        result.add(StrategyData(
          grupoIngreso: ingreso,
          estrategiaAgresiva: agresiva,
          tasaAcuerdo: lista.isNotEmpty ? (acuerdos / lista.length) * 100 : 0,
          total: lista.length,
        ));
      }
    }
    
    return result;
  }

  /// 3.7 Relación tenencia de propiedades y acuerdo
  Future<List<PropertyData>> getTasaPorPropiedades() async {
    final deudores = await loadDeudores();
    
    final result = <PropertyData>[];
    
    for (var tieneProp in [false, true]) {
      final lista = deudores.where((d) => d.tienePropiedades == tieneProp).toList();
      final acuerdos = lista.where((d) => d.acuerdoLogrado).length;
      result.add(PropertyData(
        tienePropiedades: tieneProp,
        tasaAcuerdo: lista.isNotEmpty ? (acuerdos / lista.length) * 100 : 0,
        total: lista.length,
        acuerdos: acuerdos,
      ));
    }
    
    return result;
  }

  // ============ MÉTODOS AUXILIARES ORIGINALES ============

  List<HistogramBin> _generarHistograma({
    required List<double> valores,
    required int bins,
  }) {
    if (valores.isEmpty) return [];
    
    final min = valores.reduce((a, b) => a < b ? a : b);
    final max = valores.reduce((a, b) => a > b ? a : b);
    final binWidth = (max - min) / bins;
    
    final counts = List.filled(bins, 0);
    for (var v in valores) {
      var binIndex = ((v - min) / binWidth).floor();
      if (binIndex >= bins) binIndex = bins - 1;
      counts[binIndex]++;
    }
    
    return List.generate(bins, (i) => HistogramBin(
      inicio: min + i * binWidth,
      fin: min + (i + 1) * binWidth,
      count: counts[i],
    ));
  }

  List<BarChartGroupData> _agruparPorCategoria({
    required List<Deudor> deudores,
    required String Function(Deudor) getCategoria,
  }) {
    final Map<String, List<Deudor>> grupos = {};
    for (var d in deudores) {
      final cat = getCategoria(d);
      grupos.putIfAbsent(cat, () => []).add(d);
    }

    return grupos.entries.map((e) {
      final conAcuerdo = e.value.where((d) => d.acuerdoLogrado).length;
      return BarChartGroupData(
        categoria: e.key,
        conAcuerdo: conAcuerdo,
        sinAcuerdo: e.value.length - conAcuerdo,
      );
    }).toList()..sort((a, b) => b.conAcuerdo.compareTo(a.conAcuerdo));
  }

  double _calcularCorrelacion(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0;
    
    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;
    
    var numerator = 0.0;
    var denomX = 0.0;
    var denomY = 0.0;
    
    for (var i = 0; i < n; i++) {
      final dx = x[i] - meanX;
      final dy = y[i] - meanY;
      numerator += dx * dy;
      denomX += dx * dx;
      denomY += dy * dy;
    }
    
    // Fórmula correcta de correlación de Pearson: r = Σ(xi-x̄)(yi-ȳ) / sqrt(Σ(xi-x̄)² * Σ(yi-ȳ)²)
    final denomProduct = denomX * denomY;
    if (denomProduct <= 0) return 0;
    
    return numerator / math.sqrt(denomProduct);
  }
}
