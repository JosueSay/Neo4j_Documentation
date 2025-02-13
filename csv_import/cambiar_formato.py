import os
import pandas as pd

"""
Convierte un archivo CSV a formato UTF-8 u otro formato especificado, con opción de guardar en una ruta específica.

Parámetros:
- RUTA_ARCHIVO (str): Ruta del archivo CSV a convertir.
- FORMATO_ENTRADA (str): Codificación actual del archivo CSV. Por defecto es 'latin1'.
- FORMATO_SALIDA (str): Codificación deseada para el archivo CSV de salida. Por defecto es 'utf-8'.
- RUTA_SALIDA (str): Ruta donde se guardará el archivo convertido. Si no se especifica, se guarda en la misma ubicación con un nuevo nombre.

Retorno:
- None: No retorna ningún valor, solo guarda el archivo convertido en la ubicación especificada.
"""
def cambiarFormatoUTF8(RUTA_ARCHIVO: str, FORMATO_ENTRADA: str = 'latin1', FORMATO_SALIDA: str = 'utf-8', RUTA_SALIDA: str = None) -> None:
  try:
    if not os.path.isfile(RUTA_ARCHIVO):
      raise FileNotFoundError(f"El archivo {RUTA_ARCHIVO} no existe.")
      
    df = pd.read_csv(RUTA_ARCHIVO, encoding=FORMATO_ENTRADA)
      
    if RUTA_SALIDA:
      if not os.path.exists(os.path.dirname(RUTA_SALIDA)):
        raise FileNotFoundError(f"La ruta de salida {os.path.dirname(RUTA_SALIDA)} no existe.")
      NOMBRE_SALIDA = RUTA_SALIDA
    else:
      NOMBRE_SALIDA = os.path.splitext(RUTA_ARCHIVO)[0] + '_utf8.csv'
      
    df.to_csv(NOMBRE_SALIDA, index=False, encoding=FORMATO_SALIDA)
    print(f"Archivo convertido y guardado como {NOMBRE_SALIDA}")
  
  except Exception as e:
    print(f"Error: {e}")


if __name__ == "__main__":
  ruta_csv = "./data/ventas_tienda_departamento.csv"
  ruta_salida = "./data/ventas_tienda_departamento_utf8.csv"
  formato_entrada = "latin1"
  formato_salida = "utf-8"
  cambiarFormatoUTF8(RUTA_ARCHIVO=ruta_csv, RUTA_SALIDA=ruta_salida, FORMATO_ENTRADA=formato_entrada, FORMATO_SALIDA=formato_salida)
