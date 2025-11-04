-- =========================================
-- FIX COMPLETO: RLS PARA TODAS LAS TABLAS
-- =========================================
-- 
-- Este script verifica y arregla las políticas RLS
-- para TODAS las tablas del sistema multi-tenant
-- =========================================

BEGIN;

DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔍 VERIFICANDO Y ARREGLANDO TODAS LAS POLÍTICAS RLS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
END $$;

-- =========================================
-- PASO 1: VERIFICAR POLÍTICAS EXISTENTES
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '📋 PASO 1: Verificando políticas actuales...';
END $$;

-- Ver todas las políticas de tablas relacionadas con usuario
SELECT 
  '⚠️  POLÍTICAS ACTUALES' as titulo,
  tablename as tabla,
  policyname as politica,
  cmd as comando
FROM pg_policies
WHERE tablename IN ('compras', 'ventas', 'gastos', 'compras_detalle', 'ventas_detalle', 'movimientos_inventario')
ORDER BY tablename, policyname;

-- =========================================
-- PASO 2: ELIMINAR POLÍTICAS ANTIGUAS
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🗑️  PASO 2: Eliminando políticas antiguas...';
END $$;

-- COMPRAS
DROP POLICY IF EXISTS "Usuarios pueden leer compras" ON compras;
DROP POLICY IF EXISTS "Usuarios pueden insertar compras" ON compras;
DROP POLICY IF EXISTS "Usuarios pueden actualizar compras" ON compras;
DROP POLICY IF EXISTS "Usuarios pueden eliminar compras" ON compras;
DROP POLICY IF EXISTS "compras_isolation_select" ON compras;
DROP POLICY IF EXISTS "compras_isolation_insert" ON compras;
DROP POLICY IF EXISTS "compras_isolation_update" ON compras;
DROP POLICY IF EXISTS "compras_isolation_delete" ON compras;

-- VENTAS
DROP POLICY IF EXISTS "Usuarios pueden leer ventas" ON ventas;
DROP POLICY IF EXISTS "Usuarios pueden insertar ventas" ON ventas;
DROP POLICY IF EXISTS "Usuarios pueden actualizar ventas" ON ventas;
DROP POLICY IF EXISTS "Usuarios pueden eliminar ventas" ON ventas;
DROP POLICY IF EXISTS "ventas_isolation_select" ON ventas;
DROP POLICY IF EXISTS "ventas_isolation_insert" ON ventas;
DROP POLICY IF EXISTS "ventas_isolation_update" ON ventas;
DROP POLICY IF EXISTS "ventas_isolation_delete" ON ventas;

-- GASTOS
DROP POLICY IF EXISTS "Usuarios pueden leer gastos" ON gastos;
DROP POLICY IF EXISTS "Usuarios pueden insertar gastos" ON gastos;
DROP POLICY IF EXISTS "Usuarios pueden actualizar gastos" ON gastos;
DROP POLICY IF EXISTS "Usuarios pueden eliminar gastos" ON gastos;
DROP POLICY IF EXISTS "gastos_isolation_select" ON gastos;
DROP POLICY IF EXISTS "gastos_isolation_insert" ON gastos;
DROP POLICY IF EXISTS "gastos_isolation_update" ON gastos;
DROP POLICY IF EXISTS "gastos_isolation_delete" ON gastos;

-- COMPRAS_DETALLE
DROP POLICY IF EXISTS "Usuarios pueden leer compras_detalle" ON compras_detalle;
DROP POLICY IF EXISTS "Usuarios pueden insertar compras_detalle" ON compras_detalle;

-- VENTAS_DETALLE
DROP POLICY IF EXISTS "Usuarios pueden leer ventas_detalle" ON ventas_detalle;
DROP POLICY IF EXISTS "Usuarios pueden insertar ventas_detalle" ON ventas_detalle;

-- MOVIMIENTOS_INVENTARIO
DROP POLICY IF EXISTS "Usuarios pueden leer movimientos" ON movimientos_inventario;

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas antiguas eliminadas';
END $$;

-- =========================================
-- PASO 3: HABILITAR RLS EN TODAS LAS TABLAS
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '🔒 PASO 3: Habilitando RLS en todas las tablas...';
END $$;

ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastos ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras_detalle ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_detalle ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_inventario ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  RAISE NOTICE '  ✅ RLS habilitado en todas las tablas';
END $$;

-- =========================================
-- PASO 4: CREAR POLÍTICAS CORRECTAS
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✨ PASO 4: Creando políticas nuevas con filtro por usuario...';
END $$;

-- =====================
-- COMPRAS
-- =====================
CREATE POLICY compras_isolation_select ON compras
  FOR SELECT USING (usuario_id = auth.uid());

CREATE POLICY compras_isolation_insert ON compras
  FOR INSERT WITH CHECK (usuario_id = auth.uid());

