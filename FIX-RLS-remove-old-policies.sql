-- =========================================
-- FIX: ELIMINAR POLÍTICAS ANTIGUAS
-- =========================================
-- 
-- Este script elimina las políticas RLS ANTIGUAS que estaban
-- permitiendo ver TODOS los datos sin filtro por usuario.
-- 
-- Las políticas _isolation_ son las correctas y las mantendremos.
-- =========================================

BEGIN;

DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🗑️  ELIMINANDO POLÍTICAS ANTIGUAS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Problema encontrado: Políticas duplicadas';
  RAISE NOTICE '   Las políticas antiguas permiten ver TODOS los datos';
  RAISE NOTICE '   Las políticas _isolation_ filtran correctamente por usuario';
  RAISE NOTICE '';
END $$;

-- =========================================
-- PRODUCTOS: Eliminar políticas antiguas
-- =========================================
DROP POLICY IF EXISTS "Usuarios pueden leer productos" ON productos;
DROP POLICY IF EXISTS "Usuarios pueden insertar productos" ON productos;
DROP POLICY IF EXISTS "Usuarios pueden actualizar productos" ON productos;
DROP POLICY IF EXISTS "Usuarios pueden eliminar productos" ON productos;

DO $$
BEGIN
  RAISE NOTICE '✅ Políticas antiguas de productos eliminadas';
END $$;

-- =========================================
-- PRESENTACIONES: Eliminar políticas antiguas
-- =========================================
DROP POLICY IF EXISTS "Usuarios pueden leer presentaciones" ON presentaciones;
DROP POLICY IF EXISTS "Usuarios pueden insertar presentaciones" ON presentaciones;
DROP POLICY IF EXISTS "Usuarios pueden actualizar presentaciones" ON presentaciones;
DROP POLICY IF EXISTS "Usuarios pueden eliminar presentaciones" ON presentaciones;

DO $$
BEGIN
  RAISE NOTICE '✅ Políticas antiguas de presentaciones eliminadas';
END $$;

-- =========================================
-- INVENTARIO: Eliminar políticas antiguas
-- =========================================
DROP POLICY IF EXISTS "Usuarios pueden leer inventario" ON inventario;
DROP POLICY IF EXISTS "Usuarios pueden insertar inventario" ON inventario;
DROP POLICY IF EXISTS "Sistema puede actualizar inventario" ON inventario;

DO $$
BEGIN
  RAISE NOTICE '✅ Políticas antiguas de inventario eliminadas';
END $$;

-- =========================================
-- VERIFICAR: Solo deben quedar las políticas _isolation_
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ POLÍTICAS ANTIGUAS ELIMINADAS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 Ahora solo las políticas _isolation_ están activas';
  RAISE NOTICE '   Cada usuario verá ÚNICAMENTE sus propios datos';
  RAISE NOTICE '';
END $$;

COMMIT;

-- =========================================
-- VERIFICACIÓN POST-FIX
-- =========================================

SELECT 
  '📋 POLÍTICAS RESTANTES' as titulo,
  tablename as tabla,
  policyname as politica,
  cmd as comando
FROM pg_policies
WHERE tablename IN ('productos', 'presentaciones', 'inventario')
ORDER BY tablename, policyname;

-- Verificar que todas usan auth.uid()
SELECT 
  '✅ VERIFICACIÓN FINAL' as titulo,
  c.relname as tabla,
  p.polname as politica,
  CASE 
    WHEN pg_get_expr(p.polqual, p.polrelid) LIKE '%auth.uid()%' THEN '✅ Usa auth.uid()'
    WHEN pg_get_expr(p.polqual, p.polrelid) IS NULL THEN '⚠️  Sin condición (WITH CHECK)'
    ELSE '❌ NO usa auth.uid()'
  END as estado
FROM pg_policy p
JOIN pg_class c ON p.polrelid = c.oid
WHERE c.relname IN ('productos', 'presentaciones', 'inventario')
ORDER BY c.relname, p.polname;
