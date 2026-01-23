"""
Script para exportar los datos del CSV a formato JSON para Flutter.
Ejecutar este script antes de compilar el dashboard Flutter.

Autor: Juan David Anzola Quiroga
"""

import pandas as pd
import json
import os

def exportar_datos_json():
    # Cargar el CSV
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(script_dir, 'prueba_analist_de_datos_crecere.csv')
    
    df = pd.read_csv(csv_path)
    
    # Renombrar columnas (como en el notebook)
    df = df.rename(columns={
        'antiguedad_deuda': 'dias_mora',
        'deuda_total': 'monto_deuda',
        'mujer': 'es_mujer',
        'region_bogota': 'vive_bogota',
        'propuesta_cuotas': 'cuotas_ofrecidas',
        'propuesta_descuento': 'descuento_ofrecido',
        'estrategia_agresiva': 'negociacion_agresiva',
        'origen_deudor': 'pais_origen',
        'producto_origen_deuda': 'tipo_credito',
        'beneficiario_subsidios': 'recibe_subsidios',
        'con_acuerdo': 'acuerdo_logrado'
    })
    
    # Corregir errores
    df['pais_origen'] = df['pais_origen'].replace('Venzuela', 'Venezuela')
    df['edad'] = df['edad'].round().astype(int)
    
    # Convertir a lista de diccionarios
    data = df.to_dict(orient='records')
    
    # Crear directorio de destino
    output_dir = os.path.join(script_dir, 'dashboard_flutter', 'assets', 'data')
    os.makedirs(output_dir, exist_ok=True)
    
    # Guardar JSON
    output_path = os.path.join(output_dir, 'deudores.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Datos exportados exitosamente!")
    print(f"   Archivo: {output_path}")
    print(f"   Registros: {len(data)}")
    print(f"   Columnas: {list(df.columns)}")

if __name__ == '__main__':
    exportar_datos_json()