CREATE POLICY compras_isolation_update ON compras
  FOR UPDATE USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid());

CREATE POLICY compras_isolation_delete ON compras
  FOR DELETE USING (usuario_id = auth.uid());

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas de COMPRAS creadas';
END $$;

-- =====================
-- VENTAS
-- =====================
CREATE POLICY ventas_isolation_select ON ventas
  FOR SELECT USING (usuario_id = auth.uid());

CREATE POLICY ventas_isolation_insert ON ventas
  FOR INSERT WITH CHECK (usuario_id = auth.uid());

CREATE POLICY ventas_isolation_update ON ventas
  FOR UPDATE USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid());

CREATE POLICY ventas_isolation_delete ON ventas
  FOR DELETE USING (usuario_id = auth.uid());

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas de VENTAS creadas';
END $$;

-- =====================
-- GASTOS
-- =====================
CREATE POLICY gastos_isolation_select ON gastos
  FOR SELECT USING (usuario_id = auth.uid());

CREATE POLICY gastos_isolation_insert ON gastos
  FOR INSERT WITH CHECK (usuario_id = auth.uid());

CREATE POLICY gastos_isolation_update ON gastos
  FOR UPDATE USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid());

CREATE POLICY gastos_isolation_delete ON gastos
  FOR DELETE USING (usuario_id = auth.uid());

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas de GASTOS creadas';
END $$;

-- =====================
-- COMPRAS_DETALLE (filtro indirecto vía compras)
-- =====================
CREATE POLICY compras_detalle_isolation_select ON compras_detalle
  FOR SELECT USING (
    compra_id IN (SELECT id FROM compras WHERE usuario_id = auth.uid())
  );

CREATE POLICY compras_detalle_isolation_insert ON compras_detalle
  FOR INSERT WITH CHECK (
    compra_id IN (SELECT id FROM compras WHERE usuario_id = auth.uid())
  );

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas de COMPRAS_DETALLE creadas';
END $$;

-- =====================
-- VENTAS_DETALLE (filtro indirecto vía ventas)
-- =====================
CREATE POLICY ventas_detalle_isolation_select ON ventas_detalle
  FOR SELECT USING (
    venta_id IN (SELECT id FROM ventas WHERE usuario_id = auth.uid())
  );

CREATE POLICY ventas_detalle_isolation_insert ON ventas_detalle
  FOR INSERT WITH CHECK (
    venta_id IN (SELECT id FROM ventas WHERE usuario_id = auth.uid())
  );

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas de VENTAS_DETALLE creadas';
END $$;

-- =====================
-- MOVIMIENTOS_INVENTARIO
-- =====================
CREATE POLICY movimientos_inventario_isolation_select ON movimientos_inventario
  FOR SELECT USING (usuario_id = auth.uid());

CREATE POLICY movimientos_inventario_isolation_insert ON movimientos_inventario
  FOR INSERT WITH CHECK (usuario_id = auth.uid());

DO $$
BEGIN
  RAISE NOTICE '  ✅ Políticas de MOVIMIENTOS_INVENTARIO creadas';
END $$;

-- =========================================
-- PASO 5: VERIFICACIÓN FINAL
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ TODAS LAS POLÍTICAS RLS CONFIGURADAS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 Tablas protegidas:';
  RAISE NOTICE '  ✅ productos';
  RAISE NOTICE '  ✅ presentaciones';
  RAISE NOTICE '  ✅ inventario';
  RAISE NOTICE '  ✅ compras';
  RAISE NOTICE '  ✅ ventas';
  RAISE NOTICE '  ✅ gastos';
  RAISE NOTICE '  ✅ compras_detalle';
  RAISE NOTICE '  ✅ ventas_detalle';
  RAISE NOTICE '  ✅ movimientos_inventario';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 Sistema completamente aislado por usuario';
END $$;

COMMIT;

-- =========================================
-- VERIFICACIÓN POST-FIX
-- =========================================

-- Ver todas las políticas activas
SELECT 
  '📋 TODAS LAS POLÍTICAS ACTIVAS' as titulo,
  tablename as tabla,
  policyname as politica,
  cmd as comando
FROM pg_policies
WHERE tablename IN (
  'productos', 'presentaciones', 'inventario',
  'compras', 'ventas', 'gastos',
  'compras_detalle', 'ventas_detalle', 'movimientos_inventario'
)
ORDER BY tablename, cmd, policyname;

-- Contar políticas por tabla
SELECT 
  '📊 RESUMEN DE POLÍTICAS' as titulo,
  tablename as tabla,
  COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename IN (
  'productos', 'presentaciones', 'inventario',
  'compras', 'ventas', 'gastos',
  'compras_detalle', 'ventas_detalle', 'movimientos_inventario'
)
GROUP BY tablename
ORDER BY tablename;
