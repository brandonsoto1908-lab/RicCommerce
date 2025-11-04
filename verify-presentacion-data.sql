-- Verificar TODAS las presentaciones de Bleach/Cloro
SELECT 
  p.nombre as producto,
  p.marca,
  pres.nombre as presentacion,
  pres.cantidad,
  pres.unidad_medida,
  pres.costo_envase as costo_envase_usd,
  pres.precio_venta_colones,
  inv.costo_promedio_usd as costo_producto_por_unidad,
  -- Calcular el margen manualmente con tasa de cambio 540
  ROUND((pres.cantidad * inv.costo_promedio_usd * 540), 2) as costo_producto_crc,
  ROUND((pres.costo_envase * 540), 2) as costo_envase_crc,
  ROUND(((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540)), 2) as costo_total_crc,
  ROUND((pres.precio_venta_colones - ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))), 2) as margen_crc,
  ROUND(
    ((pres.precio_venta_colones - ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))) / 
    ((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540))) * 100, 
    2
  ) as margen_porcentaje_actual,
  -- Para 30% de margen, el precio debería ser:
  ROUND(((pres.cantidad * inv.costo_promedio_usd * 540) + (pres.costo_envase * 540)) * 1.30, 2) as precio_para_30_porciento
FROM presentaciones pres
JOIN productos p ON p.id = pres.producto_id
JOIN inventario inv ON inv.producto_id = p.id
JOIN auth.users u ON u.id = pres.usuario_id
WHERE u.email = 'system@stonebyric.com'
  AND (p.nombre ILIKE '%bleach%' OR p.nombre ILIKE '%cloro%')
ORDER BY pres.cantidad;
