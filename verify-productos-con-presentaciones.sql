-- Verificar todos los productos y sus presentaciones
SELECT 
  p.nombre as producto,
  p.marca,
  p.categoria,
  p.unidad_medida,
  COUNT(DISTINCT pres.id) as total_presentaciones,
  ARRAY_AGG(DISTINCT pres.nombre) as presentaciones,
  inv.costo_promedio_usd,
  u.email
FROM productos p
LEFT JOIN presentaciones pres ON pres.producto_id = p.id AND pres.activo = true
LEFT JOIN inventario inv ON inv.producto_id = p.id
JOIN auth.users u ON u.id = p.usuario_id
WHERE u.email = 'system@stonebyric.com'
  AND p.activo = true
GROUP BY p.nombre, p.marca, p.categoria, p.unidad_medida, inv.costo_promedio_usd, u.email
ORDER BY p.nombre;
