-- ============================================
-- SISTEMA DE GESTIÓN DE PRODUCTOS DE LIMPIEZA
-- Base de Datos: Supabase (PostgreSQL)
-- ============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLA: productos
-- Descripción: Catálogo de productos de limpieza
-- ============================================
CREATE TABLE productos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL,
    marca VARCHAR(255) NOT NULL,
    descripcion TEXT,
    unidad_medida VARCHAR(50) NOT NULL, -- 'gramos', 'litros', 'unidades'
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nombre, marca)
);

-- ============================================
-- TABLA: presentaciones
-- Descripción: Diferentes presentaciones/envases de productos
-- ============================================
CREATE TABLE presentaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    nombre VARCHAR(255) NOT NULL, -- '1 litro', 'medio litro', '500g', etc.
    cantidad DECIMAL(10, 2) NOT NULL,
    unidad VARCHAR(50) NOT NULL,
    costo_envase DECIMAL(10, 2) DEFAULT 0, -- Costo del envase en dólares
    precio_venta_colones DECIMAL(10, 2) NOT NULL,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: compras
-- Descripción: Registro de compras de productos
-- ============================================
CREATE TABLE compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    total_usd DECIMAL(10, 2) NOT NULL,
    notas TEXT,
    usuario_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: compras_detalle
