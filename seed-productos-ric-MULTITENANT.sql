-- =========================================
-- SCRIPT DE INSERCIÓN DE PRODUCTOS (MULTI-TENANT)
-- Usuario: ric@stonebyric.com
-- Fecha: Actualizado con usuario_id
-- Cantidades: 5000L (líquidos), 200 unidades (Tide Pods)
-- =========================================

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
  WHERE email = 'ric@stonebyric.com';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuario no encontrado: ric@stonebyric.com';
  END IF;

  RAISE NOTICE '✅ Usuario encontrado: %', v_user_id;

  -- =========================================
  -- Paso 2: INSERTAR PRODUCTOS (CON usuario_id)
  -- =========================================

  -- 1. Liquid TIDE (5000L)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Liquid Tide Softener',
    'Tide',
    'Suavizante de telas líquido de alta calidad',
    'litros',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Liquid Tide Softener (ID: %)', v_producto_id;

  -- Crear compra (5000L × $0.384 = $1,920)
  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (
    v_user_id,
    '2025-11-03',
    1.00,
    1920.00,
    'completada'
  )
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

  -- 2. GAIN FABRIC SOFTENER (5000L)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Fabric Softener',
    'Gain',
    'Suavizante de telas con fragancia duradera',
    'litros',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Fabric Softener (ID: %)', v_producto_id;

  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (v_user_id, '2025-11-03', 1.00, 1920.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

  -- 3. DAWN SOAP (5000L)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Dawn Soap',
    'Dawn',
    'Jabón líquido para trastes ultra concentrado',
    'litros',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Dawn Soap (ID: %)', v_producto_id;

  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (v_user_id, '2025-11-03', 1.00, 1920.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

  -- 4. FABULOSO (5000L)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Fabuloso',
    'Fabuloso',
    'Limpiador multiusos con fragancia fresca',
    'litros',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Fabuloso (ID: %)', v_producto_id;

  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (v_user_id, '2025-11-03', 1.00, 1920.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

  -- 5. BLEACH (5000L)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Bleach',
    'Clorox',
    'Blanqueador desinfectante multiusos',
    'litros',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Bleach (ID: %)', v_producto_id;

  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (v_user_id, '2025-11-03', 1.00, 1920.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

  -- 6. TIDE PODS (200 unidades)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Tide Pods',
    'Tide',
    'Cápsulas de detergente 3 en 1',
    'unidades',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Tide Pods (ID: %)', v_producto_id;

  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (v_user_id, '2025-11-03', 1.00, 160.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 200, 0.80, 160.00);

  -- 7. LAUNDRY BEADS (160 unidades)
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (
    v_user_id,
    'Laundry Beads',
    'Downy',
    'Perlas aromáticas para ropa',
    'unidades',
    true
  )
  RETURNING id INTO v_producto_id;
  RAISE NOTICE '  📦 Producto creado: Laundry Beads (ID: %)', v_producto_id;

  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (v_user_id, '2025-11-03', 1.00, 160.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 160, 1.00, 160.00);

  -- =========================================
  -- RESUMEN
  -- =========================================
  RAISE NOTICE '🎉 INSERCIÓN COMPLETADA EXITOSAMENTE';
  RAISE NOTICE '📊 Productos creados: 7';
  RAISE NOTICE '📊 Compras registradas: 7';
  RAISE NOTICE '💰 Inversión total: $9,920.00 USD';
  RAISE NOTICE '📦 Cantidades: 5000L (líquidos), 200 Tide Pods, 160 Laundry Beads';
  RAISE NOTICE '👤 Usuario: ric@stonebyric.com';
  
END $$;
