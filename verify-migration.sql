-- =========================================
-- SCRIPT DE VERIFICACIÓN POST-MIGRACIÓN
-- Ejecuta este script DESPUÉS de la migración
-- para verificar que todo está correcto
-- =========================================

-- =========================================
-- 1. VERIFICAR ESTRUCTURA DE TABLAS
-- =========================================
SELECT 
    '✅ VERIFICACIÓN 1: Estructura de Tablas' as verificacion,
    '' as resultado
UNION ALL
SELECT 
    '-----------------------------------',
    ''
UNION ALL
SELECT 
    'productos tiene usuario_id:',
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'productos' AND column_name = 'usuario_id'
        ) THEN '✅ SÍ'
        ELSE '❌ NO - EJECUTA migration-add-usuario-id.sql'
    END
UNION ALL
SELECT 
    'presentaciones tiene usuario_id:',
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'presentaciones' AND column_name = 'usuario_id'
        ) THEN '✅ SÍ'
        ELSE '❌ NO - EJECUTA migration-add-usuario-id.sql'
    END
UNION ALL
SELECT 
    'inventario tiene usuario_id:',
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'inventario' AND column_name = 'usuario_id'
        ) THEN '✅ SÍ'
        ELSE '❌ NO - EJECUTA migration-add-usuario-id.sql'
    END;

-- =========================================
-- 2. VERIFICAR POLÍTICAS RLS
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '✅ VERIFICACIÓN 2: Políticas RLS',
    ''
UNION ALL
SELECT 
    '-----------------------------------',
    ''
UNION ALL
SELECT 
    'Políticas en productos:',
    COUNT(*)::text || ' políticas' || 
    CASE 
        WHEN COUNT(*) = 4 THEN ' ✅'
        ELSE ' ❌ Deberían ser 4'
    END
FROM pg_policies
WHERE tablename = 'productos'
UNION ALL
SELECT 
    'Políticas en presentaciones:',
    COUNT(*)::text || ' políticas' || 
    CASE 
        WHEN COUNT(*) = 4 THEN ' ✅'
        ELSE ' ❌ Deberían ser 4'
    END
FROM pg_policies
WHERE tablename = 'presentaciones'
UNION ALL
SELECT 
    'Políticas en inventario:',
    COUNT(*)::text || ' políticas' || 
    CASE 
        WHEN COUNT(*) = 4 THEN ' ✅'
        ELSE ' ❌ Deberían ser 4'
    END
FROM pg_policies
WHERE tablename = 'inventario';

-- =========================================
-- 3. VERIFICAR DATOS POR USUARIO
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '✅ VERIFICACIÓN 3: Datos por Usuario',
    ''
UNION ALL
SELECT 
    '-----------------------------------',
    '';

-- Productos por usuario
SELECT 
    'Usuario: ' || COALESCE(u.email, 'SIN USUARIO_ID') as verificacion,
    'Productos: ' || COUNT(p.id)::text || 
    CASE 
        WHEN COUNT(p.id) = 0 THEN ' ❌ Sin datos - Ejecuta seeds'
        WHEN COUNT(p.id) = 7 THEN ' ✅'
        ELSE ' ⚠️  Cantidad inesperada'
    END as resultado
FROM productos p
LEFT JOIN auth.users u ON p.usuario_id = u.id
GROUP BY u.email
ORDER BY u.email;

-- =========================================
-- 4. VERIFICAR CONSTRAINT DE UNICIDAD
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '✅ VERIFICACIÓN 4: Constraints',
    ''
UNION ALL
SELECT 
    '-----------------------------------',
    ''
UNION ALL
SELECT 
    'Constraint por usuario en productos:',
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_constraint 
            WHERE conname = 'productos_usuario_nombre_marca_key'
        ) THEN '✅ SÍ'
        ELSE '❌ NO - EJECUTA migration-add-usuario-id.sql'
    END;

-- =========================================
-- 5. VERIFICAR INVERSIÓN TOTAL
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '✅ VERIFICACIÓN 5: Inversión por Usuario',
    ''
UNION ALL
SELECT 
    '-----------------------------------',
    '';

-- Inversión por usuario
SELECT 
    'Usuario: ' || COALESCE(u.email, 'DESCONOCIDO') as verificacion,
    'Inversión: $' || COALESCE(SUM(cd.subtotal_usd)::numeric(10,2)::text, '0.00') || ' USD' ||
    CASE u.email
        WHEN 'brandonsoto1908@gmail.com' THEN 
            CASE WHEN SUM(cd.subtotal_usd) = 2944.00 THEN ' ✅' ELSE ' ❌ Debería ser $2,944' END
        WHEN 'ric@stonebyric.com' THEN 
            CASE WHEN SUM(cd.subtotal_usd) = 9920.00 THEN ' ✅' ELSE ' ❌ Debería ser $9,920' END
        ELSE ''
    END as resultado
