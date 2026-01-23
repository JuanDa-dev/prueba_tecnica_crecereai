import 'package:flutter/material.dart';
import '../models/deudor_model.dart' as models;
import '../services/data_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/histogram_chart.dart';
import '../widgets/grouped_bar_chart.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/scatter_chart_widget.dart';
import '../widgets/heatmap_chart.dart';
import '../widgets/waffle_chart.dart';
import '../widgets/rate_bar_chart.dart';
import '../widgets/interaction_chart.dart';
import '../widgets/strategy_chart.dart';
import '../widgets/boxplot_chart.dart';

/// Pantalla principal del Dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DataService _dataService = DataService();
  int _selectedIndex = 0;
  
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard, label: 'Resumen'),
    _NavItem(icon: Icons.bar_chart, label: 'Histogramas'),
    _NavItem(icon: Icons.stacked_bar_chart, label: 'Barras'),
    _NavItem(icon: Icons.show_chart, label: 'Líneas'),
    _NavItem(icon: Icons.scatter_plot, label: 'Dispersión'),
    _NavItem(icon: Icons.grid_on, label: 'Correlaciones'),
    _NavItem(icon: Icons.science, label: 'Hipótesis'),  // Nueva sección Parte 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navegación lateral
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            minExtendedWidth: 200,
            destinations: _navItems.map((item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            )).toList(),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 1200) ...[
                    const SizedBox(height: 8),
                    Text(
                      'CrecereAI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard de Negociación de Deudas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Análisis de deudores en mora (>180 días) | ${_navItems[_selectedIndex].label}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Autor: Juan David Anzola Q.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildResumenPage();
      case 1:
        return _buildHistogramasPage();
      case 2:
        return _buildBarrasPage();
      case 3:
        return _buildLineasPage();
      case 4:
        return _buildDispersionPage();
      case 5:
        return _buildCorrelacionesPage();
      case 6:
        return _buildHipotesisPage();  // Nueva Parte 3
      default:
        return _buildResumenPage();
    }
  }

  /// Página de Resumen con KPIs y gráficos principales
  Widget _buildResumenPage() {
    return FutureBuilder<models.DashboardStats>(
      future: _dataService.getStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error al cargar datos: ${snapshot.error}'),
                const SizedBox(height: 8),
                const Text(
                  'Asegúrate de ejecutar exportar_datos_flutter.py primero',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs principales
              GridView.count(
                crossAxisCount: _getGridColumns(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  StatCard(
                    title: 'Total Deudores',
                    value: stats.totalDeudores.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: 'Con Acuerdo',
                    value: stats.conAcuerdo.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                    subtitle: '${stats.tasaExito.toStringAsFixed(1)}% de éxito',
                  ),
                  StatCard(
                    title: 'Sin Acuerdo',
                    value: stats.sinAcuerdo.toString(),
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                  StatCard(
                    title: 'Promedio Edad',
                    value: '${stats.promedioEdad.toStringAsFixed(0)} años',
                    icon: Icons.person,
                    color: Colors.purple,
                  ),
                  StatCard(
                    title: 'Deuda Promedio',
                    value: '\$${(stats.promedioDeuda / 1000000).toStringAsFixed(1)}M',
                    icon: Icons.account_balance,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: 'Ingreso Promedio',
                    value: '\$${(stats.promedioIngreso / 1000000).toStringAsFixed(1)}M',
                    icon: Icons.attach_money,
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Gráficos de resumen
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 350,
                      child: WaffleChart(
                        conAcuerdo: stats.conAcuerdo,
                        sinAcuerdo: stats.sinAcuerdo,
                        title: 'Resultados de Negociación (cada cuadro = 1%)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 350,
                      child: PieChartWidget(
                        conAcuerdo: stats.conAcuerdo,
                        sinAcuerdo: stats.sinAcuerdo,
                        title: 'Distribución de Acuerdos',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Página de Histogramas
  Widget _buildHistogramasPage() {
    return FutureBuilder<List<models.Deudor>>(
      future: _dataService.loadDeudores(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final deudores = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distribución de Variables Numéricas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  HistogramChart(
                    data: deudores.map((d) => d.edad.toDouble()).toList(),
                    title: 'Distribución de Edad',
                    color: Colors.blue,
                    xlabel: 'Años',
                  ),
                  HistogramChart(
                    data: deudores.map((d) => d.montoDeuda / 1000000).toList(),
                    title: 'Distribución del Monto de Deuda',
                    color: Colors.orange,
                    xlabel: 'Millones de pesos',
                  ),
                  HistogramChart(
                    data: deudores.map((d) => d.ingreso / 1000000).toList(),
                    title: 'Distribución del Ingreso Mensual',
                    color: Colors.green,
                    xlabel: 'Millones de pesos',
                  ),
                  HistogramChart(
                    data: deudores.map((d) => d.diasMora.toDouble()).toList(),
                    title: 'Distribución de Días en Mora',
                    color: Colors.purple,
                    xlabel: 'Días',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Página de Gráficos de Barras
  Widget _buildBarrasPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acuerdos por Categoría',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: Future.wait([
              _dataService.getDatosPorTipoCredito(),
              _dataService.getDatosPorEstadoCivil(),
              _dataService.getDatosPorPaisOrigen(),
              _dataService.getDatosPorEstrategia(),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final tipoCredito = snapshot.data![0] as List<models.BarChartGroupData>;
              final estadoCivil = snapshot.data![1] as List<models.BarChartGroupData>;
              final paisOrigen = snapshot.data![2] as List<models.BarChartGroupData>;
              final estrategia = snapshot.data![3] as List<models.BarChartGroupData>;
              
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  GroupedBarChart(
                    data: tipoCredito,
                    title: 'Acuerdos por Tipo de Crédito',
                  ),
                  GroupedBarChart(
                    data: estadoCivil,
                    title: 'Acuerdos por Estado Civil',
                  ),
                  GroupedBarChart(
                    data: paisOrigen,
                    title: 'Acuerdos por País de Origen',
                  ),
                  GroupedBarChart(
                    data: estrategia,
                    title: 'Acuerdos por Estrategia de Negociación',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Página de Gráficos de Líneas
  Widget _buildLineasPage() {
    return FutureBuilder<List<models.LineChartDataPoint>>(
      future: _dataService.getDatosPorMes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolución Temporal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 400,
                      child: TimeSeriesChart(
                        data: snapshot.data!,
                        title: 'Número de Negociaciones por Mes',
                        showRate: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 400,
                      child: TimeSeriesChart(
                        data: snapshot.data!,
                        title: 'Tasa de Éxito por Mes (%)',
                        showRate: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Página de Gráficos de Dispersión
  Widget _buildDispersionPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dataService.getScatterIngresoDeuda(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Análisis de Dispersión',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 500,
                child: ScatterChartWidget(
                  data: snapshot.data!,
                  title: 'Ingreso vs Monto de Deuda',
                  xLabel: 'Ingreso (millones)',
                  yLabel: 'Monto Deuda (millones)',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Página de Mapa de Correlaciones
  Widget _buildCorrelacionesPage() {
    return FutureBuilder<List<models.CorrelationData>>(
      future: _dataService.getCorrelaciones(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Matriz de Correlaciones',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 500,
                child: HeatmapChart(
                  data: snapshot.data!,
                  title: 'Correlaciones entre Variables Numéricas',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Página de Hipótesis - Parte 3: Validación de Hipótesis
  Widget _buildHipotesisPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parte 3: Validación de Hipótesis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Análisis descriptivo para validar hipótesis sobre factores que influyen en el logro de acuerdos de pago.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          // 3.1 Tasa por quintil de ingreso
          _buildSectionTitle('3.1 Relación entre Ingreso y Probabilidad de Acuerdo'),
          _buildHypothesisCard('Los deudores con mayores ingresos tienen mayor probabilidad de llegar a un acuerdo.'),
          FutureBuilder<List<models.QuintileData>>(
            future: _dataService.getTasaPorQuintilIngreso(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final promedio = snapshot.data!.map((d) => d.tasaAcuerdo).reduce((a, b) => a + b) / snapshot.data!.length;
              return SizedBox(
                height: 350,
                child: RateBarChart(
                  data: snapshot.data!,
                  title: 'Probabilidad de Acuerdo según Nivel de Ingreso',
                  color: Colors.green,
                  averageLine: promedio,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // 3.2 Ratio de pago (esfuerzo de pago)
          _buildSectionTitle('3.2 Esfuerzo de Pago (Ratio Pago) y su Relación con el Acuerdo'),
          _buildHypothesisCard('Los deudores que llegan a un acuerdo enfrentan, en promedio, un menor esfuerzo de pago relativo.'),
          FutureBuilder<Map<String, List<double>>>(
            future: _dataService.getRatioPagoData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return SizedBox(
                height: 350,
                child: BoxPlotChart(
                  data: {
                    'Sin Acuerdo': snapshot.data!['sinAcuerdo']!,
                    'Con Acuerdo': snapshot.data!['conAcuerdo']!,
                  },
                  title: 'Distribución del Esfuerzo de Pago',
                  yLabel: 'Ratio de Pago (cuota/ingreso)',
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // 3.3 Tasa por decil de descuento
          _buildSectionTitle('3.3 Relación entre Descuento Ofrecido y Probabilidad de Acuerdo'),
          _buildHypothesisCard('A mayor descuento ofrecido, mayor probabilidad de que el deudor acepte un acuerdo.'),
          FutureBuilder<List<models.QuintileData>>(
            future: _dataService.getTasaPorDecilDescuento(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final promedio = snapshot.data!.map((d) => d.tasaAcuerdo).reduce((a, b) => a + b) / snapshot.data!.length;
              return SizedBox(
                height: 350,
                child: RateBarChart(
                  data: snapshot.data!,
                  title: 'Probabilidad de Acuerdo según Descuento Ofrecido',
                  color: Colors.blue,
                  averageLine: promedio,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // 3.4 Interacción descuento × antigüedad
          _buildSectionTitle('3.4 Interacción entre Descuento y Antigüedad de la Deuda'),
          _buildHypothesisCard('El efecto del descuento ofrecido sobre la probabilidad de acuerdo varía según la antigüedad de la deuda.'),
          FutureBuilder<List<models.InteractionData>>(
            future: _dataService.getInteraccionDescuentoAntiguedad(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return SizedBox(
                height: 400,
                child: InteractionChart(
                  data: snapshot.data!,
                  title: 'Interacción: Descuento × Antigüedad de la Deuda',
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // 3.5 y 3.6 Efecto de estrategia por ingreso
          _buildSectionTitle('3.5-3.6 Efecto de la Estrategia de Negociación según Nivel de Ingreso'),
          _buildHypothesisCard('El efecto de la estrategia de negociación agresiva sobre el acuerdo podría variar según el nivel de ingreso del deudor.'),
          FutureBuilder<List<models.StrategyData>>(
            future: _dataService.getEfectoEstrategiaPorIngreso(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return SizedBox(
                height: 400,
                child: StrategyChart(
                  data: snapshot.data!,
                  title: 'Efecto de la Estrategia de Negociación según Nivel de Ingreso',
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // 3.7 Tenencia de propiedades
          _buildSectionTitle('3.7 Relación entre Tenencia de Propiedades y Probabilidad de Acuerdo'),
          _buildHypothesisCard('Los deudores que tienen propiedades podrían tener mayor probabilidad de llegar a un acuerdo.'),
          FutureBuilder<List<models.PropertyData>>(
            future: _dataService.getTasaPorPropiedades(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final total = snapshot.data!.map((d) => d.total).reduce((a, b) => a + b);
              final acuerdos = snapshot.data!.map((d) => d.acuerdos).reduce((a, b) => a + b);
              final promedio = (acuerdos / total) * 100;
              return SizedBox(
                height: 350,
                child: RateBarChart(
                  data: snapshot.data!.map((d) => models.QuintileData(
                    label: d.tienePropiedades ? 'Con Propiedades' : 'Sin Propiedades',
                    tasaAcuerdo: d.tasaAcuerdo,
                    total: d.total,
                    acuerdos: d.acuerdos,
                  )).toList(),
                  title: 'Probabilidad de Acuerdo según Tenencia de Propiedades',
                  color: Colors.purple,
                  averageLine: promedio,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nota: Estos son análisis descriptivos sin controles. Las asociaciones observadas no implican causalidad.',
                    style: TextStyle(color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHypothesisCard(String hypothesis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hipótesis: $hypothesis',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 600) return 2;
    return 1;
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
