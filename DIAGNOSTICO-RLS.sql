-- =========================================
-- DIAGNÓSTICO: VERIFICAR POLÍTICAS RLS
-- =========================================
-- 
-- Este script verifica si las políticas RLS están
-- correctamente configuradas y activas
-- =========================================

-- 1. Verificar que RLS está habilitado
SELECT 
  '🔒 VERIFICACIÓN RLS' as titulo,
  tablename as tabla,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('productos', 'presentaciones', 'inventario')
ORDER BY tablename;

-- 2. Verificar políticas existentes
SELECT 
  '📋 POLÍTICAS ACTIVAS' as titulo,
  schemaname as schema,
  tablename as tabla,
  policyname as politica,
  permissive as tipo,
  roles as roles,
  cmd as comando
FROM pg_policies
WHERE tablename IN ('productos', 'presentaciones', 'inventario')
ORDER BY tablename, policyname;

-- 3. Probar políticas con un usuario específico
-- Reemplaza 'USUARIO_ID_AQUI' con un UUID real de auth.users
DO $$
DECLARE
  v_brandon_id UUID;
  v_ric_id UUID;
  v_system_id UUID;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '👥 VERIFICANDO USUARIOS';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  
  -- Obtener IDs de usuarios
  SELECT id INTO v_brandon_id FROM auth.users WHERE email = 'brandonsoto1908@gmail.com';
  SELECT id INTO v_ric_id FROM auth.users WHERE email = 'ric@stonebyric.com';
  SELECT id INTO v_system_id FROM auth.users WHERE email = 'system@stonebyric.com';
  
  IF v_brandon_id IS NOT NULL THEN
    RAISE NOTICE '✅ Brandon: %', v_brandon_id;
  ELSE
    RAISE NOTICE '❌ Brandon: NO ENCONTRADO';
  END IF;
  
  IF v_ric_id IS NOT NULL THEN
    RAISE NOTICE '✅ Ric: %', v_ric_id;
  ELSE
    RAISE NOTICE '❌ Ric: NO ENCONTRADO';
  END IF;
  
  IF v_system_id IS NOT NULL THEN
    RAISE NOTICE '✅ System: %', v_system_id;
  ELSE
    RAISE NOTICE '❌ System: NO ENCONTRADO';
  END IF;
END $$;

-- 4. Verificar productos por usuario
SELECT 
  '📦 PRODUCTOS POR USUARIO' as titulo,
  u.email,
  COUNT(p.id) as total_productos
FROM auth.users u
LEFT JOIN productos p ON p.usuario_id = u.id
WHERE u.email IN ('brandonsoto1908@gmail.com', 'ric@stonebyric.com', 'system@stonebyric.com')
GROUP BY u.id, u.email
ORDER BY u.email;

-- 5. Verificar que cada producto tiene usuario_id
SELECT 
  '⚠️  PRODUCTOS SIN USUARIO_ID' as titulo,
  COUNT(*) as total
FROM productos
WHERE usuario_id IS NULL;

-- 6. Verificar que las políticas usan auth.uid()
SELECT 
  '🔍 DEFINICIÓN DE POLÍTICAS' as titulo,
  c.relname as tabla,
  p.polname as politica,
  CASE 
    WHEN pg_get_expr(p.polqual, p.polrelid) LIKE '%auth.uid()%' THEN '✅ Usa auth.uid()'
    ELSE '❌ NO usa auth.uid()'
  END as usa_auth_uid,
  pg_get_expr(p.polqual, p.polrelid) as condicion
FROM pg_policy p
JOIN pg_class c ON p.polrelid = c.oid
WHERE c.relname IN ('productos', 'presentaciones', 'inventario')
ORDER BY c.relname, p.polname;
