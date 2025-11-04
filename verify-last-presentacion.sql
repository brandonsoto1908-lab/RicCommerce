-- Verificar la última presentación creada para Bleach
SELECT 
  p.nombre as producto,
  pres.nombre as presentacion,
  pres.cantidad,
  pres.unidad,
  pres.costo_envase as costo_envase_guardado_usd,
  pres.precio_venta_colones as precio_guardado,
  inv.costo_promedio_usd as costo_por_litro,
  
  -- Calcular lo que DEBERÍA mostrar con los datos guardados
  ROUND((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540), 2) as costo_total_crc,
  ROUND(
    ((pres.precio_venta_colones - ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))) / 
    ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))) * 100, 
    2
  ) as margen_real,
  
  -- Calcular qué costo_envase se necesitaría para obtener 56.8% con precio ₡1575
  ROUND(
    ((1575 / 1.568) - (pres.cantidad * inv.costo_promedio_usd * 540)) / 540,
    2
  ) as costo_envase_para_56_8_porciento,
  
  -- Calcular qué costo_envase se necesitaría para obtener 30.15% con precio ₡1575
  ROUND(
    ((1575 / 1.3015) - (pres.cantidad * inv.costo_promedio_usd * 540)) / 540,
    2
  ) as costo_envase_para_30_15_porciento,
  
  pres.created_at
FROM presentaciones pres
JOIN productos p ON p.id = pres.producto_id
JOIN inventario inv ON inv.producto_id = p.id
JOIN auth.users u ON u.id = pres.usuario_id
WHERE u.email = 'system@stonebyric.com'
  AND p.nombre ILIKE '%bleach%'
  AND pres.nombre = '1 Litro'
ORDER BY pres.created_at DESC
LIMIT 1;