FROM productos p
LEFT JOIN auth.users u ON p.usuario_id = u.id
LEFT JOIN compras_detalle cd ON cd.producto_id = p.id
GROUP BY u.email
ORDER BY u.email;

-- =========================================
-- 6. VERIFICAR TRIGGERS
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '✅ VERIFICACIÓN 6: Triggers Activos',
    ''
UNION ALL
SELECT 
    '-----------------------------------',
    ''
UNION ALL
SELECT 
    'Trigger inventario compras:',
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_trigger 
            WHERE tgname = 'trigger_actualizar_inventario_compra'
        ) THEN '✅ ACTIVO'
        ELSE '❌ NO EXISTE'
    END
UNION ALL
SELECT 
    'Trigger inventario ventas:',
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_trigger 
            WHERE tgname = 'trigger_actualizar_inventario_venta'
        ) THEN '✅ ACTIVO'
        ELSE '❌ NO EXISTE'
    END;

-- =========================================
-- 7. RESUMEN DE PRODUCTOS
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '✅ VERIFICACIÓN 7: Detalle de Productos',
    ''
UNION ALL
SELECT 
    '-----------------------------------',
    '';

-- Detalle completo de productos
SELECT 
    u.email as verificacion,
    p.nombre || ' (' || p.marca || ') - ' || 
    COALESCE(cd.cantidad::text, '0') || ' ' || p.unidad_medida ||
    ' @ $' || COALESCE(cd.costo_unitario_usd::numeric(10,3)::text, '0.000') as resultado
FROM productos p
LEFT JOIN auth.users u ON p.usuario_id = u.id
LEFT JOIN compras_detalle cd ON cd.producto_id = p.id
ORDER BY u.email, p.nombre;

-- =========================================
-- RESUMEN FINAL
-- =========================================
SELECT '' as verificacion, '' as resultado
UNION ALL
SELECT 
    '═══════════════════════════════════',
    '═══════════════════════════════════'
UNION ALL
SELECT 
    '🎯 RESUMEN FINAL',
    ''
UNION ALL
SELECT 
    '═══════════════════════════════════',
    '═══════════════════════════════════'
UNION ALL
SELECT 
    'Total de productos:',
    COUNT(*)::text || ' productos'
FROM productos
UNION ALL
SELECT 
    'Productos con usuario_id:',
    COUNT(*)::text || ' (' || 
    ROUND(COUNT(*)::numeric / NULLIF((SELECT COUNT(*) FROM productos), 0) * 100, 0)::text || '%)' ||
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM productos) THEN ' ✅'
        ELSE ' ❌'
    END
FROM productos
WHERE usuario_id IS NOT NULL
UNION ALL
SELECT 
    'Usuarios con datos:',
    COUNT(DISTINCT usuario_id)::text || ' usuarios' ||
    CASE 
        WHEN COUNT(DISTINCT usuario_id) >= 2 THEN ' ✅'
        ELSE ' ⚠️  Esperado: 2 usuarios'
    END
FROM productos
WHERE usuario_id IS NOT NULL
UNION ALL
SELECT 
    'Políticas RLS activas:',
    COUNT(*)::text || ' políticas' ||
    CASE 
        WHEN COUNT(*) >= 12 THEN ' ✅'
        ELSE ' ❌ Esperado: 12+'
    END
FROM pg_policies
WHERE tablename IN ('productos', 'presentaciones', 'inventario')
UNION ALL
SELECT 
    'Estado del sistema:',
    CASE 
        WHEN (
            SELECT COUNT(*) FROM productos WHERE usuario_id IS NOT NULL
        ) > 0 AND (
            SELECT COUNT(*) FROM pg_policies 
            WHERE tablename IN ('productos', 'presentaciones', 'inventario')
        ) >= 12
        THEN '✅ MULTI-TENANT ACTIVO'
        ELSE '❌ REQUIERE MIGRACIÓN'
    END;

-- =========================================
-- INSTRUCCIONES FINALES
-- =========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '📋 RESULTADOS DE VERIFICACIÓN';
    RAISE NOTICE '═══════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE 'Si ves ✅ en todas las verificaciones:';
    RAISE NOTICE '  → La migración fue EXITOSA';
    RAISE NOTICE '  → El sistema es multi-tenant';
    RAISE NOTICE '  → Puedes usar la aplicación';
    RAISE NOTICE '';
    RAISE NOTICE 'Si ves ❌ en alguna verificación:';
    RAISE NOTICE '  → Revisa el archivo INSTRUCCIONES-MIGRACION.md';
    RAISE NOTICE '  → Ejecuta el script MASTER-migration-multitenant.sql';
    RAISE NOTICE '  → Vuelve a ejecutar esta verificación';
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════';
END $$;
