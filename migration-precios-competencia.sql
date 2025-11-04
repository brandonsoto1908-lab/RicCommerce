-- =========================================
-- MIGRACIÓN: MÓDULO DE PRECIOS DE COMPETENCIA
-- =========================================
-- Este módulo permite registrar y comparar precios
-- de productos de la competencia (Walmart, PriceSmart, etc.)
-- =========================================

BEGIN;

-- ============================================
-- PASO 1: CREAR TABLA precios_competencia
-- ============================================

CREATE TABLE IF NOT EXISTS precios_competencia (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Información del producto de competencia
  marca VARCHAR(100) NOT NULL,
  producto TEXT NOT NULL,
  precio_crc DECIMAL(12, 2) NOT NULL,
  precio_usd DECIMAL(12, 2) NOT NULL,
  
  -- Cantidad y unidad (ej: "9474 ml", "694 g")
  cantidad DECIMAL(12, 2) NOT NULL,
  unidad_medida VARCHAR(50) NOT NULL, -- litros, mililitros, gramos, kilogramos, unidades
  
  -- Distribuidor/Retailer
  distribuidor VARCHAR(100) NOT NULL, -- WALMART, PRICESMART, etc.
  
  -- Categoría del producto (para facilitar comparaciones)
  categoria VARCHAR(100), -- detergente, cloro, suavizante, etc.
  
  -- Metadata
  notas TEXT,
  activo BOOLEAN DEFAULT true,
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX idx_precios_competencia_usuario ON precios_competencia(usuario_id);
CREATE INDEX idx_precios_competencia_distribuidor ON precios_competencia(distribuidor);
CREATE INDEX idx_precios_competencia_categoria ON precios_competencia(categoria);
CREATE INDEX idx_precios_competencia_activo ON precios_competencia(activo);

-- ============================================
-- PASO 2: HABILITAR RLS (Row Level Security)
-- ============================================

ALTER TABLE precios_competencia ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 3: CREAR POLÍTICAS RLS
-- ============================================

-- DROP existing policies if any
DROP POLICY IF EXISTS "Usuarios pueden ver sus precios de competencia" ON precios_competencia;
DROP POLICY IF EXISTS "Usuarios pueden insertar sus precios de competencia" ON precios_competencia;
DROP POLICY IF EXISTS "Usuarios pueden actualizar sus precios de competencia" ON precios_competencia;
DROP POLICY IF EXISTS "Usuarios pueden eliminar sus precios de competencia" ON precios_competencia;

-- Policy: SELECT - Ver solo sus propios registros
CREATE POLICY "Usuarios pueden ver sus precios de competencia"
  ON precios_competencia
  FOR SELECT
  USING (usuario_id = auth.uid());

-- Policy: INSERT - Insertar con su propio usuario_id
CREATE POLICY "Usuarios pueden insertar sus precios de competencia"
  ON precios_competencia
  FOR INSERT
  WITH CHECK (usuario_id = auth.uid());

-- Policy: UPDATE - Actualizar solo sus propios registros
CREATE POLICY "Usuarios pueden actualizar sus precios de competencia"
  ON precios_competencia
  FOR UPDATE
  USING (usuario_id = auth.uid())
  WITH CHECK (usuario_id = auth.uid());

-- Policy: DELETE - Eliminar solo sus propios registros
CREATE POLICY "Usuarios pueden eliminar sus precios de competencia"
  ON precios_competencia
  FOR DELETE
  USING (usuario_id = auth.uid());

-- ============================================
-- PASO 4: CREAR TRIGGER PARA updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_precios_competencia_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_precios_competencia_updated_at
  BEFORE UPDATE ON precios_competencia
  FOR EACH ROW
  EXECUTE FUNCTION update_precios_competencia_updated_at();

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ Tabla precios_competencia creada exitosamente';
  RAISE NOTICE '✅ RLS habilitado';
  RAISE NOTICE '✅ 4 políticas RLS creadas';
  RAISE NOTICE '✅ Trigger updated_at configurado';
END $$;

-- Verificar políticas
SELECT 
  'precios_competencia' as tabla,
  COUNT(*) as total_politicas
FROM pg_policies 
WHERE tablename = 'precios_competencia';
