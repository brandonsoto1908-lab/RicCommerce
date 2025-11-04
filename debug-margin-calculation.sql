-- DEBUG: Verificar por qué el margen se muestra incorrectamente
-- Este script muestra TODOS los valores que se usan en el cálculo del margen

SELECT 
  p.nombre as producto,
  p.marca,
  p.unidad_medida as unidad_base_producto,
  pres.nombre as presentacion,
  pres.cantidad as cantidad_presentacion,
  pres.unidad as unidad_presentacion,
  pres.costo_envase as costo_envase_usd,
  pres.precio_venta_colones,
  inv.costo_promedio_usd as costo_unitario_producto_usd,
  
  -- PASO 1: Verificar si las unidades coinciden
  CASE 
    WHEN pres.unidad = p.unidad_medida THEN 'SI - Sin conversión necesaria'
    ELSE 'NO - Se necesita conversión'
  END as unidades_coinciden,
  
  -- PASO 2: Calcular costo del producto (asumiendo misma unidad)
  ROUND(pres.cantidad * inv.costo_promedio_usd, 4) as costo_producto_usd,
  ROUND(pres.cantidad * inv.costo_promedio_usd * 540, 2) as costo_producto_crc,
  
  -- PASO 3: Costo del envase en CRC
  ROUND(pres.costo_envase * 540, 2) as costo_envase_crc,
  
  -- PASO 4: Costo total
  ROUND((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540), 2) as costo_total_crc,
  
  -- PASO 5: Margen en CRC
  ROUND(pres.precio_venta_colones - ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540)), 2) as margen_crc,
  
  -- PASO 6: Margen en porcentaje
  ROUND(
    ((pres.precio_venta_colones - ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))) / 
    ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))) * 100, 
    2
  ) as margen_porcentaje_calculado,
  
  -- PASO 7: Verificar si el precio es correcto para 30%
  ROUND(((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540)) * 1.30, 2) as precio_para_30_porciento,
  
  -- PASO 8: Diferencia entre precio actual y precio para 30%
  ROUND(pres.precio_venta_colones - (((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540)) * 1.30), 2) as diferencia_precio

FROM presentaciones pres
JOIN productos p ON p.id = pres.producto_id
JOIN inventario inv ON inv.producto_id = p.id
JOIN auth.users u ON u.id = pres.usuario_id
WHERE u.email = 'system@stonebyric.com'
  AND (p.nombre ILIKE '%bleach%' OR p.nombre ILIKE '%cloro%')
ORDER BY pres.cantidad;
