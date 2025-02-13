import os
import pandas as pd

"""
Cambia el delimitador de un archivo CSV, con opción de guardar en una ruta específica.

Parámetros:
- RUTA_ARCHIVO (str): Ruta del archivo CSV a modificar.
- DELIMITADOR_ORIGEN (str): Delimitador actual del archivo CSV. Por defecto es ','.
- DELIMITADOR_OBJETIVO (str): Nuevo delimitador para el archivo CSV. Por defecto es ';'.
- RUTA_SALIDA (str): Ruta donde se guardará el archivo modificado. Si no se especifica, se guarda en la misma ubicación con un nuevo nombre.

Retorno:
- None: No retorna ningún valor, solo guarda el archivo modificado en la ubicación especificada.
"""

def cambiarDelimitador(RUTA_ARCHIVO: str, DELIMITADOR_ORIGEN: str = ',', DELIMITADOR_OBJETIVO: str = ';', RUTA_SALIDA: str = None, FORMATO: str = 'utf-8') -> None:
  try:
    if not os.path.isfile(RUTA_ARCHIVO):
      raise FileNotFoundError(f"El archivo {RUTA_ARCHIVO} no existe.")
    
    df = pd.read_csv(RUTA_ARCHIVO, delimiter=DELIMITADOR_ORIGEN, encoding=FORMATO)
    
    if RUTA_SALIDA:
      if not os.path.exists(os.path.dirname(RUTA_SALIDA)):
        raise FileNotFoundError(f"La ruta de salida {os.path.dirname(RUTA_SALIDA)} no existe.")
      NOMBRE_SALIDA = RUTA_SALIDA
    else:
      NOMBRE_SALIDA = os.path.splitext(RUTA_ARCHIVO)[0] + '_delim.csv'
    
    df.to_csv(NOMBRE_SALIDA, index=False, sep=DELIMITADOR_OBJETIVO)
    print(f"Archivo guardado con nuevo delimitador como {NOMBRE_SALIDA}")
  
  except Exception as e:
    print(f"Error: {e}")


if __name__ == "__main__":
  ruta_csv = "./data/ventas_tienda_departamento.csv"
  ruta_salida = "./data/ventas_tienda_departamento_formated.csv"
  delimitador_origen = ";"
  delimitador_salida  = ","
  formato = "latin1"
  cambiarDelimitador(RUTA_ARCHIVO=ruta_csv, RUTA_SALIDA=ruta_salida, DELIMITADOR_ORIGEN=delimitador_origen, DELIMITADOR_OBJETIVO=delimitador_salida, FORMATO=formato)
