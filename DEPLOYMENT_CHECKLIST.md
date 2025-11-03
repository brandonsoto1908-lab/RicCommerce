# 📋 Checklist de Despliegue - RicCommerce

## Pre-Despliegue

### ✅ Base de Datos Supabase
- [ ] Proyecto de Supabase creado
- [ ] Archivo `supabase-schema.sql` ejecutado en SQL Editor
- [ ] Todas las tablas creadas correctamente
- [ ] Triggers y funciones funcionando
- [ ] Políticas RLS (Row Level Security) habilitadas
- [ ] Configuración inicial insertada en tabla `configuracion`

### ✅ Variables de Entorno
- [ ] `NEXT_PUBLIC_SUPABASE_URL` obtenida de Supabase
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` obtenida de Supabase
- [ ] `NEXT_PUBLIC_EXCHANGE_API_URL` configurada (o usar default)
- [ ] Variables guardadas en lugar seguro para usar en Vercel

### ✅ Repositorio Git
- [ ] Código subido a GitHub
- [ ] Archivo `.gitignore` actualizado
- [ ] Archivo `.env` NO subido al repositorio (debe estar en .gitignore)
- [ ] Archivo `.env.example` presente como referencia
- [ ] README.md actualizado con instrucciones

### ✅ Código Verificado
- [ ] `npm run build` ejecuta sin errores localmente
- [ ] `npm run dev` funciona correctamente
- [ ] No hay errores de TypeScript
- [ ] No hay errores de ESLint críticos

---

## Despliegue en Vercel

### ✅ Cuenta y Proyecto
- [ ] Cuenta de Vercel creada (puede ser con GitHub)
- [ ] Proyecto importado desde GitHub
- [ ] Framework detectado automáticamente como Next.js

### ✅ Configuración de Variables
- [ ] Variable `NEXT_PUBLIC_SUPABASE_URL` agregada en Vercel
- [ ] Variable `NEXT_PUBLIC_SUPABASE_ANON_KEY` agregada en Vercel
- [ ] Variable `NEXT_PUBLIC_EXCHANGE_API_URL` agregada en Vercel
- [ ] Variables marcadas para Production, Preview y Development

### ✅ Build y Deploy
- [ ] Build completado exitosamente (sin errores)
- [ ] Deploy completado exitosamente
- [ ] URL de producción generada: `https://________.vercel.app`

---

## Post-Despliegue

### ✅ Configuración de Supabase
- [ ] URL de Vercel agregada en Supabase Authentication Settings
- [ ] Site URL actualizada: `https://tu-proyecto.vercel.app`
- [ ] Redirect URLs actualizada: `https://tu-proyecto.vercel.app/**`
- [ ] Email templates configurados (si aplica)

### ✅ Verificación de Funcionalidad

#### Autenticación
- [ ] Registro de nuevo usuario funciona
- [ ] Login funciona correctamente
- [ ] Logout funciona
- [ ] Redirección al dashboard después de login

#### Módulo de Compras
- [ ] Crear producto nuevo funciona
- [ ] Registrar compra funciona
- [ ] Cálculo automático de precio unitario correcto
- [ ] Inventario se actualiza automáticamente
- [ ] Historial de compras visible

#### Módulo de Ventas
- [ ] Crear presentación funciona
- [ ] Calculadora de precio con margen objetivo funciona
- [ ] Conversión de unidades correcta (ML → L)
- [ ] Checkbox de gastos utilitarios funciona
- [ ] Registrar venta funciona
- [ ] Margen se calcula correctamente
- [ ] Inventario se descuenta automáticamente

#### Módulo de Gastos
- [ ] Registrar gasto único funciona
- [ ] Registrar gasto utilitario funciona
- [ ] Prorrateo de gastos en presentaciones correcto
- [ ] Historial de gastos visible

#### Módulo de Inventario
- [ ] Vista de inventario carga correctamente
- [ ] Cantidades actualizadas reflejan compras y ventas
- [ ] Costo promedio ponderado correcto
- [ ] Movimientos de inventario registrados

#### Módulo de Reportes
- [ ] Reporte de ventas genera PDF correctamente
- [ ] Reporte de compras genera PDF correctamente
- [ ] Reporte de gastos genera PDF correctamente
- [ ] Reporte de inventario genera PDF correctamente
- [ ] Filtros por fecha funcionan
- [ ] PDFs no muestran símbolos raros (₡ → CRC)

### ✅ Rendimiento y UX
- [ ] Página carga en menos de 3 segundos
- [ ] Navegación entre módulos fluida
- [ ] Tasa de cambio se actualiza correctamente
- [ ] Mensajes de error son claros
- [ ] Diseño responsive en móvil

### ✅ Seguridad
- [ ] RLS policies activas en Supabase
- [ ] Solo usuarios autenticados pueden acceder al dashboard
- [ ] No se exponen claves secretas en el código frontend
- [ ] Variables de entorno correctamente configuradas

---

## Mantenimiento Continuo

### ✅ Monitoreo
- [ ] Dashboard de Vercel revisado para errores
- [ ] Logs de Supabase revisados
- [ ] Tiempo de respuesta aceptable

### ✅ Actualizaciones
- [ ] Proceso de actualización documentado
- [ ] Git push automáticamente despliega en Vercel
- [ ] Rollback disponible si es necesario

### ✅ Respaldos
- [ ] Respaldo de base de datos configurado en Supabase
- [ ] Código versionado en GitHub

---

## 🎉 ¡Despliegue Completado!

Una vez que todos los checkmarks estén marcados, tu aplicación está:
- ✅ Completamente funcional
- ✅ Segura
- ✅ Lista para producción
- ✅ Fácil de actualizar

**URL de Producción**: `https://________________.vercel.app`

**Fecha de Despliegue**: _______________

**Desplegado por**: _______________
