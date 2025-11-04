-- =========================================
-- ACTUALIZACIÓN DE TRIGGERS PARA MULTI-TENANT
-- Actualiza las funciones trigger para incluir usuario_id
-- =========================================

-- ============================================
-- FUNCIÓN: Actualizar inventario al registrar compra
-- (Con soporte para usuario_id)
-- ============================================
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

-- ============================================
-- FUNCIÓN: Actualizar inventario al registrar venta
-- (Con soporte para usuario_id)
-- ============================================
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
      AND usuario_id = v_usuario_id;  -- ✅ Filtrar por usuario

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

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT 
    tgname as trigger_name,
    tgtype as trigger_type,
    proname as function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgname IN (
    'trigger_actualizar_inventario_compra',
    'trigger_actualizar_inventario_venta'
)
ORDER BY tgname;
