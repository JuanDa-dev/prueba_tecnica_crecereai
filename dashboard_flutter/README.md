# 📊 CrecereAI Dashboard - Análisis de Negociación de Deudas

Dashboard interactivo desarrollado en **Flutter Web** para visualizar el análisis de negociación de deudas en mora (>180 días).

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 🎯 Descripción

Este proyecto es parte de una prueba técnica para **CrecereAI**. El dashboard permite explorar visualmente los patrones de negociación exitosa con deudores en mora, utilizando los mismos análisis realizados en el notebook de Jupyter pero con una interfaz web interactiva.

## ✨ Características

- **📈 6 tipos de visualizaciones:**
  - Histogramas de distribución
  - Gráficos de barras agrupadas
  - Gráficos de líneas temporales
  - Diagramas de dispersión (scatter plots)
  - Mapas de calor de correlaciones
  - Pictogramas (waffle charts)

- **📊 KPIs interactivos:**
  - Total de deudores
  - Tasa de éxito en negociación
  - Promedios de edad, deuda e ingreso

- **🎨 Diseño moderno:**
  - Material Design 3
  - Modo claro/oscuro automático
  - Responsive para diferentes tamaños de pantalla

## 🚀 Instalación y Ejecución

### Prerrequisitos

1. **Flutter SDK** (versión 3.0 o superior)
   ```bash
   # Verificar instalación
   flutter --version
   ```

2. **Python 3.x** (para exportar los datos)

### Paso 1: Exportar los datos

Desde la carpeta `Prueba_Tecnica_Crecereai`, ejecuta:

```bash
python exportar_datos_flutter.py
```

Esto creará el archivo `dashboard_flutter/assets/data/deudores.json`.

### Paso 2: Instalar dependencias

```bash
cd dashboard_flutter
flutter pub get
```

### Paso 3: Ejecutar la aplicación

**Para desarrollo (web):**
```bash
flutter run -d chrome
```

**Para construir versión de producción:**
```bash
flutter build web
```

Los archivos de producción estarán en `build/web/`.

## 📁 Estructura del Proyecto

```
dashboard_flutter/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/
│   │   └── deudor_model.dart     # Modelos de datos
│   ├── services/
│   │   └── data_service.dart     # Servicio de datos
│   ├── screens/
│   │   └── dashboard_screen.dart # Pantalla principal
│   └── widgets/
│       ├── histogram_chart.dart  # Widget de histograma
│       ├── grouped_bar_chart.dart # Barras agrupadas
│       ├── line_chart_widget.dart # Gráfico de líneas
│       ├── scatter_chart_widget.dart # Diagrama dispersión
│       ├── heatmap_chart.dart    # Mapa de calor
│       ├── waffle_chart.dart     # Pictograma
│       └── stat_card.dart        # Tarjeta de KPI
├── assets/
│   └── data/
│       └── deudores.json         # Datos exportados
├── pubspec.yaml                  # Dependencias
└── README.md
```

## 📊 Visualizaciones Incluidas

| Tipo | Descripción |
|------|-------------|
| **Histogramas** | Distribución de edad, deuda, ingreso y días en mora |
| **Barras Agrupadas** | Acuerdos por tipo de crédito, estado civil, país y estrategia |
| **Líneas Temporales** | Evolución mensual de negociaciones y tasa de éxito |
| **Scatter Plot** | Relación ingreso vs monto de deuda |
| **Heatmap** | Correlaciones entre variables numéricas |
| **Waffle Chart** | Proporción visual de acuerdos vs no acuerdos |

## 🛠️ Tecnologías Utilizadas

- **Flutter 3.x** - Framework de UI
- **Dart** - Lenguaje de programación
- **fl_chart** - Librería de gráficos
- **Google Fonts** - Tipografía Poppins
- **Material Design 3** - Sistema de diseño

## 📝 Notas

- Los datos se cargan desde un archivo JSON estático
- El dashboard está optimizado para navegadores modernos
- Soporta modo oscuro del sistema operativo

## 👨‍💻 Autor

**Juan David Anzola Quiroga**

---

*Proyecto desarrollado como parte de la prueba técnica para CrecereAI*
