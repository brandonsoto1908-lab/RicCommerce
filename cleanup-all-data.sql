-- =========================================
-- SCRIPT DE LIMPIEZA COMPLETA
-- Elimina TODOS los datos de TODAS las tablas
-- =========================================

-- ADVERTENCIA: Este script eliminará TODOS los datos
-- Ejecuta solo si estás seguro

DO $$
BEGIN
  RAISE NOTICE '⚠️  INICIANDO LIMPIEZA COMPLETA DE DATOS...';

  -- Eliminar en orden correcto (respetando foreign keys)
  
  -- 1. Eliminar detalles primero
  DELETE FROM ventas_detalle;
  RAISE NOTICE '✅ ventas_detalle limpiado';
  
  DELETE FROM compras_detalle;
  RAISE NOTICE '✅ compras_detalle limpiado';
  
  -- 2. Eliminar cabeceras
  DELETE FROM ventas;
  RAISE NOTICE '✅ ventas limpiado';
  
  DELETE FROM compras;
  RAISE NOTICE '✅ compras limpiado';
  
  -- 3. Eliminar gastos
  DELETE FROM gastos;
  RAISE NOTICE '✅ gastos limpiado';
  
  -- 4. Eliminar movimientos e inventario
  DELETE FROM movimientos_inventario;
  RAISE NOTICE '✅ movimientos_inventario limpiado';
  
  DELETE FROM inventario;
  RAISE NOTICE '✅ inventario limpiado';
  
  -- 5. Eliminar presentaciones
  DELETE FROM presentaciones;
  RAISE NOTICE '✅ presentaciones limpiado';
  
  -- 6. Eliminar productos
  DELETE FROM productos;
  RAISE NOTICE '✅ productos limpiado';
  
  -- 7. Eliminar historial de precios (si existe)
  DELETE FROM historial_precios;
  RAISE NOTICE '✅ historial_precios limpiado';

  RAISE NOTICE '🎉 LIMPIEZA COMPLETA FINALIZADA';
  RAISE NOTICE '📊 Todas las tablas han sido vaciadas';
  
END $$;

-- Verificar que todo está vacío
SELECT 
  'productos' as tabla, COUNT(*) as registros FROM productos
UNION ALL
SELECT 'presentaciones', COUNT(*) FROM presentaciones
UNION ALL
SELECT 'compras', COUNT(*) FROM compras
UNION ALL
SELECT 'compras_detalle', COUNT(*) FROM compras_detalle
UNION ALL
SELECT 'ventas', COUNT(*) FROM ventas
UNION ALL
SELECT 'ventas_detalle', COUNT(*) FROM ventas_detalle
UNION ALL
SELECT 'gastos', COUNT(*) FROM gastos
UNION ALL
SELECT 'inventario', COUNT(*) FROM inventario
UNION ALL
SELECT 'movimientos_inventario', COUNT(*) FROM movimientos_inventario;
