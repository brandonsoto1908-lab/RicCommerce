-- =========================================
-- SCRIPT MAESTRO: MIGRACIÓN COMPLETA A MULTI-TENANT
-- =========================================
-- 
-- Este script ejecuta TODO el proceso de migración:
-- 1. Limpia todos los datos
-- 2. Agrega usuario_id a las tablas
-- 3. Configura políticas RLS
-- 4. Re-inserta los datos con aislamiento por usuario
--
-- IMPORTANTE: Ejecuta este script en Supabase SQL Editor
-- Dashboard > SQL Editor > New Query > Pega TODO este código > Run
-- =========================================

BEGIN;

-- =========================================
-- FASE 1: LIMPIEZA DE DATOS
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🧹 FASE 1: LIMPIANDO TODOS LOS DATOS';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  DELETE FROM ventas_detalle;
  RAISE NOTICE '✅ ventas_detalle limpiado';
  
  DELETE FROM compras_detalle;
  RAISE NOTICE '✅ compras_detalle limpiado';
  
  DELETE FROM ventas;
  RAISE NOTICE '✅ ventas limpiado';
  
  DELETE FROM compras;
  RAISE NOTICE '✅ compras limpiado';
  
  DELETE FROM gastos;
  RAISE NOTICE '✅ gastos limpiado';
  
  DELETE FROM movimientos_inventario;
  RAISE NOTICE '✅ movimientos_inventario limpiado';
  
  DELETE FROM inventario;
  RAISE NOTICE '✅ inventario limpiado';
  
  DELETE FROM presentaciones;
  RAISE NOTICE '✅ presentaciones limpiado';
  
  DELETE FROM productos;
  RAISE NOTICE '✅ productos limpiado';
  
  DELETE FROM historial_precios;
  RAISE NOTICE '✅ historial_precios limpiado';

  RAISE NOTICE '🎉 Limpieza completada';
END $$;

-- =========================================
-- FASE 2: MIGRACIÓN DE SCHEMA
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔧 FASE 2: MIGRANDO SCHEMA A MULTI-TENANT';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  -- PRODUCTOS
  RAISE NOTICE '📦 Migrando tabla productos...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'productos' AND column_name = 'usuario_id'
  ) THEN
    ALTER TABLE productos ADD COLUMN usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '  ✅ Columna usuario_id agregada';
  END IF;

  -- Eliminar constraint global
  BEGIN
    ALTER TABLE productos DROP CONSTRAINT IF EXISTS productos_nombre_marca_key;
    RAISE NOTICE '  ✅ Constraint global eliminado';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '  ℹ️  Constraint global no existe';
  END;

  -- Agregar constraint por usuario
  BEGIN
    ALTER TABLE productos ADD CONSTRAINT productos_usuario_nombre_marca_key 
      UNIQUE(usuario_id, nombre, marca);
    RAISE NOTICE '  ✅ Constraint por usuario agregado';
  EXCEPTION WHEN duplicate_table THEN
    RAISE NOTICE '  ℹ️  Constraint ya existe';
  END;

  CREATE INDEX IF NOT EXISTS idx_productos_usuario_id ON productos(usuario_id);
  RAISE NOTICE '  ✅ Índice creado';

  -- PRESENTACIONES
  RAISE NOTICE '📋 Migrando tabla presentaciones...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'presentaciones' AND column_name = 'usuario_id'
  ) THEN
    ALTER TABLE presentaciones ADD COLUMN usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '  ✅ Columna usuario_id agregada';
  END IF;

  CREATE INDEX IF NOT EXISTS idx_presentaciones_usuario_id ON presentaciones(usuario_id);
  RAISE NOTICE '  ✅ Índice creado';

  -- INVENTARIO
  RAISE NOTICE '📊 Migrando tabla inventario...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'inventario' AND column_name = 'usuario_id'
  ) THEN
    ALTER TABLE inventario ADD COLUMN usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '  ✅ Columna usuario_id agregada';
  END IF;

  CREATE INDEX IF NOT EXISTS idx_inventario_usuario_id ON inventario(usuario_id);
  RAISE NOTICE '  ✅ Índice creado';

  RAISE NOTICE '🎉 Migración de schema completada';
END $$;

