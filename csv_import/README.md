# Importación de CSV en AuraDB con Cypher 🚀

- [📌 Conceptos Clave](#-conceptos-clave)  
  - [CSV (Comma-Separated Values)](#csv-comma-separated-values)  
  - [TSV (Tab-Separated Values)](#tsv-tab-separated-values)  
  - [UTF-8 (Formato de Datos)](#utf-8-formato-de-datos)  
- [📂 Archivos Importantes](#-archivos-importantes)  
- [🛠️ Pasos para la Importación](#️-pasos-para-la-importación)  
  - [1. Comprender la Estructura de los Datos](#1-comprender-la-estructura-de-los-datos)  
  - [2. Diseñar el Modelo de Datos](#2-diseñar-el-modelo-de-datos)  
  - [3. Preparar los Datos para la Importación](#3-preparar-los-datos-para-la-importación)  
  - [4. Importar los Datos con Data Importer](#4-importar-los-datos-con-data-importer)  
  - [5. Importar los Datos Usando Cypher](#5-importar-los-datos-usando-cypher)  
- [🔗 Enlaces Útiles](#-enlaces-útiles)

## 📌 Conceptos Clave

### CSV (Comma-Separated Values)

Es un formato de archivo de texto en el que los datos están separados por comas. Se utiliza comúnmente para almacenar datos tabulares de manera sencilla y compatible con muchas aplicaciones.

**Ejemplo:**

```csv
Nombre,Edad,País
Juan,25,México
Ana,30,España
```

### TSV (Tab-Separated Values)

Similar al CSV, pero los valores están separados por tabulaciones en lugar de comas. Es útil cuando los datos contienen comas, evitando confusiones en la separación.

**Ejemplo:**

```tsv
Nombre	Edad	País
Juan	25	México
Ana	30	España
```

### UTF-8 (Formato de Datos)

Es una codificación de caracteres ampliamente utilizada que puede representar casi todos los caracteres del mundo. Es compatible con ASCII y es el estándar en la web y muchos sistemas.

**Ejemplo de caracteres en UTF-8:**

- `A` (Letra en ASCII y UTF-8)
- `ñ` (Carácter especial en español)
- `✓` (Símbolo de verificación)

## 📂 Archivos Importantes

```bash
├── images/                    # Imágenes de apoyo
├── data/                      # Carpeta donde están los dataset de tipo `.csv`
├── code.cql                   # Archivos con los querys para Neo4j para la importación
├── cambiar_delimitador.py     # Scripts en python para cambiar el delimitador de un archivo `.csv`
├── cambiar_formato.py         # Scripts en python para cambiar el formato de un archivo `.csv`
└── requirements.txt           # Dependencias necesarias para los scripts
```

## 🛠️ Pasos para la Importación

Para esta documentación se utilizará el dataset `ventas_tienda_departamento_formated.csv` de la carpeta `data`.

### 1. Comprender la Estructura de los Datos

Analizar los datos de origen para identificar sus características, relaciones y posibles inconsistencias. En el csv de ejemplo, se puede observar:

1. **Tienda**: *(String)* – Nombre de la ubicación donde se realiza la venta (por ejemplo, "Lima").
2. **Marca**: *(String)* – Marca del producto (por ejemplo, "Asics", "Nike").
3. **Tipo**: *(String)* – Modelo o tipo específico del producto (por ejemplo, "WB1820", "Cummulus 17").
4. **Género**: *(String)* – Público objetivo del producto (por ejemplo, "Femenino", "Masculino", "Usinex" que podría interpretarse como "Unisex").
5. **Talla**: *(String)* – Talla o rango de tallas (por ejemplo, "42", "42-44", "38-40").
6. **Color**: *(String)* – Color del producto (por ejemplo, "Azul", "Negro", "Multicolor").
7. **Categoría**: *(String)* – Categoría del producto (por ejemplo, "Pantalon", "Zapatillas", "Ropa interior").
8. **Precio de venta S/**: *(Float)* – Precio de venta en soles (por ejemplo, 89.0, 159.0).
9. **Fecha**: *(Date)* – Fecha de la transacción en formato DD/MM/AAAA (por ejemplo, 15/07/2015).
10. **Hora**: *(Time)* – Hora de la transacción en formato HH:MM:SS (por ejemplo, 07:32:00).

**Observaciones:**

- **Tipos de datos**: Se observan datos textuales, numéricos y de fecha/hora.
- **Inconsistencias y Mejoras**:
  - La columna "Género" tiene "Usinex", que parece un error tipográfico para "Unisex".
  - La "Talla" puede ser un solo valor o un rango, lo que podría requerir limpieza o estandarización.
  - La "Marca" y "Tipo" están bien definidas pero podrían contener inconsistencias si el dataset completo es grande (diferencias de mayúsculas, errores tipográficos, etc.).
  - El "Color" tiene valores como "Multicolor", lo que podría ser un desafío para categorizar.
- **Entidades identificables**: Tienda, Marca, Producto, Categoría, Venta (transacción).

### 2. Diseñar el Modelo de Datos

Definir cómo se representarán los datos en el grafo, incluyendo nodos, relaciones y propiedades. En el csv de ejemplo, se puede obtener:

#### **Nodos principales**

1. **Tienda**:
   - *Propiedades*: `nombre`

2. **Marca**:
   - *Propiedades*: `nombre`

3. **Producto**:
   - *Propiedades*: `tipo`, `genero`, `talla`, `color`, `categoria`, `precio`

4. **Venta**:
   - *Propiedades*: `fecha`, `hora`

#### **Relaciones**

- `(Tienda)-[:VENDE]->(Producto)`
- `(Marca)-[:FABRICA]->(Producto)`
- `(Venta)-[:INCLUYE]->(Producto)`
- `(Tienda)-[:REALIZA]->(Venta)`

Para ver el modelo se puede utilizar el `Arrows App` el enlace está en la sección de [Enlaces Útiles](#-enlaces-útiles)

![alt text](image.png)

### 3. Preparar los Datos para la Importación

Para asegurar una importación correcta en Neo4j, es necesario estandarizar el **formato de codificación** y el **delimitador de columnas** en los archivos CSV.  

- Se recomienda utilizar **UTF-8** para evitar problemas de codificación.  
- El delimitador debe ser **coma ( , )** para garantizar compatibilidad con Neo4j.  

#### **Sin Código**

En Windows, el delimitador predeterminado para CSV puede variar según la configuración regional del sistema. Para ajustarlo:  

1. **Abrir el Panel de Control** y buscar "Configuración regional" o "Formato de fecha y hora".  

   ![Panel de Control](./images/panel_control.png "Panel de Control")

   ![Cambiar Formato de Fecha y Hora](./images/panel_formato_fecha_hora.png "Cambiar Formato de Fecha y Hora")

2. Ir a **Configuración adicional** y modificar el campo **"Separador de listas"**, cambiándolo por una coma (`,`) si es necesario.

   ![Configuración Adicional](./images/panel_configuracion_adicion.png "Configuración Adicional")

   ![Configuración de Delimitador](./images/panel_configuracion_delimitador.png "Configuración de Delimitador")

3. Guardar los cambios y aplicar.  

4. **Abrir Excel** y dirigirse a `Datos > Obtener y Transformar Datos > De texto/CSV`.  

   ![Preparación de Datos Excel](./images/preparacion_excel1.png "Preparación de Datos Excel")

5. Seleccionar el archivo CSV a importar. Si el delimitador no es correcto, cambiarlo en la vista previa antes de cargar los datos.  

   ![Preparción de Datos Excel 2](./images/preparacion_excel2.png "Preparción de Datos Excel 2")

6. Una vez cargado, ir a `Archivo > Guardar como`, seleccionar **"CSV delimitado por comas"** o **"CSV UTF-8 delimitado por comas"**, según sea necesario.
   ![Preparción de Datos Excel 3](./images/preparacion_excel3.png "Preparción de Datos Excel 3")

7. Abrir el archivo CSV en **Bloc de notas**.

   ![Preparación de Datos Formato 1](./images/preparacion_formato1.png "Preparación de Datos Formato 1")

   ![Preparación de Datos Formato 2](./images/preparacion_formato2.png "Preparación de Datos Formato 2")

8. Ir a `Archivo > Guardar como`, y en la opción **"Codificación"**, seleccionar **UTF-8** antes de guardar.

   ![Preparación de Datos Formato 3](./images/preparacion_formato3.png "Preparación de Datos Formato 3")

#### **Con código**

Para realizar estos cambios de forma más rápida y automatizada, puedes usar los scripts auxiliares en Python de la carpeta `csv_import`.

- Tener **Python 3.12** instalado.
- Instalar dependencias con:

  ```bash
  pip install -r requirements.txt
  ```

- Ubicar los scripts:
  - `cambiar_delimitador.py`: Cambia el delimitador de los archivos CSV.  
  - `cambiar_formato.py`: Convierte el formato de codificación a UTF-8 o cualquier otro formato deseado.  

- Para usar los scripts puedes abrir directamente el codigo y cambiar el contenido de las variables al final del scripts por los propios; para ver el significado de los parámetros que necesita puedes ver la documentación de cada script. Luego ejecutas el programa y obtendras los archivos convertidos.

> **Nota:** En la carpeta `data`, encontrarás archivos de ejemplo ya convertidos con estos scripts.

### 4. Importar los Datos con Data Importer

### 5. Importar los Datos Usando Cypher

## 🔗 Enlaces Útiles

- [Neo4j](https://neo4j.com/)
- [Neo4j Console](https://console.neo4j.io/)
- [Documentación para la Importación de Datos en Neo4j por AuraDB](https://neo4j.com/docs/data-importer/current/)
- [Documentación para la Importación de Datos en Neo4j Por Cypher](https://neo4j.com/docs/cypher-manual/current/clauses/load-csv/)
- [Arrows App Modelar Datos](https://arrows.app/#/local/id=50Jx0RywfReyZzq4_SXx)
- [Data Origen CSV](https://github.com/VictorGuevaraP/Mineria-de-datos/blob/master/Ventas%20tienda%20por%20departamento.csv)
- [Video Referencia 1](https://www.youtube.com/watch?v=Jro1MMzUAgs)
- [Video Referencia 2](https://www.youtube.com/watch?v=v-JdvAfRWtQ)
