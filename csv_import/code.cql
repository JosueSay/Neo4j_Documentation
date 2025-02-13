// ==================================================
// QUERYS DE PRUEBA PARA AMBOS MÉTODOS DE IMPORTACIÓN
// ==================================================

// Ver todos los nodos y relaciones
MATCH (n)-[r]->(m) 
RETURN n, r, m;

// Eliminar toda la data de la instancia
MATCH (n)
DETACH DELETE n;

// Eliminación de constraints
DROP CONSTRAINT `fecha_Venta_uniq`;
DROP CONSTRAINT `nombre_Marca_uniq`;
DROP CONSTRAINT `nombre_Tienda_uniq`;
DROP CONSTRAINT `tipo_Producto_uniq`;

// Producto más vendido
MATCH (p:Producto)<-[r:INCLUYE]-()
RETURN p.tipo AS Producto, count(r) AS Cantidad_Ventas
ORDER BY Cantidad_Ventas DESC
LIMIT 1;

// Venta más grande
MATCH (v:Venta)-[:INCLUYE]->(p:Producto)
RETURN v.fecha AS Fecha, v.hora AS Hora, sum(p.precio) AS Monto_Total
ORDER BY Monto_Total DESC
LIMIT 1;

// Venta con el monto más pequeño
MATCH (v:Venta)-[:INCLUYE]->(p:Producto)
RETURN v.fecha AS Fecha, v.hora AS Hora, sum(p.precio) AS Monto_Total
ORDER BY Monto_Total ASC
LIMIT 1;

// Tienda con más ventas realizadas
MATCH (t:Tienda)-[:REALIZA]->(v:Venta)
RETURN t.nombre AS Tienda, count(v) AS Ventas_Realizadas
ORDER BY Ventas_Realizadas DESC
LIMIT 1;

// Marca más vendida (cantidad de productos vendidos de esa marca)
MATCH (m:Marca)-[:FABRICA]->(p:Producto)<-[:INCLUYE]-()
RETURN m.nombre AS Marca, count(p) AS Productos_Vendidos
ORDER BY Productos_Vendidos DESC
LIMIT 1;

// Ingresos totales por tienda
MATCH (t:Tienda)-[:REALIZA]->(v:Venta)-[:INCLUYE]->(p:Producto)
RETURN t.nombre AS Tienda, sum(p.precio) AS Ingresos_Totales
ORDER BY Ingresos_Totales DESC;

// Productos con mayores ingresos generados
MATCH (p:Producto)<-[:INCLUYE]-()
RETURN p.tipo AS Producto, sum(p.precio) AS Ingresos_Generados
ORDER BY Ingresos_Generados DESC
LIMIT 5;

// Venta promedio por tienda
MATCH (t:Tienda)-[:REALIZA]->(v:Venta)-[:INCLUYE]->(p:Producto)
RETURN t.nombre AS Tienda, avg(p.precio) AS Venta_Promedio
ORDER BY Venta_Promedio DESC;

// ============================================
// QUERYS PARA IMPORTACIÓN DE DATOS POR CYPHER 
// ============================================

// 0. Verificar archivo csv y creación de nuevos constraints
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/JosueSay/7bbb5d5504463ce23056d468dd8077e4/raw/abdb23826c36770e3a9d5a4f4544cd53da32b990/ventas_tienda_departamento_formated.csv' AS row
RETURN count(*) AS total_registros, size(keys(row)) AS total_columnas;

CREATE CONSTRAINT nombre_Tienda_uniq FOR (t:Tienda) REQUIRE t.nombre IS UNIQUE;
CREATE CONSTRAINT nombre_Marca_uniq FOR (m:Marca) REQUIRE m.nombre IS UNIQUE;
CREATE CONSTRAINT tipo_Producto_uniq FOR (p:Producto) REQUIRE p.tipo IS UNIQUE;
CREATE CONSTRAINT fecha_Venta_uniq FOR (v:Venta) REQUIRE v.fecha IS UNIQUE;

// 1. Crear nodos de Tienda
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/JosueSay/7bbb5d5504463ce23056d468dd8077e4/raw/abdb23826c36770e3a9d5a4f4544cd53da32b990/ventas_tienda_departamento_formated.csv' AS row FIELDTERMINATOR ','
WITH DISTINCT row.Tienda AS nombre
WHERE nombre IS NOT NULL
MERGE (t:Tienda {nombre: nombre});

// 2. Crear nodos de Marca
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/JosueSay/7bbb5d5504463ce23056d468dd8077e4/raw/abdb23826c36770e3a9d5a4f4544cd53da32b990/ventas_tienda_departamento_formated.csv' AS row FIELDTERMINATOR ','
WITH DISTINCT row.Marca AS nombre
WHERE nombre IS NOT NULL
MERGE (m:Marca {nombre: nombre});

// 3. Crear nodos de Producto
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/JosueSay/7bbb5d5504463ce23056d468dd8077e4/raw/abdb23826c36770e3a9d5a4f4544cd53da32b990/ventas_tienda_departamento_formated.csv' AS row FIELDTERMINATOR ','
WITH DISTINCT row.Tipo AS tipo, row
WHERE tipo IS NOT NULL
MERGE (p:Producto {tipo: tipo})
SET p.genero = row.Género,
    p.talla = coalesce(trim(row.Talla), 'Desconocido'),
    p.color = coalesce(row.Color, 'Desconocido'),
    p.categoria = coalesce(row.Categoria, 'Desconocido'),
    p.precio = coalesce(toFloat(trim(row.`precio de venta S/`)), 0.0);

// 4. Crear nodos de Venta
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/JosueSay/7bbb5d5504463ce23056d468dd8077e4/raw/abdb23826c36770e3a9d5a4f4544cd53da32b990/ventas_tienda_departamento_formated.csv' AS row FIELDTERMINATOR ','
MERGE (v:Venta {fecha: row.Fecha})
SET v.hora = coalesce(v.hora, row.Hora);

// 5. Crear relaciones entre nodos
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/JosueSay/7bbb5d5504463ce23056d468dd8077e4/raw/abdb23826c36770e3a9d5a4f4544cd53da32b990/ventas_tienda_departamento_formated.csv' AS row FIELDTERMINATOR ','
MATCH (t:Tienda {nombre: row.Tienda})
MATCH (m:Marca {nombre: row.Marca})
MATCH (p:Producto {tipo: row.Tipo})
MATCH (v:Venta {fecha: row.Fecha})
MERGE (t)-[:VENDE]->(p)
MERGE (m)-[:FABRICA]->(p)
MERGE (v)-[:INCLUYE]->(p)
MERGE (t)-[:REALIZA]->(v);
