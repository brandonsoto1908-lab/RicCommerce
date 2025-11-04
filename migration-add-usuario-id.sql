-- =========================================
-- MIGRACIÓN: AGREGAR USUARIO_ID A TABLAS
-- Convierte el sistema en multi-tenant
-- =========================================

DO $$
BEGIN
  RAISE NOTICE '🚀 INICIANDO MIGRACIÓN A MULTI-TENANT...';

  -- =====================================
  -- 1. TABLA PRODUCTOS
  -- =====================================
  RAISE NOTICE '📦 Migrando tabla productos...';
  
  -- Agregar columna usuario_id
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'productos' AND column_name = 'usuario_id'
  ) THEN
    ALTER TABLE productos 
    ADD COLUMN usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '  ✅ Columna usuario_id agregada';
  ELSE
    RAISE NOTICE '  ⚠️  Columna usuario_id ya existe';
  END IF;

  -- Eliminar constraint de unicidad global
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'productos_nombre_marca_key'
  ) THEN
    ALTER TABLE productos DROP CONSTRAINT productos_nombre_marca_key;
    RAISE NOTICE '  ✅ Constraint global eliminado';
  END IF;

  -- Agregar constraint de unicidad por usuario
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'productos_usuario_nombre_marca_key'
  ) THEN
    ALTER TABLE productos 
    ADD CONSTRAINT productos_usuario_nombre_marca_key 
    UNIQUE(usuario_id, nombre, marca);
    RAISE NOTICE '  ✅ Constraint por usuario agregado';
  END IF;

  -- Crear índice para performance
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_productos_usuario_id'
  ) THEN
    CREATE INDEX idx_productos_usuario_id ON productos(usuario_id);
    RAISE NOTICE '  ✅ Índice creado';
  END IF;

  -- =====================================
  -- 2. TABLA PRESENTACIONES
  -- =====================================
  RAISE NOTICE '📋 Migrando tabla presentaciones...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'presentaciones' AND column_name = 'usuario_id'
  ) THEN
    ALTER TABLE presentaciones 
    ADD COLUMN usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '  ✅ Columna usuario_id agregada';
  ELSE
    RAISE NOTICE '  ⚠️  Columna usuario_id ya existe';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_presentaciones_usuario_id'
  ) THEN
    CREATE INDEX idx_presentaciones_usuario_id ON presentaciones(usuario_id);
    RAISE NOTICE '  ✅ Índice creado';
  END IF;

  -- =====================================
  -- 3. TABLA INVENTARIO
  -- =====================================
  RAISE NOTICE '📊 Migrando tabla inventario...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'inventario' AND column_name = 'usuario_id'
  ) THEN
    ALTER TABLE inventario 
    ADD COLUMN usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '  ✅ Columna usuario_id agregada';
  ELSE
    RAISE NOTICE '  ⚠️  Columna usuario_id ya existe';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'idx_inventario_usuario_id'
  ) THEN
    CREATE INDEX idx_inventario_usuario_id ON inventario(usuario_id);
    RAISE NOTICE '  ✅ Índice creado';
  END IF;

  -- =====================================
  -- 4. POLÍTICAS RLS - PRODUCTOS
  -- =====================================
  RAISE NOTICE '🔒 Configurando RLS para productos...';
  
  -- Habilitar RLS
  ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
  
  -- Eliminar políticas antiguas si existen
  DROP POLICY IF EXISTS productos_isolation_select ON productos;
  DROP POLICY IF EXISTS productos_isolation_insert ON productos;
  DROP POLICY IF EXISTS productos_isolation_update ON productos;
  DROP POLICY IF EXISTS productos_isolation_delete ON productos;
  
  -- Crear nuevas políticas
  CREATE POLICY productos_isolation_select ON productos
    FOR SELECT
    USING (usuario_id = auth.uid());
  
  CREATE POLICY productos_isolation_insert ON productos
    FOR INSERT
    WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY productos_isolation_update ON productos
    FOR UPDATE
    USING (usuario_id = auth.uid())
    WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY productos_isolation_delete ON productos
    FOR DELETE
    USING (usuario_id = auth.uid());
  
  RAISE NOTICE '  ✅ Políticas RLS configuradas';

  -- =====================================
  -- 5. POLÍTICAS RLS - PRESENTACIONES
  -- =====================================
  RAISE NOTICE '🔒 Configurando RLS para presentaciones...';
  
  ALTER TABLE presentaciones ENABLE ROW LEVEL SECURITY;
  
  DROP POLICY IF EXISTS presentaciones_isolation_select ON presentaciones;
  DROP POLICY IF EXISTS presentaciones_isolation_insert ON presentaciones;
  DROP POLICY IF EXISTS presentaciones_isolation_update ON presentaciones;
  DROP POLICY IF EXISTS presentaciones_isolation_delete ON presentaciones;
  
  CREATE POLICY presentaciones_isolation_select ON presentaciones
    FOR SELECT
    USING (usuario_id = auth.uid());
  
  CREATE POLICY presentaciones_isolation_insert ON presentaciones
    FOR INSERT
    WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY presentaciones_isolation_update ON presentaciones
    FOR UPDATE
    USING (usuario_id = auth.uid())
    WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY presentaciones_isolation_delete ON presentaciones
    FOR DELETE
    USING (usuario_id = auth.uid());
  
  RAISE NOTICE '  ✅ Políticas RLS configuradas';

  -- =====================================
  -- 6. POLÍTICAS RLS - INVENTARIO
  -- =====================================
  RAISE NOTICE '🔒 Configurando RLS para inventario...';
  
  ALTER TABLE inventario ENABLE ROW LEVEL SECURITY;
  
  DROP POLICY IF EXISTS inventario_isolation_select ON inventario;
  DROP POLICY IF EXISTS inventario_isolation_insert ON inventario;
  DROP POLICY IF EXISTS inventario_isolation_update ON inventario;
  DROP POLICY IF EXISTS inventario_isolation_delete ON inventario;
  
  CREATE POLICY inventario_isolation_select ON inventario
    FOR SELECT
    USING (usuario_id = auth.uid());
  
  CREATE POLICY inventario_isolation_insert ON inventario
    FOR INSERT
    WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY inventario_isolation_update ON inventario
    FOR UPDATE
    USING (usuario_id = auth.uid())
    WITH CHECK (usuario_id = auth.uid());
  
  CREATE POLICY inventario_isolation_delete ON inventario
    FOR DELETE
    USING (usuario_id = auth.uid());
  
  RAISE NOTICE '  ✅ Políticas RLS configuradas';

  RAISE NOTICE '🎉 MIGRACIÓN COMPLETADA EXITOSAMENTE';
  RAISE NOTICE '✅ Sistema ahora es multi-tenant';
  RAISE NOTICE '✅ Cada usuario tiene sus propios productos';
  
END $$;

-- Verificar configuración
SELECT 
  tablename, 
  policyname, 
  cmd, 
  qual
FROM pg_policies
WHERE tablename IN ('productos', 'presentaciones', 'inventario')
ORDER BY tablename, policyname;
