-- =========================================
-- MIGRACIÓN: Agregar categoría a productos
-- =========================================
-- Permite clasificar productos para comparar
-- con la competencia
-- =========================================

BEGIN;

-- Agregar columna categoria a la tabla productos
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS categoria VARCHAR(100);

-- Crear índice para optimizar búsquedas por categoría
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria);

-- Actualizar categorías de los productos existentes de system@stonebyric.com
UPDATE productos p
SET categoria = CASE
  WHEN p.nombre ILIKE '%tide%' THEN 'detergente'
  WHEN p.nombre ILIKE '%gain%' THEN 'detergente'
  WHEN p.nombre ILIKE '%dawn%' THEN 'jabon'
  WHEN p.nombre ILIKE '%fabuloso%' THEN 'desinfectante'
  WHEN p.nombre ILIKE '%bleach%' OR p.nombre ILIKE '%cloro%' THEN 'cloro'
  WHEN p.nombre ILIKE '%beads%' OR p.nombre ILIKE '%perlas%' THEN 'perlas'
  WHEN p.nombre ILIKE '%pods%' THEN 'detergente'
  ELSE 'otros'
END
WHERE p.usuario_id = (SELECT id FROM auth.users WHERE email = 'system@stonebyric.com')
  AND p.categoria IS NULL;

COMMIT;

-- Verificar las categorías asignadas
SELECT 
  p.nombre,
  p.marca,
  p.categoria,
  p.unidad_medida,
  u.email
FROM productos p
JOIN auth.users u ON u.id = p.usuario_id
WHERE u.email = 'system@stonebyric.com'
ORDER BY p.categoria, p.nombre;