-- Descripción: Detalle de productos en cada compra
-- ============================================
CREATE TABLE compras_detalle (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    compra_id UUID REFERENCES compras(id) ON DELETE CASCADE,
    producto_id UUID REFERENCES productos(id),
    cantidad DECIMAL(10, 2) NOT NULL,
    precio_unitario_usd DECIMAL(10, 2) NOT NULL,
    subtotal_usd DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: ventas
-- Descripción: Registro de ventas de productos
-- ============================================
CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    total_colones DECIMAL(10, 2) NOT NULL,
    total_usd DECIMAL(10, 2) NOT NULL,
    tasa_cambio DECIMAL(10, 4) NOT NULL,
    notas TEXT,
    usuario_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: ventas_detalle
-- Descripción: Detalle de productos vendidos
-- ============================================
CREATE TABLE ventas_detalle (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id UUID REFERENCES ventas(id) ON DELETE CASCADE,
    presentacion_id UUID REFERENCES presentaciones(id),
    cantidad INTEGER NOT NULL,
    precio_unitario_colones DECIMAL(10, 2) NOT NULL,
    subtotal_colones DECIMAL(10, 2) NOT NULL,
    costo_unitario_usd DECIMAL(10, 2) NOT NULL,
    margen_porcentaje DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: gastos
-- Descripción: Registro de gastos del negocio
-- ============================================
CREATE TABLE gastos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tipo VARCHAR(50) NOT NULL, -- 'unico', 'utilitario'
    categoria VARCHAR(100) NOT NULL, -- 'agua', 'luz', 'internet', 'otros'
    descripcion TEXT NOT NULL,
    monto_usd DECIMAL(10, 2) NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    periodicidad VARCHAR(50), -- 'mensual', 'semanal', 'quincenal', 'anual', null
    activo BOOLEAN DEFAULT true,
    usuario_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: inventario
-- Descripción: Stock actual de productos
-- ============================================
CREATE TABLE inventario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE UNIQUE,
    cantidad_disponible DECIMAL(10, 2) NOT NULL DEFAULT 0,
    costo_promedio_usd DECIMAL(10, 2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: movimientos_inventario
-- Descripción: Historial de movimientos de inventario
-- ============================================
CREATE TABLE movimientos_inventario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL, -- 'entrada', 'salida', 'ajuste'
    cantidad DECIMAL(10, 2) NOT NULL,
    referencia_tipo VARCHAR(50), -- 'compra', 'venta', 'ajuste_manual'
    referencia_id UUID,
    notas TEXT,
    usuario_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: historial_precios
-- Descripción: Historial de cambios de precios (opcional)
-- ============================================
CREATE TABLE historial_precios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    presentacion_id UUID REFERENCES presentaciones(id) ON DELETE CASCADE,
    precio_anterior_colones DECIMAL(10, 2),
    precio_nuevo_colones DECIMAL(10, 2),
    margen_anterior DECIMAL(10, 2),
    margen_nuevo DECIMAL(10, 2),
    usuario_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: perfiles_usuario
-- Descripción: Información adicional de usuarios
-- ============================================
CREATE TABLE perfiles_usuario (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nombre_completo VARCHAR(255),
    rol VARCHAR(50) DEFAULT 'usuario', -- 'admin', 'usuario'
    puede_editar BOOLEAN DEFAULT false,
    puede_eliminar BOOLEAN DEFAULT false,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: configuracion
-- Descripción: Configuración del sistema
-- ============================================
CREATE TABLE configuracion (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    descripcion TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ÍNDICES PARA MEJORAR PERFORMANCE
-- ============================================
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_presentaciones_producto ON presentaciones(producto_id);
CREATE INDEX idx_compras_fecha ON compras(fecha);
CREATE INDEX idx_ventas_fecha ON ventas(fecha);
CREATE INDEX idx_gastos_fecha ON gastos(fecha);
CREATE INDEX idx_gastos_tipo ON gastos(tipo);
CREATE INDEX idx_movimientos_producto ON movimientos_inventario(producto_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(created_at);

-- ============================================
-- TRIGGERS PARA ACTUALIZAR updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_productos_updated_at BEFORE UPDATE ON productos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_presentaciones_updated_at BEFORE UPDATE ON presentaciones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_compras_updated_at BEFORE UPDATE ON compras
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ventas_updated_at BEFORE UPDATE ON ventas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gastos_updated_at BEFORE UPDATE ON gastos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventario_updated_at BEFORE UPDATE ON inventario
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_perfiles_updated_at BEFORE UPDATE ON perfiles_usuario
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNCIÓN: Actualizar inventario al registrar compra
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario_compra()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar o actualizar inventario
    INSERT INTO inventario (producto_id, cantidad_disponible, costo_promedio_usd)
    VALUES (NEW.producto_id, NEW.cantidad, NEW.precio_unitario_usd)
    ON CONFLICT (producto_id) 
    DO UPDATE SET
        cantidad_disponible = inventario.cantidad_disponible + NEW.cantidad,
        costo_promedio_usd = (
            (inventario.cantidad_disponible * inventario.costo_promedio_usd) + 
            (NEW.cantidad * NEW.precio_unitario_usd)
        ) / (inventario.cantidad_disponible + NEW.cantidad),
        updated_at = CURRENT_TIMESTAMP;
    
    -- Registrar movimiento
    INSERT INTO movimientos_inventario (
        producto_id, tipo, cantidad, referencia_tipo, referencia_id
    ) VALUES (
        NEW.producto_id, 'entrada', NEW.cantidad, 'compra', NEW.compra_id
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_inventario_compra
AFTER INSERT ON compras_detalle
FOR EACH ROW EXECUTE FUNCTION actualizar_inventario_compra();

-- ============================================
-- FUNCIÓN: Actualizar inventario al registrar venta
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario_venta()
RETURNS TRIGGER AS $$
DECLARE
    v_producto_id UUID;
    v_cantidad_presentacion DECIMAL(10, 2);
    v_cantidad_total DECIMAL(10, 2);
BEGIN
    -- Obtener información de la presentación y producto
    SELECT producto_id, cantidad
    INTO v_producto_id, v_cantidad_presentacion
    FROM presentaciones
    WHERE id = NEW.presentacion_id;
    
    -- Calcular cantidad total a descontar (cantidad de venta * cantidad de la presentación)
    v_cantidad_total := v_cantidad_presentacion * NEW.cantidad;
    
    -- Actualizar inventario
    UPDATE inventario
    SET cantidad_disponible = cantidad_disponible - v_cantidad_total,
        updated_at = CURRENT_TIMESTAMP
    WHERE producto_id = v_producto_id;
    
    -- Registrar movimiento
    INSERT INTO movimientos_inventario (
        producto_id, tipo, cantidad, referencia_tipo, referencia_id
    ) VALUES (
        v_producto_id, 'salida', v_cantidad_total, 'venta', NEW.venta_id
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_inventario_venta
AFTER INSERT ON ventas_detalle
FOR EACH ROW EXECUTE FUNCTION actualizar_inventario_venta();

-- ============================================
-- INSERTAR CONFIGURACIÓN INICIAL
-- ============================================
INSERT INTO configuracion (clave, valor, descripcion) VALUES
('tasa_cambio_manual', '520', 'Tasa de cambio USD a CRC manual'),
('usar_api_cambio', 'true', 'Usar API para obtener tasa de cambio'),
('margen_minimo_alerta', '15', 'Porcentaje de margen mínimo para alertas'),
('sistema_inicializado', 'true', 'Indica si el sistema fue inicializado');

-- ============================================
-- POLÍTICAS DE SEGURIDAD RLS (Row Level Security)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE presentaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras_detalle ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_detalle ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastos ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventario ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_inventario ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_precios ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfiles_usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracion ENABLE ROW LEVEL SECURITY;

-- Políticas: Los usuarios autenticados pueden leer todo
CREATE POLICY "Usuarios pueden leer productos" ON productos
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer presentaciones" ON presentaciones
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer compras" ON compras
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer compras_detalle" ON compras_detalle
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer ventas" ON ventas
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer ventas_detalle" ON ventas_detalle
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer gastos" ON gastos
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer inventario" ON inventario
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer movimientos" ON movimientos_inventario
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer historial_precios" ON historial_precios
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden leer configuracion" ON configuracion
    FOR SELECT USING (auth.role() = 'authenticated');

-- Políticas: Solo usuarios autenticados pueden insertar
CREATE POLICY "Usuarios pueden insertar productos" ON productos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar presentaciones" ON presentaciones
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar compras" ON compras
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar compras_detalle" ON compras_detalle
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar ventas" ON ventas
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar ventas_detalle" ON ventas_detalle
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar gastos" ON gastos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar inventario" ON inventario
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar movimientos" ON movimientos_inventario
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden insertar historial_precios" ON historial_precios
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Políticas de actualización para todos los usuarios autenticados
CREATE POLICY "Usuarios pueden actualizar productos" ON productos
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar presentaciones" ON presentaciones
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Sistema puede actualizar inventario" ON inventario
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar compras" ON compras
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar ventas" ON ventas
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar gastos" ON gastos
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Políticas de eliminación para todos los usuarios autenticados
CREATE POLICY "Usuarios pueden eliminar productos" ON productos
    FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar presentaciones" ON presentaciones
    FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar compras" ON compras
    FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar ventas" ON ventas
    FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden eliminar gastos" ON gastos
    FOR DELETE USING (auth.role() = 'authenticated');

-- Política para perfiles: los usuarios pueden ver y actualizar su propio perfil
CREATE POLICY "Usuarios pueden ver perfiles" ON perfiles_usuario
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden actualizar su perfil" ON perfiles_usuario
    FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista: Productos con inventario actual
CREATE OR REPLACE VIEW vista_productos_inventario AS
SELECT 
    p.id,
    p.nombre,
    p.marca,
    p.unidad_medida,
    COALESCE(i.cantidad_disponible, 0) as stock_actual,
    COALESCE(i.costo_promedio_usd, 0) as costo_promedio,
    p.activo
FROM productos p
LEFT JOIN inventario i ON p.id = i.producto_id;

-- Vista: Resumen de ventas por producto
CREATE OR REPLACE VIEW vista_ventas_por_producto AS
SELECT 
    p.id as producto_id,
    p.nombre,
    p.marca,
    COUNT(DISTINCT v.id) as total_ventas,
    SUM(vd.cantidad) as unidades_vendidas,
    SUM(vd.subtotal_colones) as total_colones,
    AVG(vd.margen_porcentaje) as margen_promedio
FROM productos p
JOIN presentaciones pr ON p.id = pr.producto_id
JOIN ventas_detalle vd ON pr.id = vd.presentacion_id
JOIN ventas v ON vd.venta_id = v.id
GROUP BY p.id, p.nombre, p.marca;

-- Vista: Gastos mensuales
CREATE OR REPLACE VIEW vista_gastos_mensuales AS
SELECT 
    DATE_TRUNC('month', fecha) as mes,
    tipo,
    categoria,
    SUM(monto_usd) as total_usd
FROM gastos
WHERE activo = true
GROUP BY DATE_TRUNC('month', fecha), tipo, categoria
ORDER BY mes DESC;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
