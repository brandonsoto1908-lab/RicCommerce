-- =========================================
-- INYECCIÓN DE DATOS PARA: system@stonebyric.com
-- =========================================
-- 
-- Este script inserta los productos con la estructura de precios actualizada
-- 
-- PRECIOS:
-- - Liquid TIDE: $2,850 USD / 5000L = $0.57/L
-- - GAIN: $2,875 USD / 5000L = $0.575/L
-- - DAWN: $2,650 USD / 5000L = $0.53/L
-- - FABULOSO: $1,950 USD / 5000L = $0.39/L
-- - BLEACH: $2,050 USD / 5000L = $0.41/L
-- - TIDE PODS: $850 USD / 5 cartons (8,000 pcs) = $0.10625/pc
-- - Laundry Beads: $4.35 USD/KG × 5 KG = $21.75
--
-- TOTAL INVERSIÓN: $13,246.75 USD
-- =========================================

BEGIN;

DO $$
DECLARE
  v_user_id UUID;
  v_producto_id UUID;
  v_compra_id UUID;
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '📥 INSERTANDO DATOS PARA SYSTEM@STONEBYRIC.COM';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  -- Obtener ID del usuario
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'system@stonebyric.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuario system@stonebyric.com no encontrado en auth.users';
  ELSE
    RAISE NOTICE '✅ Usuario encontrado: system@stonebyric.com';
    RAISE NOTICE 'Usuario ID: %', v_user_id;
  END IF;

  -- =========================================
  -- 1. LIQUID TIDE - $2,850 / 5000L
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 1/7: Liquid Tide Softener...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Liquid Tide Softener', 'Tide', 'Suavizante de telas líquido de alta calidad', 'litros', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 2850.00) RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.57, 2850.00);
  
  RAISE NOTICE '  ✅ Liquid TIDE: 5000L @ $0.57/L = $2,850';

  -- =========================================
  -- 2. GAIN - $2,875 / 5000L
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 2/7: Fabric Softener (Gain)...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Fabric Softener', 'Gain', 'Suavizante de telas con fragancia duradera', 'litros', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 2875.00) RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.575, 2875.00);
  
  RAISE NOTICE '  ✅ GAIN: 5000L @ $0.575/L = $2,875';

  -- =========================================
  -- 3. DAWN - $2,650 / 5000L
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 3/7: Dawn Soap...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Dawn Soap', 'Dawn', 'Jabón líquido para trastes ultra concentrado', 'litros', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 2650.00) RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.53, 2650.00);
  
  RAISE NOTICE '  ✅ DAWN: 5000L @ $0.53/L = $2,650';

  -- =========================================
  -- 4. FABULOSO - $1,950 / 5000L
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 4/7: Fabuloso...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Fabuloso', 'Fabuloso', 'Limpiador multiusos con fragancia fresca', 'litros', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 1950.00) RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.39, 1950.00);
  
  RAISE NOTICE '  ✅ FABULOSO: 5000L @ $0.39/L = $1,950';

  -- =========================================
  -- 5. BLEACH - $2,050 / 5000L
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 5/7: Bleach...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Bleach', 'Clorox', 'Blanqueador desinfectante multiusos', 'litros', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 2050.00) RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5000, 0.41, 2050.00);
  
  RAISE NOTICE '  ✅ BLEACH: 5000L @ $0.41/L = $2,050';

  -- =========================================
  -- 6. TIDE PODS - $850 total (5 cartons)
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 6/7: Tide Pods...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Tide Pods', 'Tide', 'Cápsulas de detergente 3 en 1 (8g por pieza, 1600 pcs/carton)', 'unidades', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 850.00) RETURNING id INTO v_compra_id;
  
  -- 5 cartons × 1600 pcs = 8000 pods
  -- $850 total / 8000 pcs = $0.10625 per pod
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 8000, 0.10625, 850.00);
  
  RAISE NOTICE '  ✅ TIDE PODS: 8000 pcs (5 cartons) @ $0.10625/pc = $850';

  -- =========================================
  -- 7. LAUNDRY BEADS - $4.35/KG × 5 KG
  -- =========================================
  RAISE NOTICE '📦 Insertando producto 7/7: Laundry Beads...';
  
  INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
  VALUES (v_user_id, 'Laundry Beads', 'Downy', 'Perlas aromáticas para ropa', 'kilogramos', true)
  RETURNING id INTO v_producto_id;
  
  INSERT INTO compras (usuario_id, fecha, total_usd)
  VALUES (v_user_id, '2025-11-03', 21.75) RETURNING id INTO v_compra_id;
  
  INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
  VALUES (v_compra_id, v_producto_id, 5, 4.35, 21.75);
  
  RAISE NOTICE '  ✅ LAUNDRY BEADS: 5 KG @ $4.35/KG = $21.75';

  -- =========================================
  -- RESUMEN
  -- =========================================
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ INSERCIÓN COMPLETADA';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '👤 Usuario: system@stonebyric.com';
  RAISE NOTICE '📦 Productos insertados: 7';
  RAISE NOTICE '';
  RAISE NOTICE '💰 RESUMEN FINANCIERO:';
  RAISE NOTICE '  • Liquid TIDE:     $ 2,850';
  RAISE NOTICE '  • GAIN:            $ 2,875';
  RAISE NOTICE '  • DAWN:            $ 2,650';
  RAISE NOTICE '  • FABULOSO:        $ 1,950';
  RAISE NOTICE '  • BLEACH:          $ 2,050';
  RAISE NOTICE '  • TIDE PODS:       $   850';
  RAISE NOTICE '  • LAUNDRY BEADS:   $    21.75';
  RAISE NOTICE '  ─────────────────────────';
  RAISE NOTICE '  TOTAL INVERSIÓN:   $13,246.75 USD';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 ¡Datos insertados exitosamente!';
  
END $$;

COMMIT;

-- =========================================
-- VERIFICACIÓN
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔍 VERIFICANDO INSERCIÓN';
  RAISE NOTICE '═══════════════════════════════════════════════════';
END $$;

-- Verificar productos por usuario
SELECT 
  '📊 PRODUCTOS POR USUARIO' as titulo,
  (SELECT email FROM auth.users WHERE id = productos.usuario_id) as usuario,
  COUNT(*) as total_productos,
  SUM((SELECT SUM(subtotal_usd) FROM compras_detalle cd 
       JOIN compras c ON cd.compra_id = c.id 
       WHERE cd.producto_id = productos.id)) as inversion_total_usd
FROM productos
GROUP BY usuario_id
ORDER BY usuario;

-- Detalle de productos para system@stonebyric.com
SELECT 
  '📦 DETALLE PRODUCTOS - system@stonebyric.com' as titulo,
  p.nombre,
  p.marca,
  cd.cantidad,
  p.unidad_medida,
  cd.precio_unitario_usd as precio_unitario,
  cd.subtotal_usd as total
FROM productos p
JOIN compras_detalle cd ON cd.producto_id = p.id
JOIN compras c ON c.id = cd.compra_id
JOIN auth.users u ON u.id = p.usuario_id
WHERE u.email = 'system@stonebyric.com'
ORDER BY p.nombre;
