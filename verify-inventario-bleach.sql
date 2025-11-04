-- Verificar si existe inventario para Bleach
SELECT 
  p.nombre as producto,
  p.marca,
  p.id as producto_id,
  inv.id as inventario_id,
  inv.cantidad_disponible,
  inv.costo_promedio_usd,
  inv.usuario_id,
  u.email
FROM productos p
LEFT JOIN inventario inv ON inv.producto_id = p.id
LEFT JOIN auth.users u ON u.id = inv.usuario_id
WHERE p.nombre ILIKE '%bleach%'
ORDER BY p.nombre;
