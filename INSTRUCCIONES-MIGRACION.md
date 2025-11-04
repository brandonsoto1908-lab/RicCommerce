# 🔧 Instrucciones de Migración Multi-Tenant

## ⚠️ IMPORTANTE: Lee todo antes de ejecutar

Esta migración convierte el sistema en **multi-tenant**, donde cada usuario tiene sus propios productos, presentaciones e inventario completamente aislados.

---

## 📋 ¿Qué hace esta migración?

### Antes (Sistema actual - PROBLEMA):
- ❌ Todos los usuarios ven los mismos productos
- ❌ Si Usuario A crea "Liquid Tide", Usuario B también lo ve
- ❌ Inventarios compartidos globalmente
- ❌ No hay aislamiento de datos

### Después (Sistema corregido):
- ✅ Cada usuario tiene sus propios productos
- ✅ Usuario A crea "Liquid Tide" → Solo él lo ve
- ✅ Usuario B puede crear su propio "Liquid Tide"
- ✅ Inventarios completamente aislados
- ✅ Seguridad RLS implementada

---

## 🚀 Pasos para ejecutar

### **Opción 1: Script Maestro (RECOMENDADO)**

Ejecuta TODO en un solo paso:

1. Ve a tu proyecto Supabase: https://supabase.com/dashboard
2. Selecciona tu proyecto **RicCommerce**
3. Menú lateral: **SQL Editor**
4. Click en **+ New Query**
5. Abre el archivo: `MASTER-migration-multitenant.sql`
6. Copia **TODO** el contenido (Ctrl+A, Ctrl+C)
7. Pégalo en el editor de Supabase (Ctrl+V)
8. Click en **Run** (o F5)
9. Espera a que termine (~30 segundos)
10. ✅ ¡Listo!

### **Opción 2: Scripts Individuales (Manual)**

Si prefieres ejecutar paso a paso:

#### Paso 1: Limpiar datos
```sql
-- Ejecuta: cleanup-all-data.sql
```

#### Paso 2: Migrar schema
```sql
-- Ejecuta: migration-add-usuario-id.sql
```

#### Paso 3: Insertar datos de Brandon
```sql
-- Ejecuta: seed-productos-brandonsoto-MULTITENANT.sql
```

#### Paso 4: Insertar datos de Ric
```sql
-- Ejecuta: seed-productos-ric-MULTITENANT.sql
```

---

## 📊 Datos que se insertarán

### Usuario 1: `brandonsoto1908@gmail.com`
- 7 productos
- 1,000 litros de cada producto líquido
- 1,600 unidades de Tide Pods
- 160 unidades de Laundry Beads
- **Inversión total: $2,944.00 USD**

### Usuario 2: `ric@stonebyric.com`
- 7 productos (mismos nombres, pero INDEPENDIENTES)
- 5,000 litros de cada producto líquido
- 200 unidades de Tide Pods
- 160 unidades de Laundry Beads
- **Inversión total: $9,920.00 USD**

---

## ✅ Verificación después de ejecutar

### 1. Verifica que la migración fue exitosa

En SQL Editor de Supabase, ejecuta:

```sql
-- Ver productos por usuario
SELECT 
  p.nombre,
  p.marca,
  u.email as usuario,
  cd.cantidad,
  cd.costo_unitario_usd
FROM productos p
JOIN auth.users u ON p.usuario_id = u.id
LEFT JOIN compras_detalle cd ON cd.producto_id = p.id
LEFT JOIN compras c ON cd.compra_id = c.id
ORDER BY u.email, p.nombre;
```

**Resultado esperado:**
```
nombre                  | marca    | usuario                        | cantidad | costo
------------------------|----------|--------------------------------|----------|-------
Bleach                  | Clorox   | brandonsoto1908@gmail.com      | 1000     | 0.384
Dawn Soap               | Dawn     | brandonsoto1908@gmail.com      | 1000     | 0.384
...
Bleach                  | Clorox   | ric@stonebyric.com             | 5000     | 0.384
Dawn Soap               | Dawn     | ric@stonebyric.com             | 5000     | 0.384
...
```

### 2. Verifica políticas RLS

