# Detalles de LOAD CSV

## Uso de `LOAD CSV` en Neo4j

- **Función**: Importa datos desde archivos CSV a Neo4j.
- **Fuentes**:
  - Archivos locales: `file:///archivo.csv`
  - URLs remotas: `http://`, `https://`, `ftp://`
  - Servicios en la nube: `azb://` (Azure), `gs://` (Google Cloud), `s3://` (AWS S3)
- **Cláusulas clave**:
  - `LOAD CSV FROM 'url' AS row`: Carga el CSV fila por fila.
  - `WITH HEADERS`: Usa la primera fila como nombres de columnas.
  - `MERGE`: Crea o fusiona nodos/relaciones a partir de los datos.
  - `FIELDTERMINATOR ';'`: Define un delimitador personalizado.
- **Seguridad**:
  - Prefiere URLs con `HTTPS`.
  - Se recomienda configurar permisos en archivos locales.
- **Manejo de datos**:
  - Conversión de tipos (`toInteger()`, `date()`, `split()`).
  - Manejo de valores nulos (`coalesce()`, `nullIf()`).
  - Uso de listas (`split()`).
- **Optimización**:
  - Carga en transacciones (`CALL { ... } IN TRANSACTIONS`).
  - Creación de restricciones de unicidad antes de importar.
- **Compatibilidad**:
  - Soporta importación dinámica de etiquetas y CSV comprimidos (`.zip`, `.gzip`).

## Usos con Detalles

### **1. Importar CSV desde distintas conexiones (local, remota o nube)**

- **Local:** `file:///archivo.csv`
- **Remota:** `http://`, `https://`, `ftp://`
- **Nube:** `azb://` (Azure), `gs://` (Google Cloud), `s3://` (AWS S3)

### **2. Importar CSV con o sin encabezados**

- **Con encabezados:** `LOAD CSV WITH HEADERS`
- **Sin encabezados:** `LOAD CSV`

#### **3. Usar delimitadores personalizados**

- Modificar el separador por defecto (`,`) usando `FIELDTERMINATOR`.

### **4. Manejar grandes volúmenes de datos**

- Cargar datos en **transacciones por lotes** con `CALL { ... } IN TRANSACTIONS`.
  - Recomendado a partir de 100,000 filas.

### **5. Importar CSV comprimidos**

- **ZIP o GZIP** (solo archivos locales).

### **6. Procesar datos durante la importación**

- **Conversión de tipos** (`toInteger()`, `date()`, `split()`).
- **Manejo de valores nulos** (`coalesce()`, `nullIf()`).

### **7. Crear relaciones desde uno o múltiples CSV**

- Separar la importación de **nodos** y **relaciones** en distintos pasos.

### **8. Importar datos dinámicos**

- Asignar **etiquetas y propiedades dinámicas** desde valores de las columnas.

### **9. Inspeccionar y validar CSV antes de importar**

- Contar filas, ver primeras líneas, validar estructura, etc.

### **10. Crear restricciones de unicidad antes de importar**

- Para evitar duplicados al cargar datos.
