-- =========================================
-- SCRIPT DE LIMPIEZA: ELIMINAR DUPLICADOS
-- =========================================
-- 
-- Este script elimina TODOS los datos de system@stonebyric.com
-- porque se insertaron múltiples veces por error
-- 
-- EJECUTA ESTE SCRIPT PRIMERO para limpiar los duplicados
-- =========================================

BEGIN;

DO $$
DECLARE
  v_user_id UUID;
  v_productos_eliminados INTEGER;
  v_compras_eliminadas INTEGER;
  v_detalle_eliminado INTEGER;
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🧹 LIMPIANDO DATOS DUPLICADOS DE SYSTEM@STONEBYRIC.COM';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  -- Buscar el usuario
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'system@stonebyric.com';
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️  Usuario system@stonebyric.com NO encontrado en auth.users';
    RAISE NOTICE '⚠️  Esto significa que los datos se insertaron SIN usuario_id válido';
    RAISE NOTICE '';
    RAISE NOTICE '🔍 Buscando productos sin usuario_id o con usuario_id inválido...';
    
    -- Eliminar datos que NO tienen usuario válido
    -- (productos que NO pertenecen a brandon o ric)
    DELETE FROM compras_detalle
    WHERE compra_id IN (
      SELECT id FROM compras 
      WHERE usuario_id NOT IN (
        SELECT id FROM auth.users WHERE email IN ('brandonsoto1908@gmail.com', 'ric@stonebyric.com')
      )
    );
    GET DIAGNOSTICS v_detalle_eliminado = ROW_COUNT;
    RAISE NOTICE '  ✅ compras_detalle eliminados: %', v_detalle_eliminado;
    
    DELETE FROM compras
    WHERE usuario_id NOT IN (
      SELECT id FROM auth.users WHERE email IN ('brandonsoto1908@gmail.com', 'ric@stonebyric.com')
    );
    GET DIAGNOSTICS v_compras_eliminadas = ROW_COUNT;
    RAISE NOTICE '  ✅ compras eliminadas: %', v_compras_eliminadas;
    
    DELETE FROM inventario
    WHERE usuario_id NOT IN (
      SELECT id FROM auth.users WHERE email IN ('brandonsoto1908@gmail.com', 'ric@stonebyric.com')
    );
    RAISE NOTICE '  ✅ inventario limpiado';
    
    DELETE FROM productos
    WHERE usuario_id NOT IN (
      SELECT id FROM auth.users WHERE email IN ('brandonsoto1908@gmail.com', 'ric@stonebyric.com')
    );
    GET DIAGNOSTICS v_productos_eliminados = ROW_COUNT;
    RAISE NOTICE '  ✅ productos eliminados: %', v_productos_eliminados;
    
  ELSE
    RAISE NOTICE '✅ Usuario encontrado: system@stonebyric.com';
    RAISE NOTICE '📧 Usuario ID: %', v_user_id;
    RAISE NOTICE '';
    RAISE NOTICE '🗑️  Eliminando TODOS los datos de este usuario...';
    
    -- Eliminar datos del usuario system@stonebyric.com
    DELETE FROM compras_detalle
    WHERE compra_id IN (SELECT id FROM compras WHERE usuario_id = v_user_id);
    GET DIAGNOSTICS v_detalle_eliminado = ROW_COUNT;
    RAISE NOTICE '  ✅ compras_detalle eliminados: %', v_detalle_eliminado;
    
    DELETE FROM compras WHERE usuario_id = v_user_id;
    GET DIAGNOSTICS v_compras_eliminadas = ROW_COUNT;
    RAISE NOTICE '  ✅ compras eliminadas: %', v_compras_eliminadas;
    
    DELETE FROM inventario WHERE usuario_id = v_user_id;
    RAISE NOTICE '  ✅ inventario limpiado';
    
    DELETE FROM movimientos_inventario WHERE usuario_id = v_user_id;
    RAISE NOTICE '  ✅ movimientos_inventario limpiado';
    
    DELETE FROM productos WHERE usuario_id = v_user_id;
    GET DIAGNOSTICS v_productos_eliminados = ROW_COUNT;
    RAISE NOTICE '  ✅ productos eliminados: %', v_productos_eliminados;
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '✅ LIMPIEZA COMPLETADA';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📊 RESUMEN:';
  RAISE NOTICE '  • Productos eliminados: %', v_productos_eliminados;
  RAISE NOTICE '  • Compras eliminadas: %', v_compras_eliminadas;
  RAISE NOTICE '  • Detalles eliminados: %', v_detalle_eliminado;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  IMPORTANTE:';
  RAISE NOTICE '  1. El usuario system@stonebyric.com DEBE existir en Authentication';
  RAISE NOTICE '  2. Ve a Dashboard > Authentication > Users';
  RAISE NOTICE '  3. Crea el usuario manualmente si no existe';
  RAISE NOTICE '  4. Luego ejecuta seed-productos-system-MULTITENANT.sql';
  
END $$;

COMMIT;

-- =========================================
-- VERIFICACIÓN POST-LIMPIEZA
-- =========================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════';
  RAISE NOTICE '🔍 VERIFICANDO ESTADO ACTUAL';
  RAISE NOTICE '═══════════════════════════════════════════════════';
END $$;

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
  'inventario',
  COUNT(*),
  COUNT(DISTINCT usuario_id)
FROM inventario;

-- Detalle por usuario
SELECT 
  '👤 PRODUCTOS POR USUARIO' as info,
  (SELECT email FROM auth.users WHERE id = productos.usuario_id) as usuario,
  COUNT(*) as total_productos
FROM productos
GROUP BY usuario_id
ORDER BY usuario;
