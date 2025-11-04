-- =========================================
-- SCRIPT DE INSERCIÓN DE PRODUCTOS
-- Usuario: brandonsoto1908@gmail.com
-- Fecha: 3 de Noviembre, 2025
-- =========================================

-- IMPORTANTE: Ejecuta este script en Supabase SQL Editor
-- Dashboard > SQL Editor > New Query > Pega este código > Run

DO $$
DECLARE
  v_user_id UUID;
  v_producto_id UUID;
  v_compra_id UUID;
BEGIN
  -- =========================================
  -- Paso 1: Obtener el user_id del usuario
  -- =========================================
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'brandonsoto1908@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuario no encontrado: brandonsoto1908@gmail.com';
  END IF;

  RAISE NOTICE 'Usuario encontrado: %', v_user_id;

  -- =========================================
  -- Paso 2: INSERTAR PRODUCTOS
  -- =========================================

  -- 1. Liquid TIDE
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Liquid Tide Softener',
    'Tide',
    'Suavizante de telas líquido de alta calidad',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 2. GAIN FABRIC SOFTENER
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Fabric Softener',
    'Gain',
    'Suavizante de telas con fragancia duradera',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 3. DAWN DISH SOAP
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Dish Soap',
    'Dawn',
    'Jabón líquido para lavar platos con poder desengrasante',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 4. FABULOSO
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Limpiador Multiusos',
    'Fabuloso',
    'Limpiador líquido multiusos con fragancia',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 5. Laundry Bleach
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Laundry Bleach',
    'Bleach',
    'Blanqueador para lavandería, elimina manchas difíciles',
    'litros',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 6. TIDE PODS
  INSERT INTO productos (nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    'Laundry Pods 8g',
    'Tide Pods',
    'Cápsulas de detergente concentrado, 1600 piezas por cartón',
    'unidades',
    true
  )
  ON CONFLICT (nombre, marca) DO NOTHING;

  -- 7. Laundry Beads
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
  -- Paso 3: CREAR COMPRAS Y DETALLES
  -- =========================================

  -- COMPRA 1: Liquid TIDE (1000L @ $0.57/L = $570)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Liquid Tide Softener' AND marca = 'Tide';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 570, 'Compra inicial - Liquid Tide', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.57, 570);

  -- COMPRA 2: GAIN FABRIC SOFTENER (1000L @ $0.575/L = $575)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Fabric Softener' AND marca = 'Gain';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 575, 'Compra inicial - Gain Softener', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.575, 575);

  -- COMPRA 3: DAWN DISH SOAP (1000L @ $0.53/L = $530)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Dish Soap' AND marca = 'Dawn';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 530, 'Compra inicial - Dawn Dish Soap', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.53, 530);

  -- COMPRA 4: FABULOSO (1000L @ $0.39/L = $390)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Limpiador Multiusos' AND marca = 'Fabuloso';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 390, 'Compra inicial - Fabuloso', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.39, 390);

  -- COMPRA 5: Laundry Bleach (1000L @ $0.41/L = $410)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Laundry Bleach' AND marca = 'Bleach';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 410, 'Compra inicial - Bleach', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.41, 410);

  -- COMPRA 6: TIDE PODS (1600 unidades @ $0.02125/unidad = $34)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Laundry Pods 8g' AND marca = 'Tide Pods';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 34, 'Compra inicial - Tide Pods (1 cartón)', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1600, 0.02125, 34);

  -- COMPRA 7: Laundry Beads (100 KG @ $4.35/KG = $435)
  SELECT id INTO v_producto_id FROM productos WHERE nombre = 'Laundry Beads' AND marca = 'Generic';
  
  INSERT INTO compras (fecha, total_usd, notas, usuario_id)
  VALUES (CURRENT_DATE, 435, 'Compra inicial - Laundry Beads', v_user_id)
  RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 100, 4.35, 435);

  RAISE NOTICE '✅ Compras y detalles registrados exitosamente';
  RAISE NOTICE '⚠️ El inventario se actualizará automáticamente mediante triggers';

END $$;

-- =========================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- =========================================
SELECT 
  p.nombre,
  p.marca,
  p.unidad_medida,
  COUNT(DISTINCT cd.compra_id) as num_compras,
  COALESCE(SUM(cd.cantidad), 0) as cantidad_comprada,
  COALESCE(SUM(cd.subtotal_usd), 0) as total_invertido,
  COALESCE(i.cantidad_disponible, 0) as stock_actual,
  COALESCE(i.costo_promedio_usd, 0) as costo_promedio
FROM productos p
LEFT JOIN compras_detalle cd ON cd.producto_id = p.id
LEFT JOIN inventario i ON i.producto_id = p.id
WHERE p.nombre IN (
  'Liquid Tide Softener',
  'Fabric Softener',
  'Dish Soap',
  'Limpiador Multiusos',
  'Laundry Bleach',
  'Laundry Pods 8g',
  'Laundry Beads'
)
GROUP BY p.id, p.nombre, p.marca, p.unidad_medida, i.cantidad_disponible, i.costo_promedio_usd
ORDER BY p.nombre;

-- =========================================
-- RESUMEN
-- =========================================
-- ✅ 7 Productos creados
-- ✅ 7 Compras registradas
-- ✅ 7 Detalles de compra insertados
-- ✅ Inventario actualizado automáticamente
-- 💰 Total invertido: $2,944 USD
-- =========================================