```sql
-- Ver políticas activas
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('productos', 'presentaciones', 'inventario')
ORDER BY tablename;
```

**Deberías ver:**
- `productos_isolation_select`
- `productos_isolation_insert`
- `productos_isolation_update`
- `productos_isolation_delete`
- (Y lo mismo para presentaciones e inventario)

### 3. Prueba desde la aplicación

1. **Login como Brandon** (`brandonsoto1908@gmail.com`)
   - Deberías ver 7 productos
   - 5 productos de 1,000L cada uno
   - Tide Pods: 1,600 unidades
   
2. **Login como Ric** (`ric@stonebyric.com`)
   - Deberías ver 7 productos (mismos nombres pero diferentes)
   - 5 productos de 5,000L cada uno
   - Tide Pods: 200 unidades

3. **Verifica aislamiento:**
   - Los productos de Brandon NO aparecen en la cuenta de Ric
   - Los productos de Ric NO aparecen en la cuenta de Brandon
   - Cada uno puede crear productos con los mismos nombres sin conflicto

---

## 🔍 Cambios técnicos implementados

### Tablas modificadas:

#### 1. `productos`
```sql
-- Antes:
CREATE TABLE productos (
    id UUID,
    nombre VARCHAR(255),
    marca VARCHAR(255),
    UNIQUE(nombre, marca)  -- ❌ Global
);

-- Después:
CREATE TABLE productos (
    id UUID,
    nombre VARCHAR(255),
    marca VARCHAR(255),
    usuario_id UUID,  -- ✅ NUEVO
    UNIQUE(usuario_id, nombre, marca)  -- ✅ Por usuario
);
```

#### 2. `presentaciones`
```sql
-- Agregado:
usuario_id UUID REFERENCES auth.users(id)
```

#### 3. `inventario`
```sql
-- Agregado:
usuario_id UUID REFERENCES auth.users(id)
```

### Políticas RLS creadas:

Todas las tablas ahora tienen:
```sql
-- SELECT: Solo ver tus datos
USING (usuario_id = auth.uid())

-- INSERT: Solo insertar con tu ID
WITH CHECK (usuario_id = auth.uid())

-- UPDATE: Solo modificar tus datos
USING (usuario_id = auth.uid()) WITH CHECK (usuario_id = auth.uid())

-- DELETE: Solo eliminar tus datos
USING (usuario_id = auth.uid())
```

---

## 🛑 Problemas comunes

### Error: "Usuario no encontrado"
**Causa:** El usuario no existe en `auth.users`

**Solución:** Crea los usuarios primero en la aplicación o en Supabase Dashboard > Authentication

### Error: "column usuario_id does not exist"
**Causa:** La migración no se ejecutó completamente

**Solución:** Ejecuta el script `migration-add-usuario-id.sql` primero

### Error: "violates unique constraint"
**Causa:** Intentando insertar productos duplicados para el mismo usuario

**Solución:** Ejecuta `cleanup-all-data.sql` primero para limpiar todo

---

## 📞 Contacto

Si tienes problemas durante la migración:

1. Revisa los mensajes de RAISE NOTICE en el SQL Editor
2. Verifica que ambos usuarios existen en auth.users
3. Ejecuta el script de verificación (sección "Verificación")
4. Si el problema persiste, ejecuta el cleanup y vuelve a intentar

---

## ⚡ Resumen de archivos

- ✅ `MASTER-migration-multitenant.sql` → **EJECUTA ESTE** (todo en uno)
- 📄 `cleanup-all-data.sql` → Limpieza individual
- 📄 `migration-add-usuario-id.sql` → Migración de schema
- 📄 `seed-productos-brandonsoto-MULTITENANT.sql` → Datos Brandon
- 📄 `seed-productos-ric-MULTITENANT.sql` → Datos Ric
- 📖 `INSTRUCCIONES-MIGRACION.md` → Este archivo

---

## 🎯 Resultado final

Después de ejecutar:

```
✅ Sistema multi-tenant activado
✅ 2 usuarios con datos aislados
✅ 14 productos totales (7 por usuario)
✅ RLS configurado correctamente
✅ Cada usuario solo ve sus datos
```

¡Tu aplicación ahora es 100% multi-tenant! 🎉
