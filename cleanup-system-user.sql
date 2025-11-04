-- =========================================
-- LIMPIEZA: ELIMINAR DATOS DE system@stonebyric.com
-- =========================================
-- 
-- Este script elimina TODOS los datos del usuario system@stonebyric.com
-- para poder insertar datos nuevos con precios actualizados
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
  RAISE NOTICE '🧹 LIMPIANDO DATOS DE SYSTEM@STONEBYRIC.COM';
  RAISE NOTICE '═══════════════════════════════════════════════════';

  -- Obtener ID del usuario
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'system@stonebyric.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuario system@stonebyric.com no encontrado';
  END IF;
  
  RAISE NOTICE '✅ Usuario encontrado: %', v_user_id;
  RAISE NOTICE '';
  RAISE NOTICE '🗑️  Eliminando datos antiguos...';

  -- Eliminar en orden correcto (respetando foreign keys)
  
  DELETE FROM compras_detalle
  WHERE compra_id IN (SELECT id FROM compras WHERE usuario_id = v_user_id);
  GET DIAGNOSTICS v_detalle_eliminado = ROW_COUNT;
  RAISE NOTICE '  ✅ compras_detalle eliminados: %', v_detalle_eliminado;
  
  DELETE FROM compras WHERE usuario_id = v_user_id;
  GET DIAGNOSTICS v_compras_eliminadas = ROW_COUNT;
  RAISE NOTICE '  ✅ compras eliminadas: %', v_compras_eliminadas;
  
  DELETE FROM movimientos_inventario WHERE usuario_id = v_user_id;
  RAISE NOTICE '  ✅ movimientos_inventario limpiado';
  
  DELETE FROM inventario WHERE usuario_id = v_user_id;
  RAISE NOTICE '  ✅ inventario limpiado';
  
  DELETE FROM presentaciones WHERE usuario_id = v_user_id;
  RAISE NOTICE '  ✅ presentaciones limpiado';
  
  DELETE FROM productos WHERE usuario_id = v_user_id;
  GET DIAGNOSTICS v_productos_eliminados = ROW_COUNT;
  RAISE NOTICE '  ✅ productos eliminados: %', v_productos_eliminados;

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
  RAISE NOTICE '✅ Listo para insertar datos nuevos';
  RAISE NOTICE '   Ejecuta: seed-productos-system-MULTITENANT.sql';
  
END $$;

COMMIT;

-- Verificar que está limpio
SELECT 
  'system@stonebyric.com' as usuario,
  COUNT(*) as productos_restantes
FROM productos p
JOIN auth.users u ON u.id = p.usuario_id
WHERE u.email = 'system@stonebyric.com';
