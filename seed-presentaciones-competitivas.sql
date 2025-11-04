-- =========================================
-- SEED: PRESENTACIONES BASADAS EN COMPETENCIA
-- =========================================
-- Crea presentaciones para tus productos usando:
-- 1. Cantidades similares a la competencia
-- 2. Costos de tus compras reales
-- 3. Márgenes competitivos
-- =========================================

BEGIN;

DO $$
DECLARE
  v_user_id UUID;
  v_producto_id UUID;
  v_costo_promedio_usd DECIMAL(12, 4);
  v_tasa_cambio DECIMAL(12, 2) := 540.00;
  v_margen_objetivo DECIMAL(5, 2) := 30.00; -- 30% margen por defecto
BEGIN
  -- Obtener ID del usuario
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'system@stonebyric.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuario system@stonebyric.com no encontrado';
  END IF;
  
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '📦 GENERANDO PRESENTACIONES BASADAS EN COMPETENCIA';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';

  -- ============================================
  -- DAWN (JABÓN PARA PLATOS)
  -- ============================================
  RAISE NOTICE '🧼 DAWN - Jabón para platos';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE p.nombre ILIKE '%dawn%' AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 434ml (similar a Walmart $3.73)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '434ml Botella',
      434,
      'mililitros',
      0.50, -- Costo envase pequeño
      ROUND((((0.434 * v_costo_promedio_usd) + 0.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 434ml - Precio: ₡%', ROUND((((0.434 * v_costo_promedio_usd) + 0.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 2.66L (similar a PriceSmart $11.50-$15.94)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '2.66 Litros',
      2.66,
      'litros',
      2.00,
      ROUND((((2.66 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 2.66L - Precio: ₡%', ROUND((((2.66 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;
  
  -- ============================================
  -- BLEACH/CLORO
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '🧴 BLEACH - Cloro';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE (p.nombre ILIKE '%bleach%' OR p.nombre ILIKE '%cloro%') AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 1.893L (similar a Walmart Great Value $1.79)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '1.9 Litros',
      1.9,
      'litros',
      1.00,
      ROUND((((1.9 * v_costo_promedio_usd) + 1.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 1.9L - Precio: ₡%', ROUND((((1.9 * v_costo_promedio_usd) + 1.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 3.785L (similar a Walmart Clorox $3.39)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '3.8 Litros',
      3.8,
      'litros',
      2.00,
      ROUND((((3.8 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 3.8L - Precio: ₡%', ROUND((((3.8 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;

  -- ============================================
  -- TIDE (DETERGENTE)
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '🧺 TIDE - Detergente líquido';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE p.nombre ILIKE '%tide%' AND p.nombre ILIKE '%liquid%' AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 3.9L (similar a Walmart $34.87)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '3.9 Litros',
      3.9,
      'litros',
      3.00,
      ROUND((((3.9 * v_costo_promedio_usd) + 3.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 3.9L - Precio: ₡%', ROUND((((3.9 * v_costo_promedio_usd) + 3.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 5L (similar a PriceSmart $35.48)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '5 Litros',
      5,
      'litros',
      3.50,
      ROUND((((5 * v_costo_promedio_usd) + 3.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 5L - Precio: ₡%', ROUND((((5 * v_costo_promedio_usd) + 3.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;

  -- ============================================
  -- TIDE PODS
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '💊 TIDE PODS';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE p.nombre ILIKE '%tide%' AND p.nombre ILIKE '%pods%' AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 81 pods (pack común)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '81 Pods',
      81,
      'unidades',
      1.50,
      ROUND((((81 * v_costo_promedio_usd) + 1.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 81 pods - Precio: ₡%', ROUND((((81 * v_costo_promedio_usd) + 1.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 152 pods (pack grande)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '152 Pods',
      152,
      'unidades',
      2.50,
      ROUND((((152 * v_costo_promedio_usd) + 2.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 152 pods - Precio: ₡%', ROUND((((152 * v_costo_promedio_usd) + 2.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;

  -- ============================================
  -- GAIN
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '🌸 GAIN - Detergente';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE p.nombre ILIKE '%gain%' AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 2L
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '2 Litros',
      2,
      'litros',
      1.50,
      ROUND((((2 * v_costo_promedio_usd) + 1.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 2L - Precio: ₡%', ROUND((((2 * v_costo_promedio_usd) + 1.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 4L
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '4 Litros',
      4,
      'litros',
      2.50,
      ROUND((((4 * v_costo_promedio_usd) + 2.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 4L - Precio: ₡%', ROUND((((4 * v_costo_promedio_usd) + 2.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;

  -- ============================================
  -- FABULOSO
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '🍋 FABULOSO - Desinfectante';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE p.nombre ILIKE '%fabuloso%' AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 750ml (similar a Walmart $1.46)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '750ml',
      750,
      'mililitros',
      0.50,
      ROUND((((0.750 * v_costo_promedio_usd) + 0.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 750ml - Precio: ₡%', ROUND((((0.750 * v_costo_promedio_usd) + 0.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 3.78L (similar a Walmart $6.58)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '3.8 Litros',
      3.8,
      'litros',
      2.00,
      ROUND((((3.8 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 3.8L - Precio: ₡%', ROUND((((3.8 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 10L Pack (2x5L similar a PriceSmart $14.55)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '10 Litros (2x5L)',
      10,
      'litros',
      3.00,
      ROUND((((10 * v_costo_promedio_usd) + 3.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 10L - Precio: ₡%', ROUND((((10 * v_costo_promedio_usd) + 3.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;

  -- ============================================
  -- LAUNDRY BEADS (PERLAS)
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '✨ LAUNDRY BEADS - Perlas aromáticas';
  
  SELECT p.id, i.costo_promedio_usd INTO v_producto_id, v_costo_promedio_usd
  FROM productos p
  JOIN inventario i ON i.producto_id = p.id
  WHERE (p.nombre ILIKE '%beads%' OR p.nombre ILIKE '%perlas%') AND p.usuario_id = v_user_id
  LIMIT 1;
  
  IF v_producto_id IS NOT NULL THEN
    -- 680g (similar a Walmart $12.76)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '680 gramos',
      680,
      'gramos',
      1.50,
      ROUND((((0.680 * v_costo_promedio_usd) + 1.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 680g - Precio: ₡%', ROUND((((0.680 * v_costo_promedio_usd) + 1.50) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
    
    -- 1.06kg (similar a PriceSmart $13.95)
    INSERT INTO presentaciones (usuario_id, producto_id, nombre, cantidad, unidad, costo_envase, precio_venta_colones, activo)
    VALUES (
      v_user_id,
      v_producto_id,
      '1.06 Kilogramos',
      1.06,
      'kilogramos',
      2.00,
      ROUND((((1.06 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2),
      true
    );
    RAISE NOTICE '  ✅ 1.06kg - Precio: ₡%', ROUND((((1.06 * v_costo_promedio_usd) + 2.00) * v_tasa_cambio) * (1 + (v_margen_objetivo / 100)), 2);
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ PRESENTACIONES GENERADAS EXITOSAMENTE';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  
END $$;

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 
  p.nombre as producto,
  p.marca,
  p.categoria,
  COUNT(pres.id) as total_presentaciones,
  STRING_AGG(pres.nombre, ', ') as presentaciones
FROM productos p
LEFT JOIN presentaciones pres ON pres.producto_id = p.id AND pres.activo = true
JOIN auth.users u ON u.id = p.usuario_id
WHERE u.email = 'system@stonebyric.com'
  AND p.activo = true
GROUP BY p.nombre, p.marca, p.categoria
ORDER BY p.categoria, p.nombre;