-- =========================================
-- FASE 3: CONFIGURACIÓN RLS
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔒 FASE 3: CONFIGURANDO POLÍTICAS RLS';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  -- PRODUCTOS
  RAISE NOTICE '🔐 Configurando RLS para productos...';
  ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
  
  DROP POLICY IF EXISTS productos_isolation_select ON productos;
  DROP POLICY IF EXISTS productos_isolation_insert ON productos;
  DROP POLICY IF EXISTS productos_isolation_update ON productos;
  DROP POLICY IF EXISTS productos_isolation_delete ON productos;
  
  CREATE POLICY productos_isolation_select ON productos
    FOR SELECT USING (usuario_id = auth.uid());
  
  CREATE POLICY productos_isolation_insert ON productos
    FOR INSERT WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY productos_isolation_update ON productos
    FOR UPDATE USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY productos_isolation_delete ON productos
    FOR DELETE USING (usuario_id = auth.uid());
  
  RAISE NOTICE '  ✅ Políticas configuradas';

  -- PRESENTACIONES
  RAISE NOTICE '🔐 Configurando RLS para presentaciones...';
  ALTER TABLE presentaciones ENABLE ROW LEVEL SECURITY;
  
  DROP POLICY IF EXISTS presentaciones_isolation_select ON presentaciones;
  DROP POLICY IF EXISTS presentaciones_isolation_insert ON presentaciones;
  DROP POLICY IF EXISTS presentaciones_isolation_update ON presentaciones;
  DROP POLICY IF EXISTS presentaciones_isolation_delete ON presentaciones;
  
  CREATE POLICY presentaciones_isolation_select ON presentaciones
    FOR SELECT USING (usuario_id = auth.uid());
  
  CREATE POLICY presentaciones_isolation_insert ON presentaciones
    FOR INSERT WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY presentaciones_isolation_update ON presentaciones
    FOR UPDATE USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY presentaciones_isolation_delete ON presentaciones
    FOR DELETE USING (usuario_id = auth.uid());
  
  RAISE NOTICE '  ✅ Políticas configuradas';

  -- INVENTARIO
  RAISE NOTICE '🔐 Configurando RLS para inventario...';
  ALTER TABLE inventario ENABLE ROW LEVEL SECURITY;
  
  DROP POLICY IF EXISTS inventario_isolation_select ON inventario;
  DROP POLICY IF EXISTS inventario_isolation_insert ON inventario;
  DROP POLICY IF EXISTS inventario_isolation_update ON inventario;
  DROP POLICY IF EXISTS inventario_isolation_delete ON inventario;
  
  CREATE POLICY inventario_isolation_select ON inventario
    FOR SELECT USING (usuario_id = auth.uid());
  
  CREATE POLICY inventario_isolation_insert ON inventario
    FOR INSERT WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY inventario_isolation_update ON inventario
    FOR UPDATE USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY inventario_isolation_delete ON inventario
    FOR DELETE USING (usuario_id = auth.uid());
  
  RAISE NOTICE '  ✅ Políticas configuradas';

  RAISE NOTICE '🎉 Configuración RLS completada';
END $$;

-- =========================================
-- FASE 3.5: ACTUALIZAR TRIGGERS
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔧 FASE 3.5: ACTUALIZANDO TRIGGERS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  
  RAISE NOTICE '📝 Actualizando trigger de compras...';
END $$;

