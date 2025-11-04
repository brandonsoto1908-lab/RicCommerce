-- =========================================
-- SCRIPT DE INSERCIÓN DE PRODUCTOS (MULTI-TENANT)
-- Usuario: brandonsoto1908@gmail.com
-- Fecha: Actualizado con usuario_id
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
  WHERE email = 'brandonsoto1908@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuario no encontrado: brandonsoto1908@gmail.com';
  END IF;

  RAISE NOTICE '✅ Usuario encontrado: %', v_user_id;

  -- =========================================
  -- Paso 2: INSERTAR PRODUCTOS (CON usuario_id)
  -- =========================================

  -- 1. Liquid TIDE
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

  -- Crear compra
  INSERT INTO compras (usuario_id, fecha_compra, tipo_cambio, total_usd, estado)
  VALUES (
    v_user_id,
    '2025-11-03',
    1.00,
    384.00,
    'completada'
  )
  RETURNING id INTO v_compra_id;

  -- Detalle de compra
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

  -- 2. GAIN FABRIC SOFTENER
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
  VALUES (v_user_id, '2025-11-03', 1.00, 384.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

  -- 3. DAWN SOAP
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
  VALUES (v_user_id, '2025-11-03', 1.00, 384.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

  -- 4. FABULOSO
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
  VALUES (v_user_id, '2025-11-03', 1.00, 384.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

  -- 5. BLEACH
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
  VALUES (v_user_id, '2025-11-03', 1.00, 384.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

  -- 6. TIDE PODS
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
  VALUES (v_user_id, '2025-11-03', 1.00, 1280.00, 'completada')
  RETURNING id INTO v_compra_id;

  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, costo_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 1600, 0.80, 1280.00);

  -- 7. LAUNDRY BEADS
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
  RAISE NOTICE '💰 Inversión total: $2,944.00 USD';
  RAISE NOTICE '👤 Usuario: brandonsoto1908@gmail.com';
  
END $$;
