-- =========================================
-- SCRIPT DE INSERCIÓN DE PRODUCTOS
-- Usuario: brandonsoto1908@gmail.com
-- Fecha: 3 de Noviembre, 2025
-- =========================================

-- IMPORTANTE: Ejecuta este script en Supabase SQL Editor
-- Dashboard > SQL Editor > New Query > Pega este código > Run

-- Paso 1: Obtener el user_id del usuario
-- Reemplaza 'brandonsoto1908@gmail.com' si es diferente
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Buscar el usuario por email
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'brandonsoto1908@gmail.com';

  -- Verificar si el usuario existe
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no encontrado: brandonsoto1908@gmail.com';
  END IF;

  RAISE NOTICE 'Usuario encontrado: %', v_user_id;

  -- =========================================
  -- INSERTAR PRODUCTOS
  -- =========================================

  -- 1. Liquid TIDE (1000 litros @ $0.57/L)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Liquid Tide Softener',
    'Tide',
    'Suavizante de telas líquido de alta calidad',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 2. GAIN FABRIC SOFTENER (1000 litros @ $0.575/L)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Fabric Softener',
    'Gain',
    'Suavizante de telas con fragancia duradera',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 3. DAWN DISH SOAP (1000 litros @ $0.53/L)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Dish Soap',
    'Dawn',
    'Jabón líquido para lavar platos con poder desengrasante',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 4. FABOLUSO (1000 litros @ $0.39/L)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Limpiador Multiusos',
    'Fabuloso',
    'Limpiador líquido multiusos con fragancia',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 5. Laundry Bleach (1000 litros @ $0.41/L)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Laundry Bleach',
    'Bleach',
    'Blanqueador para lavandería, elimina manchas difíciles',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 6. TIDE PODS (por cartón de 1600 piezas @ $34/cartón)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Laundry Pods 8g',
    'Tide Pods',
    'Cápsulas de detergente concentrado, 1600 piezas por cartón',
    'unidades',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 7. Laundry Beads (por kilogramo @ $4.35/KG)
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Laundry Beads',
    'Generic',
    'Perlas aromáticas para lavandería, precio por kilogramo',
    'kilogramos',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  RAISE NOTICE '✅ Productos insertados exitosamente';

  -- =========================================
  -- INSERTAR COMPRAS INICIALES
  -- =========================================

  -- Compra 1: Liquid TIDE
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    1000,
    0.57,
    570,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Liquid Tide Softener'
    AND p.marca = 'Tide'
  ON CONFLICT DO NOTHING;

  -- Compra 2: GAIN FABRIC SOFTENER
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    1000,
    0.575,
    575,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Fabric Softener'
    AND p.marca = 'Gain'
  ON CONFLICT DO NOTHING;

  -- Compra 3: DAWN DISH SOAP
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    1000,
    0.53,
    530,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Dish Soap'
    AND p.marca = 'Dawn'
  ON CONFLICT DO NOTHING;

  -- Compra 4: FABOLUSO
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    1000,
    0.39,
    390,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Limpiador Multiusos'
    AND p.marca = 'Fabuloso'
  ON CONFLICT DO NOTHING;

  -- Compra 5: Laundry Bleach
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    1000,
    0.41,
    410,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Laundry Bleach'
    AND p.marca = 'Bleach'
  ON CONFLICT DO NOTHING;

  -- Compra 6: TIDE PODS (1600 unidades por cartón @ $34)
  -- Precio unitario = $34 / 1600 = $0.02125 por pieza
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    1600,
    0.02125,
    34,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Laundry Pods 8g'
    AND p.marca = 'Tide Pods'
  ON CONFLICT DO NOTHING;

  -- Compra 7: Laundry Beads (precio variable por KG)
  -- Registrando 100 KG como ejemplo @ $4.35/KG = $435 total
  INSERT INTO compras (
    usuario_id, 
    producto_id, 
    proveedor, 
    cantidad, 
    precio_unitario_usd, 
    total_compra_usd,
    costo_envase,
    fecha
  )
  SELECT 
    v_user_id,
    p.id,
    'Proveedor Inicial',
    100,
    4.35,
    435,
    0,
    CURRENT_DATE
  FROM productos p
  WHERE p.usuario_id = v_user_id 
    AND p.nombre = 'Laundry Beads'
    AND p.marca = 'Generic'
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ Compras iniciales registradas exitosamente';
  RAISE NOTICE '⚠️ IMPORTANTE: El inventario se actualizará automáticamente mediante los triggers de la base de datos';

END $$;

-- =========================================
-- VERIFICACIÓN
-- =========================================

-- Ver productos insertados
SELECT 
  p.nombre,
  p.marca,
  p.unidad_medida,
  COUNT(c.id) as num_compras,
  COALESCE(i.cantidad_disponible, 0) as stock_actual,
  COALESCE(i.costo_promedio_usd, 0) as costo_promedio
FROM productos p
LEFT JOIN compras c ON c.producto_id = p.id
LEFT JOIN inventario i ON i.producto_id = p.id
WHERE p.usuario_id = (
  SELECT id FROM auth.users WHERE email = 'brandonsoto1908@gmail.com'
)
GROUP BY p.id, p.nombre, p.marca, p.unidad_medida, i.cantidad_disponible, i.costo_promedio_usd
ORDER BY p.nombre;

-- =========================================
-- RESUMEN DE DATOS INSERTADOS
-- =========================================
-- 
-- ✅ 7 Productos creados:
--   1. Liquid Tide Softener (1000L @ $0.57/L = $570)
--   2. Gain Fabric Softener (1000L @ $0.575/L = $575)
--   3. Dawn Dish Soap (1000L @ $0.53/L = $530)
--   4. Fabuloso Limpiador (1000L @ $0.39/L = $390)
--   5. Laundry Bleach (1000L @ $0.41/L = $410)
--   6. Tide Pods 8g (1600 unidades @ $0.02125/unidad = $34)
--   7. Laundry Beads (100 KG @ $4.35/KG = $435)
--
-- ✅ 7 Compras iniciales registradas
-- ✅ Inventario actualizado automáticamente por triggers
-- 
-- Total invertido: $2,944 USD
-- =========================================