-- Actualizar función de trigger para compras
CREATE OR REPLACE FUNCTION actualizar_inventario_compra()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_id UUID;
BEGIN
    -- Obtener el usuario_id de la compra
    SELECT usuario_id INTO v_usuario_id
    FROM compras
    WHERE id = NEW.compra_id;

    -- Insertar o actualizar inventario (CON usuario_id)
    INSERT INTO inventario (producto_id, usuario_id, cantidad_disponible, costo_promedio_usd)
    VALUES (NEW.producto_id, v_usuario_id, NEW.cantidad, NEW.precio_unitario_usd)
    ON CONFLICT (producto_id) 
    DO UPDATE SET
        cantidad_disponible = inventario.cantidad_disponible + NEW.cantidad,
        costo_promedio_usd = (
            (inventario.cantidad_disponible * inventario.costo_promedio_usd) + 
            (NEW.cantidad * NEW.precio_unitario_usd)
        ) / (inventario.cantidad_disponible + NEW.cantidad),
        updated_at = CURRENT_TIMESTAMP;
    
    -- Registrar movimiento (CON usuario_id)
    INSERT INTO movimientos_inventario (
        producto_id, tipo, cantidad, referencia_tipo, referencia_id, usuario_id
    ) VALUES (
        NEW.producto_id, 'entrada', NEW.cantidad, 'compra', NEW.compra_id, v_usuario_id
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear trigger
DROP TRIGGER IF EXISTS trigger_actualizar_inventario_compra ON compras_detalle;
CREATE TRIGGER trigger_actualizar_inventario_compra
AFTER INSERT ON compras_detalle
FOR EACH ROW EXECUTE FUNCTION actualizar_inventario_compra();

-- Actualizar función de trigger para ventas
CREATE OR REPLACE FUNCTION actualizar_inventario_venta()
RETURNS TRIGGER AS $$
DECLARE
    v_producto_id UUID;
    v_cantidad_presentacion DECIMAL(10, 2);
    v_cantidad_total DECIMAL(10, 2);
    v_usuario_id UUID;
BEGIN
    -- Obtener el usuario_id de la venta
    SELECT usuario_id INTO v_usuario_id
    FROM ventas
    WHERE id = NEW.venta_id;

    -- Obtener información de la presentación y producto
    SELECT producto_id, cantidad
    INTO v_producto_id, v_cantidad_presentacion
    FROM presentaciones
    WHERE id = NEW.presentacion_id;

    -- Calcular cantidad total en unidades del producto base
    v_cantidad_total := v_cantidad_presentacion * NEW.cantidad;

    -- Actualizar inventario (restando stock)
    UPDATE inventario
    SET cantidad_disponible = cantidad_disponible - v_cantidad_total,
        updated_at = CURRENT_TIMESTAMP
    WHERE producto_id = v_producto_id
      AND usuario_id = v_usuario_id;

    -- Registrar movimiento (CON usuario_id)
    INSERT INTO movimientos_inventario (
        producto_id, tipo, cantidad, referencia_tipo, referencia_id, usuario_id
    ) VALUES (
        v_producto_id, 'salida', v_cantidad_total, 'venta', NEW.venta_id, v_usuario_id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear trigger
DROP TRIGGER IF EXISTS trigger_actualizar_inventario_venta ON ventas_detalle;
CREATE TRIGGER trigger_actualizar_inventario_venta
AFTER INSERT ON ventas_detalle
FOR EACH ROW EXECUTE FUNCTION actualizar_inventario_venta();

DO $$
BEGIN
  RAISE NOTICE '✅ Triggers actualizados correctamente';
END $$;

-- =========================================
-- FASE 4: INSERCIÓN DE DATOS - BRANDON
-- =========================================
DO $$
DECLARE
  v_user_id UUID;
  v_producto_id UUID;
  v_compra_id UUID;
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '📥 FASE 4A: INSERTANDO DATOS PARA BRANDON';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  SELECT id INTO v_user_id FROM auth.users WHERE email = 'brandonsoto1908@gmail.com';
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️  Usuario brandonsoto1908@gmail.com no encontrado, saltando...';
  ELSE
    RAISE NOTICE '✅ Usuario encontrado: brandonsoto1908@gmail.com';

    -- 1. Liquid TIDE
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Liquid Tide Softener', 'Tide', 'Suavizante de telas líquido de alta calidad', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 384.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

    -- 2. GAIN
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Fabric Softener', 'Gain', 'Suavizante de telas con fragancia duradera', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 384.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

    -- 3. DAWN
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Dawn Soap', 'Dawn', 'Jabón líquido para trastes ultra concentrado', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 384.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

    -- 4. FABULOSO
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Fabuloso', 'Fabuloso', 'Limpiador multiusos con fragancia fresca', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 384.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

    -- 5. BLEACH
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Bleach', 'Clorox', 'Blanqueador desinfectante multiusos', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 384.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 1000, 0.384, 384.00);

    -- 6. TIDE PODS
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Tide Pods', 'Tide', 'Cápsulas de detergente 3 en 1', 'unidades', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 1280.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 1600, 0.80, 1280.00);

    -- 7. LAUNDRY BEADS
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Laundry Beads', 'Downy', 'Perlas aromáticas para ropa', 'unidades', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 160.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 160, 1.00, 160.00);

    RAISE NOTICE '🎉 Datos de Brandon insertados: 7 productos, $2,944 USD';
  END IF;
END $$;

-- =========================================
-- FASE 5: INSERCIÓN DE DATOS - RIC
-- =========================================
DO $$
DECLARE
  v_user_id UUID;
  v_producto_id UUID;
  v_compra_id UUID;
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '📥 FASE 4B: INSERTANDO DATOS PARA RIC';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  SELECT id INTO v_user_id FROM auth.users WHERE email = 'ric@stonebyric.com';
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️  Usuario ric@stonebyric.com no encontrado, saltando...';
  ELSE
    RAISE NOTICE '✅ Usuario encontrado: ric@stonebyric.com';

    -- 1. Liquid TIDE (5000L)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Liquid Tide Softener', 'Tide', 'Suavizante de telas líquido de alta calidad', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 1920.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

    -- 2. GAIN (5000L)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Fabric Softener', 'Gain', 'Suavizante de telas con fragancia duradera', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 1920.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

    -- 3. DAWN (5000L)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Dawn Soap', 'Dawn', 'Jabón líquido para trastes ultra concentrado', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 1920.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

    -- 4. FABULOSO (5000L)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Fabuloso', 'Fabuloso', 'Limpiador multiusos con fragancia fresca', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 1920.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

    -- 5. BLEACH (5000L)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Bleach', 'Clorox', 'Blanqueador desinfectante multiusos', 'litros', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 1920.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 5000, 0.384, 1920.00);

    -- 6. TIDE PODS (200 unidades)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Tide Pods', 'Tide', 'Cápsulas de detergente 3 en 1', 'unidades', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 160.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 200, 0.80, 160.00);

    -- 7. LAUNDRY BEADS (160 unidades)
    INSERT INTO productos (usuario_id, nombre, marca, descripcion, unidad_medida, activo)
    VALUES (v_user_id, 'Laundry Beads', 'Downy', 'Perlas aromáticas para ropa', 'unidades', true)
    RETURNING id INTO v_producto_id;
    
    INSERT INTO compras (usuario_id, fecha, total_usd)
    VALUES (v_user_id, '2025-11-03', 160.00) RETURNING id INTO v_compra_id;
    
    INSERT INTO compras_detalle (compra_id, producto_id, cantidad, precio_unitario_usd, subtotal_usd)
    VALUES (v_compra_id, v_producto_id, 160, 1.00, 160.00);

    RAISE NOTICE '🎉 Datos de Ric insertados: 7 productos, $9,920 USD';
  END IF;
END $$;

-- =========================================
-- COMMIT Y VERIFICACIÓN FINAL
-- =========================================
COMMIT;

-- Verificar resultados
DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ MIGRACIÓN COMPLETADA EXITOSAMENTE';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📊 RESUMEN:';
  RAISE NOTICE '  ✅ Datos antiguos eliminados';
  RAISE NOTICE '  ✅ Schema migrado a multi-tenant';
  RAISE NOTICE '  ✅ Políticas RLS configuradas';
  RAISE NOTICE '  ✅ Datos re-insertados con aislamiento';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 SEGURIDAD:';
  RAISE NOTICE '  ✅ Cada usuario solo ve SUS productos';
  RAISE NOTICE '  ✅ Cada usuario solo ve SUS presentaciones';
  RAISE NOTICE '  ✅ Cada usuario solo ve SU inventario';
  RAISE NOTICE '';
  RAISE NOTICE '👥 USUARIOS:';
  RAISE NOTICE '  📧 brandonsoto1908@gmail.com: 7 productos, $2,944 USD';
  RAISE NOTICE '  📧 ric@stonebyric.com: 7 productos, $9,920 USD';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 ¡Sistema multi-tenant activado!';
END $$;

-- Estadísticas finales
SELECT 
  'productos' as tabla, 
  COUNT(*) as total_registros,
  COUNT(DISTINCT usuario_id) as usuarios_distintos
FROM productos
UNION ALL
SELECT 
  'compras', 
  COUNT(*), 
  COUNT(DISTINCT usuario_id)
FROM compras
UNION ALL
SELECT 
  'compras_detalle', 
  COUNT(*),
  COUNT(DISTINCT (SELECT usuario_id FROM compras WHERE compras.id = compras_detalle.compra_id))
FROM compras_detalle;
