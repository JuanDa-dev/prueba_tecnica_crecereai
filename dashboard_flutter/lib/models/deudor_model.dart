/// Modelo de datos para cada deudor
class Deudor {
  final int diasMora;
  final double montoDeuda;
  final bool esMujer;
  final int edad;
  final bool viveBogota;
  final int cuotasOfrecidas;
  final double descuentoOfrecido;
  final bool negociacionAgresiva;
  final String paisOrigen;
  final String estadoCivil;
  final bool tienePropiedades;
  final String tipoCredito;
  final bool recibeSubsidios;
  final String heladoFavorito;
  final int mes;
  final double ingreso;
  final bool acuerdoLogrado;

  Deudor({
    required this.diasMora,
    required this.montoDeuda,
    required this.esMujer,
    required this.edad,
    required this.viveBogota,
    required this.cuotasOfrecidas,
    required this.descuentoOfrecido,
    required this.negociacionAgresiva,
    required this.paisOrigen,
    required this.estadoCivil,
    required this.tienePropiedades,
    required this.tipoCredito,
    required this.recibeSubsidios,
    required this.heladoFavorito,
    required this.mes,
    required this.ingreso,
    required this.acuerdoLogrado,
  });

  factory Deudor.fromJson(Map<String, dynamic> json) {
    return Deudor(
      diasMora: json['dias_mora'] as int,
      montoDeuda: (json['monto_deuda'] as num).toDouble(),
      esMujer: json['es_mujer'] == 1,
      edad: json['edad'] as int,
      viveBogota: json['vive_bogota'] == 1,
      cuotasOfrecidas: json['cuotas_ofrecidas'] as int,
      descuentoOfrecido: (json['descuento_ofrecido'] as num).toDouble(),
      negociacionAgresiva: json['negociacion_agresiva'] == 1,
      paisOrigen: json['pais_origen'] as String,
      estadoCivil: json['estado_civil'] as String,
      tienePropiedades: json['tiene_propiedades'] == 1,
      tipoCredito: json['tipo_credito'] as String,
      recibeSubsidios: json['recibe_subsidios'] == 1,
      heladoFavorito: json['helado_favorito'] as String,
      mes: json['mes'] as int,
      ingreso: (json['ingreso'] as num).toDouble(),
      acuerdoLogrado: json['acuerdo_logrado'] == 1,
    );
  }
}

/// Estadísticas agregadas del dataset
class DashboardStats {
  final int totalDeudores;
  final int conAcuerdo;
  final int sinAcuerdo;
  final double tasaExito;
  final double promedioEdad;
  final double promedioDeuda;
  final double promedioIngreso;
  final double promedioDiasMora;

  DashboardStats({
    required this.totalDeudores,
    required this.conAcuerdo,
    required this.sinAcuerdo,
    required this.tasaExito,
    required this.promedioEdad,
    required this.promedioDeuda,
    required this.promedioIngreso,
    required this.promedioDiasMora,
  });

  factory DashboardStats.fromDeudores(List<Deudor> deudores) {
    final total = deudores.length;
    final conAcuerdo = deudores.where((d) => d.acuerdoLogrado).length;
    
    return DashboardStats(
      totalDeudores: total,
      conAcuerdo: conAcuerdo,
      sinAcuerdo: total - conAcuerdo,
      tasaExito: total > 0 ? (conAcuerdo / total) * 100 : 0,
      promedioEdad: _promedio(deudores.map((d) => d.edad.toDouble())),
      promedioDeuda: _promedio(deudores.map((d) => d.montoDeuda)),
      promedioIngreso: _promedio(deudores.map((d) => d.ingreso)),
      promedioDiasMora: _promedio(deudores.map((d) => d.diasMora.toDouble())),
    );
  }

  static double _promedio(Iterable<double> valores) {
    if (valores.isEmpty) return 0;
    return valores.reduce((a, b) => a + b) / valores.length;
  }
}

/// Datos para gráficas de barras agrupadas
class BarChartGroupData {
  final String categoria;
  final int conAcuerdo;
  final int sinAcuerdo;
  final double tasaExito;

  BarChartGroupData({
    required this.categoria,
    required this.conAcuerdo,
    required this.sinAcuerdo,
  }) : tasaExito = (conAcuerdo + sinAcuerdo) > 0 
      ? (conAcuerdo / (conAcuerdo + sinAcuerdo)) * 100 
      : 0;
}

/// Datos para gráficas de línea (series temporales)
class LineChartDataPoint {
  final int mes;
  final String mesNombre;
  final int total;
  final int acuerdos;
  final double tasaExito;

  LineChartDataPoint({
    required this.mes,
    required this.total,
    required this.acuerdos,
  }) : mesNombre = _nombreMes(mes),
       tasaExito = total > 0 ? (acuerdos / total) * 100 : 0;

  static String _nombreMes(int mes) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return meses[mes - 1];
  }
}

/// Datos para histogramas
class HistogramBin {
  final double inicio;
  final double fin;
  final int count;
  final String label;

  HistogramBin({
    required this.inicio,
    required this.fin,
    required this.count,
  }) : label = '${inicio.toStringAsFixed(0)}-${fin.toStringAsFixed(0)}';
}

/// Datos para el mapa de calor de correlaciones
class CorrelationData {
  final String variable1;
  final String variable2;
  final double correlation;

  CorrelationData({
    required this.variable1,
    required this.variable2,
    required this.correlation,
  });
}

// ============ MODELOS PARA PARTE 3 ============

/// Datos para gráficos de quintiles/deciles
class QuintileData {
  final String label;
  final double tasaAcuerdo;
  final int total;
  final int acuerdos;

  QuintileData({
    required this.label,
    required this.tasaAcuerdo,
    required this.total,
    required this.acuerdos,
  });
}

/// Datos para análisis de interacción
class InteractionData {
  final String grupoAntiguedad;
  final String grupoDescuento;
  final double tasaAcuerdo;
  final int total;

  InteractionData({
    required this.grupoAntiguedad,
    required this.grupoDescuento,
    required this.tasaAcuerdo,
    required this.total,
  });
}

/// Datos para análisis de estrategia
class StrategyData {
  final String grupoIngreso;
  final bool estrategiaAgresiva;
  final double tasaAcuerdo;
  final int total;

  StrategyData({
    required this.grupoIngreso,
    required this.estrategiaAgresiva,
    required this.tasaAcuerdo,
    required this.total,
  });
}

/// Datos para análisis de propiedades
class PropertyData {
  final bool tienePropiedades;
  final double tasaAcuerdo;
  final int total;
  final int acuerdos;

  PropertyData({
    required this.tienePropiedades,
    required this.tasaAcuerdo,
    required this.total,
    required this.acuerdos,
  });
}
